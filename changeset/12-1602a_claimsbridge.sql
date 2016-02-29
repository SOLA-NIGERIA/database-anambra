DROP VIEW application.systematic_registration_certificates;
DROP VIEW administrative.sys_reg_owner_name;
DROP VIEW administrative.systematic_registration_listing;
DROP VIEW administrative.sys_reg_state_land;
DROP VIEW administrative.sys_reg_signing_list;

DROP VIEW cadastre.current_parcels;
DROP VIEW cadastre.pending_parcels;
DROP VIEW cadastre.current_pending_parcels;
DROP VIEW cadastre.historic_parcels;
    

ALTER TABLE cadastre.cadastre_object
   ALTER COLUMN name_lastpart TYPE character varying(255);

ALTER TABLE cadastre.cadastre_object_historic
   ALTER COLUMN name_lastpart TYPE character varying(255);



   ALTER TABLE administrative.ba_unit
   ALTER COLUMN name_lastpart TYPE character varying(255);

ALTER TABLE administrative.ba_unit_historic
   ALTER COLUMN name_lastpart TYPE character varying(255);

-- View: application.systematic_registration_certificates

   CREATE OR REPLACE VIEW application.systematic_registration_certificates AS 
 SELECT DISTINCT aa.nr, co.name_firstpart, co.name_lastpart, su.ba_unit_id, 
    sg.name::text AS name, aa.id::text AS appid, 
    aa.change_time AS commencingdate, 
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
    (( SELECT count(s.id) AS count
           FROM source.source s
          WHERE s.description::text ~~ ((('TOTAL_'::text || 'title'::text) || '%'::text) || replace(sg.name::text, '/'::text, '-'::text))))::integer AS cofo, 
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
          WHERE setting.name::text = 'surveyorRank'::text) AS rank
   FROM cadastre.spatial_unit_group sg, cadastre.cadastre_object co, 
    administrative.ba_unit bu, cadastre.land_use_type lu, 
    cadastre.spatial_value_area sa, 
    administrative.ba_unit_contains_spatial_unit su, 
    application.application_property ap, application.application aa, 
    application.service s
  WHERE sg.hierarchy_level = 4 AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom) AND (co.name_firstpart::text || co.name_lastpart::text) = (ap.name_firstpart::text || ap.name_lastpart::text) AND (co.name_firstpart::text || co.name_lastpart::text) = (bu.name_firstpart::text || bu.name_lastpart::text) AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text AND (aa.status_code::text = 'approved'::text OR aa.status_code::text = 'archived'::text) AND bu.id::text = su.ba_unit_id::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text AND sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text AND COALESCE(bu.land_use_code, 'res_home'::character varying)::text = lu.code::text
  ORDER BY co.name_firstpart, co.name_lastpart;

ALTER TABLE application.systematic_registration_certificates
  OWNER TO postgres;

-- View: administrative.sys_reg_owner_name

-- DROP VIEW administrative.sys_reg_owner_name;

CREATE OR REPLACE VIEW administrative.sys_reg_owner_name AS 
 SELECT (pp.name::text || ' '::text) || COALESCE(pp.last_name, ''::character varying)::text AS value, 
    pp.name::text AS party, 
    COALESCE(pp.last_name, ''::character varying)::text AS last_name, co.id, 
    co.name_firstpart, co.name_lastpart, 
    get_translation(lu.display_value, NULL::character varying) AS land_use_code, 
    su.ba_unit_id, round(sa.size, 0) AS size, sg.name::text AS name, 
    bu.location, rrrt.display_value AS rrr
   FROM cadastre.land_use_type lu, cadastre.cadastre_object co, 
    cadastre.spatial_value_area sa, 
    administrative.ba_unit_contains_spatial_unit su, 
    application.application_property ap, application.application aa, 
    application.service s, administrative.ba_unit bu, 
    cadastre.spatial_unit_group sg, administrative.rrr rrr, 
    administrative.rrr_type rrrt, party.party pp, 
    administrative.party_for_rrr pr
  WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text AND (ap.ba_unit_id::text = su.ba_unit_id::text OR (ap.name_lastpart::text || ap.name_firstpart::text) = (bu.name_lastpart::text || bu.name_firstpart::text)) AND (co.name_lastpart::text || co.name_firstpart::text) = (bu.name_lastpart::text || bu.name_firstpart::text) AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text AND s.status_code::text = 'completed'::text AND COALESCE(bu.land_use_code, 'residential'::character varying)::text = lu.code::text AND bu.id::text = su.ba_unit_id::text AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom) AND sg.hierarchy_level = 4 AND rrr.ba_unit_id::text = bu.id::text AND rrr.type_code::text = rrrt.code::text AND pp.id::text = pr.party_id::text AND pr.rrr_id::text = rrr.id::text
  ORDER BY COALESCE(pp.last_name, ''::character varying)::text, pp.name::text;

