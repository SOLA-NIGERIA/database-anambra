--correction to interim BR to calculate annual rent
DELETE FROM system.br_definition WHERE br_id ='generate_ground_rent';
INSERT INTO system.br_definition VALUES ('generate_ground_rent', '2016-09-04', 'infinity', 
	'SELECT CASE 	WHEN (SELECT (tarrif_type = ''residential'') AND (propLocation = ''AN/AWKA SOUTH'')) THEN  5 * size 
			WHEN (SELECT (tarrif_type = ''commercial'') AND (propLocation = ''AN/AWKA SOUTH'')) THEN  5 * size 
			WHEN (SELECT (tarrif_type = ''industrial'') AND (propLocation = ''AN/AWKA SOUTH'')) THEN  5 * size 
			WHEN (SELECT (tarrif_type = ''agricultural'') AND (propLocation = ''AN/AWKA SOUTH'')) THEN  5 * size
			WHEN (SELECT (tarrif_type = ''zero'')) THEN  0      	
			ELSE 5 * size
	END AS vl
FROM application.systematic_registration_certificates 
WHERE ba_unit_id = #{id}
');

--modification to View application.systematic_registration_certificates to remove two improvement premium fields

DROP VIEW IF EXISTS application.systematic_registration_certificates;

CREATE OR REPLACE VIEW application.systematic_registration_certificates AS 
 SELECT DISTINCT aa.nr,
    co.name_firstpart,
    co.name_lastpart,
    su.ba_unit_id,
    sg.name::text AS name,
    aa.id::text AS appid,
    "substring"(lu.display_value::text, 0, "position"(lu.display_value::text, '-'::text)) AS landuse,
    ( SELECT lga.label
           FROM cadastre.spatial_unit_group lga
          WHERE lga.hierarchy_level = 2 AND co.name_lastpart::text ~~ (lga.name::text || '/%'::text)) AS proplocation,
    round(sa.size) AS size,
    administrative.get_parcel_share(su.ba_unit_id) AS owners,
    (co.name_lastpart::text || '/'::text) || upper(co.name_firstpart::text) AS title,
    co.id,
    ( SELECT lga.label
           FROM cadastre.spatial_unit_group lga
          WHERE lga.hierarchy_level = 3 AND co.name_lastpart::text = lga.name::text) AS ward,
    ( SELECT lga.label
           FROM cadastre.spatial_unit_group lga
          WHERE lga.hierarchy_level = 1) AS state,
    ( SELECT config_map_layer_metadata.value
           FROM system.config_map_layer_metadata
          WHERE config_map_layer_metadata.name_layer::text = 'orthophoto'::text AND config_map_layer_metadata.name::text = 'date'::text) AS imagerydate,
    (( SELECT count(s_1.id) AS count
           FROM source.source s_1
          WHERE s_1.description::text ~~ ((('TOTAL_'::text || 'title'::text) || '%'::text) || replace(sg.name::text, '/'::text, '-'::text))))::integer AS cofo,
    ( SELECT config_map_layer_metadata.value
           FROM system.config_map_layer_metadata
          WHERE config_map_layer_metadata.name_layer::text = 'orthophoto'::text AND config_map_layer_metadata.name::text = 'resolution'::text) AS imageryresolution,
    ( SELECT config_map_layer_metadata.value
           FROM system.config_map_layer_metadata
          WHERE config_map_layer_metadata.name_layer::text = 'orthophoto'::text AND config_map_layer_metadata.name::text = 'data-source'::text) AS imagerysource,
    ( SELECT config_map_layer_metadata.value
           FROM system.config_map_layer_metadata
          WHERE config_map_layer_metadata.name_layer::text = 'orthophoto'::text AND config_map_layer_metadata.name::text = 'sheet-number'::text) AS sheetnr,
    ( SELECT setting.vl
           FROM system.setting
          WHERE setting.name::text = 'surveyor'::text) AS surveyor,
    ( SELECT setting.vl
           FROM system.setting
          WHERE setting.name::text = 'surveyorRank'::text) AS rank,
    rrr.date_commenced AS commencingdate,
    rrr.term,
    rrr.yearly_rent AS rent,
    rrr.rot_code AS estate,
    ltr.tarrif_type AS tarrif_type,
    ltr.premium_state_land,
    ltr.premium_non_state_land AS premium_non_state,
        CASE
            WHEN rrr.rot_code::text = 'P'::text THEN ltr.rent_non_state_land::numeric * sa.size
            WHEN rrr.rot_code::text = 'G'::text THEN ltr.rent_state_land::numeric * sa.size
            ELSE 0::numeric
        END AS stamp_duty
   FROM cadastre.lga_tarrif_rate ltr,
    cadastre.spatial_unit_group sg,
    cadastre.cadastre_object co,
    administrative.ba_unit bu,
    cadastre.land_use_type lu,
    cadastre.spatial_value_area sa,
    administrative.ba_unit_contains_spatial_unit su,
    application.application_property ap,
    application.application aa,
    application.service s,
    administrative.rrr rrr,
    address.address ad
  WHERE sg.hierarchy_level = 4 AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom) AND (co.name_firstpart::text || co.name_lastpart::text) = (ap.name_firstpart::text || ap.name_lastpart::text) AND (co.name_firstpart::text || co.name_lastpart::text) = (bu.name_firstpart::text || bu.name_lastpart::text) AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text AND (aa.status_code::text = 'approved'::text OR aa.status_code::text = 'archived'::text) AND bu.id::text = su.ba_unit_id::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text AND sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text AND COALESCE(bu.land_use_code, 'res_home'::character varying)::text = lu.code::text AND bu.id::text = rrr.ba_unit_id::text AND lu.tarrif_code::text = ltr.tarrif_type::text AND ltr.sug_id::text = "substring"(co.name_lastpart::text, 0, "position"("substring"(co.name_lastpart::text, "position"(co.name_lastpart::text, '/'::text) + 1), '/'::text) + "position"(co.name_lastpart::text, '/'::text))
  ORDER BY co.name_firstpart, co.name_lastpart;

ALTER TABLE application.systematic_registration_certificates
  OWNER TO postgres;
