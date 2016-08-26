----  STATUS OF THE SLTR CLAIM ----
  

-- View: application.systematic_registration_certificates
DROP VIEW application.systematic_registration_certificates;
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
  WHERE sg.hierarchy_level = 4 AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom) AND (co.name_firstpart::text || co.name_lastpart::text) = (ap.name_firstpart::text || ap.name_lastpart::text)
   AND (co.name_firstpart::text || co.name_lastpart::text) = (bu.name_firstpart::text || bu.name_lastpart::text) AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text 
   AND s.request_type_code::text = 'systematicRegn'::text AND (aa.status_code::text = 'approved'::text OR aa.status_code::text = 'archived'::text) AND bu.id::text = su.ba_unit_id::text 
   AND su.spatial_unit_id::text = sa.spatial_unit_id::text AND sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text 
   AND COALESCE(bu.land_use_code, 'res_home'::character varying)::text = lu.code::text
  ORDER BY co.name_firstpart, co.name_lastpart;

ALTER TABLE application.systematic_registration_certificates
  OWNER TO postgres;
---------------------------------------------------------------------------
--DROP VIEW application.systematic_registration_certificates;
--CREATE OR REPLACE VIEW application.systematic_registration_certificates AS 
  --SELECT DISTINCT 
 
    --co.id											AS id, 
    --co.name_firstpart										AS name_firstpart, 
    --co.name_lastpart										AS name_lastpart, 
    --su.ba_unit_id										AS ba_unit_id, 
    --round(sa.size) 										AS size, 
    --administrative.get_parcel_share(su.ba_unit_id) 						AS owners, 

--	SYSTEM.SETTING TABLE
--	system.setting.system_id
    --( SELECT setting.vl
      --       from system.setting
        --     WHERE setting.name::text = 'state'::text) 					AS state, 
          
-- 	system.setting.surveyor
   -- ( SELECT setting.vl
     --      FROM system.setting
       --   WHERE setting.name::text = 'surveyor'::text) 						AS surveyor, 


--	system.setting.rank
   -- ( SELECT setting.vl
     --      FROM system.setting
       --   WHERE setting.name::text = 'surveyorRank'::text) 					AS rank,



--	SYSTEM.CONFIG_MAP_LAYER_METADATA TABLE

-- 	imagerydate
    --( SELECT config_map_layer_metadata.value
      --     FROM system.config_map_layer_metadata
        --  WHERE config_map_layer_metadata.name_layer::text = 'orthophoto'::text 
          --AND config_map_layer_metadata.name::text = 'date'::text) 				AS imagerydate, 
--	imageryresolution
    --( SELECT config_map_layer_metadata.value
      --     FROM system.config_map_layer_metadata
        --  WHERE config_map_layer_metadata.name_layer::text = 'orthophoto'::text 
          --AND config_map_layer_metadata.name::text = 'resolution'::text) 			AS imageryresolution, 
--	imagerysource
    --( SELECT config_map_layer_metadata.value
      --     FROM system.config_map_layer_metadata
        --  WHERE config_map_layer_metadata.name_layer::text = 'orthophoto'::text 
          --AND config_map_layer_metadata.name::text = 'data-source'::text) 			AS imagerysource, 

--   	 lga 
--      lga.display_value										AS lga, 
        
--   	 zone 
    
  --  zone.display_value										AS zone, 

--   	 location 
    
    --ad.description										AS location, 

--    	 plan        
    
    --co.source_reference										AS plan, 

-- 	 sheetnr  
    
    --co.intell_map_sheet										AS sheetnr, 

-- 	 date commenced
    
    --rrr.date_commenced										AS commencingdate, 

--  	 purpose     
    
    --lu.display_value										AS purpose, 

--  	 term     
    
    --rrr.term											AS term,

--       rent
    
    --rrr.yearly_rent										AS  rent

   --FROM 
    --cadastre.cadastre_object co, 
    --administrative.ba_unit bu, 
    --cadastre.land_use_type lu, 
    --cadastre.lga_type lga,
    --cadastre.zone_type zone, 
    --cadastre.spatial_value_area sa, 
    --administrative.ba_unit_contains_spatial_unit su,
    --administrative.rrr rrr,
    --address.address ad,
    --cadastre.spatial_unit_address  sad
    
  --WHERE 
  --bu.id::text = su.ba_unit_id::text
  --AND bu.id::text = rrr.ba_unit_id::text
  --AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  --AND sa.spatial_unit_id::text = co.id::text 
  --AND sa.type_code::text = 'officialArea'::text 
  --AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text
  --AND coalesce(co.lga_code::text, 'Katsina')  = lga.code::text 
  --AND rrr.zone_code::text = zone.code::text
  --AND ad.id =  sad.address_id
  --AND co.id =  sad.spatial_unit_id
  --AND rrr.type_code = 'ownership'
  --ORDER BY co.name_firstpart, co.name_lastpart;
-------------------------------------------------------------------------------------------------