ALTER TABLE administrative.sys_reg_owner_name
  OWNER TO postgres;

-- View: administrative.sys_reg_signing_list

-- DROP VIEW administrative.sys_reg_signing_list;

CREATE OR REPLACE VIEW administrative.sys_reg_signing_list AS 
 SELECT DISTINCT co.id, co.name_firstpart, co.name_lastpart, 
    (co.name_lastpart::text || '/'::text) || co.name_firstpart::text AS parcel, 
    sg.name::text AS name, 
    administrative.get_parcel_ownernames(bu.id) AS persons
   FROM cadastre.cadastre_object co, cadastre.spatial_value_area sa, 
    administrative.ba_unit_contains_spatial_unit su, 
    application.application_property ap, application.application aa, 
    application.service s, administrative.ba_unit bu, 
    cadastre.spatial_unit_group sg, administrative.rrr rrr, 
    administrative.rrr_type rrrt, party.party pp, 
    administrative.party_for_rrr pr
  WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text AND (ap.ba_unit_id::text = su.ba_unit_id::text OR (ap.name_lastpart::text || ap.name_firstpart::text) = (bu.name_lastpart::text || bu.name_firstpart::text)) AND (co.name_lastpart::text || co.name_firstpart::text) = (bu.name_lastpart::text || bu.name_firstpart::text) AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text AND s.status_code::text = 'completed'::text AND bu.id::text = su.ba_unit_id::text AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom) AND sg.hierarchy_level = 4 AND rrr.ba_unit_id::text = bu.id::text AND rrr.type_code::text = rrrt.code::text AND pp.id::text = pr.party_id::text AND pr.rrr_id::text = rrr.id::text AND sg.hierarchy_level = 4 AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom)
  ORDER BY (co.name_lastpart::text || '/'::text) || co.name_firstpart::text;

ALTER TABLE administrative.sys_reg_signing_list
  OWNER TO postgres;

-- View: administrative.sys_reg_state_land

-- DROP VIEW administrative.sys_reg_state_land;

CREATE OR REPLACE VIEW administrative.sys_reg_state_land AS 
 SELECT (pp.name::text || ' '::text) || COALESCE(pp.last_name, ' '::character varying)::text AS value, 
    co.id, co.name_firstpart, co.name_lastpart, 
    get_translation(lu.display_value, NULL::character varying) AS land_use_code, 
    su.ba_unit_id, sa.size, sg.name::text AS name, 
        CASE
            WHEN "substring"(COALESCE(bu.land_use_code, 'residential'::character varying)::text, 1, 3) = 'res'::text THEN sa.size
            ELSE 0::numeric
        END AS residential, 
        CASE
            WHEN "substring"(COALESCE(bu.land_use_code, 'residential'::character varying)::text, 5, 5) = 'agric'::text THEN sa.size
            ELSE 0::numeric
        END AS agricultural, 
        CASE
            WHEN "substring"(COALESCE(bu.land_use_code, 'residential'::character varying)::text, 5, 10) = 'commercial'::text THEN sa.size
            ELSE 0::numeric
        END AS commercial, 
        CASE
            WHEN "substring"(COALESCE(bu.land_use_code, 'residential'::character varying)::text, 5, 10) = 'industrial'::text THEN sa.size
            ELSE 0::numeric
        END AS industrial
   FROM cadastre.land_use_type lu, cadastre.cadastre_object co, 
    cadastre.spatial_value_area sa, 
    administrative.ba_unit_contains_spatial_unit su, 
    application.application_property ap, application.application aa, 
    application.service s, party.party pp, administrative.party_for_rrr pr, 
    administrative.rrr rrr, administrative.ba_unit bu, 
    cadastre.spatial_unit_group sg
  WHERE sa.spatial_unit_id::text = co.id::text AND COALESCE(bu.land_use_code, 'residential'::character varying)::text = lu.code::text AND sa.type_code::text = 'officialArea'::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text AND (ap.ba_unit_id::text = su.ba_unit_id::text OR ap.name_lastpart::text = bu.name_lastpart::text AND ap.name_firstpart::text = bu.name_firstpart::text) AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text AND s.status_code::text = 'completed'::text AND pp.id::text = pr.party_id::text AND pr.rrr_id::text = rrr.id::text AND rrr.ba_unit_id::text = su.ba_unit_id::text AND rrr.type_code::text = 'stateOwnership'::text AND bu.id::text = su.ba_unit_id::text AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom)
  ORDER BY (pp.name::text || ' '::text) || COALESCE(pp.last_name, ' '::character varying)::text;

ALTER TABLE administrative.sys_reg_state_land
  OWNER TO postgres;

-- View: administrative.systematic_registration_listing

-- DROP VIEW administrative.systematic_registration_listing;

CREATE OR REPLACE VIEW administrative.systematic_registration_listing AS 
         SELECT DISTINCT co.id, co.name_firstpart, co.name_lastpart, 
            round(sa.size, 0) AS size, 
            get_translation(lu.display_value, NULL::character varying) AS land_use_code, 
            su.ba_unit_id, sg.name::text AS name, 
            bu.location AS property_location
           FROM cadastre.land_use_type lu, cadastre.cadastre_object co, 
            cadastre.spatial_value_area sa, 
            administrative.ba_unit_contains_spatial_unit su, 
            application.application_property ap, application.application aa, 
            application.service s, administrative.ba_unit bu, 
            cadastre.spatial_unit_group sg
          WHERE (co.name_firstpart::text || co.name_lastpart::text) = (ap.name_firstpart::text || ap.name_lastpart::text) AND (co.name_firstpart::text || co.name_lastpart::text) = (bu.name_firstpart::text || bu.name_lastpart::text) AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text AND s.request_type_code::text = 'systematicRegn'::text AND sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text AND su.spatial_unit_id::text = sa.spatial_unit_id::text AND su.spatial_unit_id::text = co.id::text AND (ap.ba_unit_id::text = su.ba_unit_id::text OR ap.name_lastpart::text = bu.name_lastpart::text AND ap.name_firstpart::text = bu.name_firstpart::text) AND s.status_code::text = 'completed'::text AND COALESCE(bu.land_use_code, 'res_home'::character varying)::text = lu.code::text AND bu.id::text = su.ba_unit_id::text AND sg.hierarchy_level = 4 AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom)
UNION 
         SELECT DISTINCT co.id, co.name_firstpart, co.name_lastpart, 
            round(sa.size, 0) AS size, co.land_use_code, ''::text AS ba_unit_id, 
            sg.name::text AS name, ''::text AS property_location
           FROM cadastre.cadastre_object co, cadastre.spatial_value_area sa, 
            cadastre.spatial_unit_group sg, application.application_property ap
          WHERE co.status_code::text = 'current'::text AND sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom) AND sg.hierarchy_level = 4 AND NOT (co.name_firstpart::text || co.name_lastpart::text IN ( SELECT ap.name_firstpart::text || ap.name_lastpart::text
                   FROM application.application_property ap)) AND co.name_firstpart::text ~~ 'NC%'::text
  ORDER BY 2;

ALTER TABLE administrative.systematic_registration_listing
  OWNER TO postgres;


-- View: cadastre.current_parcels

-- DROP VIEW cadastre.current_parcels;

CREATE OR REPLACE VIEW cadastre.current_parcels AS 
 SELECT c.view_id, c.id, 
    (c.name_lastpart::text || '/'::text) || c.name_firstpart::text AS parcel_code, 
    c.geom_polygon, c.status_code, 
    ( SELECT spatial_value_area.size
           FROM cadastre.spatial_value_area
          WHERE spatial_value_area.spatial_unit_id::text = c.id::text AND spatial_value_area.type_code::text = 'officialArea'::text
         LIMIT 1) AS official_area
   FROM cadastre.cadastre_object c
  WHERE c.type_code::text = 'parcel'::text AND c.geom_polygon IS NOT NULL AND c.status_code::text = 'current'::text;

ALTER TABLE cadastre.current_parcels
  OWNER TO postgres;
GRANT ALL ON TABLE cadastre.current_parcels TO postgres;
GRANT SELECT ON TABLE cadastre.current_parcels TO sola_reader;

-- View: cadastre.current_pending_parcels

-- DROP VIEW cadastre.current_pending_parcels;

CREATE OR REPLACE VIEW cadastre.current_pending_parcels AS 
 SELECT c.view_id, c.id, 
    (c.name_lastpart::text || '/'::text) || c.name_firstpart::text AS parcel_code, 
    c.geom_polygon, c.status_code, 
    ( SELECT spatial_value_area.size
           FROM cadastre.spatial_value_area
          WHERE spatial_value_area.spatial_unit_id::text = c.id::text AND spatial_value_area.type_code::text = 'officialArea'::text
         LIMIT 1) AS official_area
   FROM cadastre.cadastre_object c
  WHERE c.type_code::text = 'parcel'::text AND c.geom_polygon IS NOT NULL AND (c.status_code::text = ANY (ARRAY['current'::character varying, 'pending'::character varying]::text[]));

ALTER TABLE cadastre.current_pending_parcels
  OWNER TO postgres;
GRANT ALL ON TABLE cadastre.current_pending_parcels TO postgres;
GRANT SELECT ON TABLE cadastre.current_pending_parcels TO sola_reader;

-- View: cadastre.historic_parcels

-- DROP VIEW cadastre.historic_parcels;

CREATE OR REPLACE VIEW cadastre.historic_parcels AS 
 SELECT c.view_id, c.id, 
    (c.name_lastpart::text || '/'::text) || c.name_firstpart::text AS parcel_code, 
    c.geom_polygon, c.status_code, 
    ( SELECT spatial_value_area.size
           FROM cadastre.spatial_value_area
          WHERE spatial_value_area.spatial_unit_id::text = c.id::text AND spatial_value_area.type_code::text = 'officialArea'::text
         LIMIT 1) AS official_area
   FROM cadastre.cadastre_object c
  WHERE c.type_code::text = 'parcel'::text AND c.geom_polygon IS NOT NULL AND c.status_code::text = 'historic'::text;

ALTER TABLE cadastre.historic_parcels
  OWNER TO postgres;
GRANT ALL ON TABLE cadastre.historic_parcels TO postgres;
GRANT SELECT ON TABLE cadastre.historic_parcels TO sola_reader;

-- View: cadastre.pending_parcels

-- DROP VIEW cadastre.pending_parcels;

CREATE OR REPLACE VIEW cadastre.pending_parcels AS 
 SELECT c.view_id, c.id, 
    (c.name_lastpart::text || '/'::text) || c.name_firstpart::text AS parcel_code, 
    c.geom_polygon, c.status_code, 
    ( SELECT spatial_value_area.size
           FROM cadastre.spatial_value_area
          WHERE spatial_value_area.spatial_unit_id::text = c.id::text AND spatial_value_area.type_code::text = 'officialArea'::text
         LIMIT 1) AS official_area
   FROM cadastre.cadastre_object c
  WHERE c.type_code::text = 'parcel'::text AND c.geom_polygon IS NOT NULL AND c.status_code::text = 'pending'::text;

ALTER TABLE cadastre.pending_parcels
  OWNER TO postgres;
GRANT ALL ON TABLE cadastre.pending_parcels TO postgres;
GRANT SELECT ON TABLE cadastre.pending_parcels TO sola_reader;

