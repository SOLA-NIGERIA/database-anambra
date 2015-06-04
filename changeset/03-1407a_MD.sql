insert into system.setting(name, vl, active, description) values('title-plan-gridcut-srid', 26332, true, 'The srid of the grid cut used in the title plan map');
insert into system.setting(name, vl, active, description) values('surveyor', 'Abolarin Michael Biodun', true, 'Name of Surveyor');
insert into system.setting(name, vl, active, description) values('surveyorRank', 'Deputy SLTR Officer', true, 'The rank of the Surveyor');




insert into system.query(name, sql) 
values('SpatialResult.getParcelsForParcelPlan', 
'select co.id, 
co.name_firstpart as label,  
st_asewkb(st_transform(co.geom_polygon, #{srid})) as the_geom 
from cadastre.cadastre_object co 
where type_code= ''parcel'' and status_code= ''current'' 
and ST_Intersects(st_transform(co.geom_polygon, #{srid}), 
ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid})) and st_area(co.geom_polygon)> power(5 * #{pixel_res}, 2)');

insert into system.config_map_layer(name, title, type_code, active, visible_in_start, item_order, style, pojo_structure, pojo_query_name, use_in_public_display) 
values('parcels-for-parcel-plan', 'Parcels for Parcel Plan', 'pojo', false, false, 82, 'parcels_for_parcel_plan.xml', 'theGeom:Polygon,label:""', 'SpatialResult.getParcelsForParcelPlan', false);

insert into system.config_map_layer_metadata (name_layer ,"name" , "value") values ('parcels-for-parcel-plan', 'in-plan-production', 'true');
insert into system.config_map_layer_metadata (name_layer ,"name" , "value") values ('parcels-for-parcel-plan', 'in-plan-sketch-production', 'true');



insert into system.query(name, sql)
values('SpatialResult.getRoadCenterlinesForParcelPlan', 
'select id, label, st_asewkb(st_transform(geom, #{srid})) as the_geom 
from cadastre.spatial_unit
where level_id = ''road-centerline'' and ST_Intersects(st_transform(geom, #{srid}), ST_SetSRID(ST_3DMakeBox(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))');

insert into system.config_map_layer(name, title, type_code, active, visible_in_start, item_order, style, pojo_structure, pojo_query_name)
values('road-centerlines-for-parcel-plan', 'Road centerlines for Parcel Plan', 'pojo', true, true, 35, 'road_centerline_for_parcel_plan.xml', 'theGeom:LineString,label:""', 'SpatialResult.getRoadCenterlinesForParcelPlan');

insert into system.config_map_layer_metadata (name_layer ,"name" , "value") values ('road-centerlines-for-parcel-plan', 'in-plan-production', 'true');


insert into system.config_map_layer_metadata (name_layer ,"name" , "value") values ('orthophoto', 'resolution', '50 cm');
insert into system.config_map_layer_metadata (name_layer ,"name" , "value") values ('orthophoto', 'data-source', 'Minna Datum/UTM');
insert into system.config_map_layer_metadata (name_layer ,"name" , "value") values ('orthophoto', 'in-plan-sketch-production', 'true');
update system.config_map_layer_metadata set  value = 'true' where "name" = 'in-plan-production' and  name_layer = 'orthophoto';
update system.config_map_layer_metadata set  value = 'false' where "name" = 'in-plan-production' and  name_layer not in ('orthophoto','parcels-for-parcel-plan','road-centerlines-for-parcel-plan');



DROP VIEW application.systematic_registration_certificates;

CREATE OR REPLACE VIEW application.systematic_registration_certificates AS 
 SELECT DISTINCT 
 aa.nr, 
 co.name_firstpart, 
 co.name_lastpart, 
 su.ba_unit_id, 
 sg.name::text AS name, 
 aa.id::text AS appid, 
 aa.change_time AS commencingdate, 
 "substring"(lu.display_value::text, 0, "position"(lu.display_value::text, '-'::text)) AS landuse,
( SELECT lga.label
           FROM cadastre.spatial_unit_group lga
          WHERE lga.hierarchy_level = 2 AND co.name_lastpart::text ~~ (lga.name::text || '/%'::text)) AS proplocation, 
  round(sa.size) AS size, administrative.get_parcel_share(su.ba_unit_id) AS owners, 
  (co.name_lastpart::text || '/'::text) || upper(co.name_firstpart::text) AS title, 
  co.id, 
  ( SELECT lga.label
           FROM cadastre.spatial_unit_group lga
          WHERE lga.hierarchy_level = 3 AND co.name_lastpart::text = lga.name::text) AS ward, ( SELECT lga.label
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
          '' as sheetnr,
          ( SELECT system.setting.vl
           FROM system.setting
          WHERE system.setting.name::text = 'surveyor'::text) AS surveyor,
          ( SELECT system.setting.vl
           FROM system.setting
          WHERE system.setting.name::text = 'surveyorRank'::text) AS rank
    FROM 
   cadastre.spatial_unit_group sg,
   cadastre.cadastre_object co,
   administrative.ba_unit bu,  
   cadastre.land_use_type lu, 
   cadastre.spatial_value_area sa, 
   administrative.ba_unit_contains_spatial_unit su, application.application_property ap, 
   application.application aa, 
   application.service s
  WHERE
  sg.hierarchy_level = 4 
  AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom)  
  AND ((co.name_firstpart::text || co.name_lastpart::text)=(ap.name_firstpart::text || ap.name_lastpart::text)) 
  AND ((co.name_firstpart::text || co.name_lastpart::text)=(bu.name_firstpart::text || bu.name_lastpart::text)) 
  AND aa.id::text = ap.application_id::text 
  AND s.application_id::text = aa.id::text 
  AND s.request_type_code::text = 'systematicRegn'::text 
  AND (aa.status_code::text = 'approved'::text OR aa.status_code::text = 'archived'::text) 
  AND  bu.id::text = su.ba_unit_id::text 
  AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  AND sa.spatial_unit_id::text = co.id::text 
  AND sa.type_code::text = 'officialArea'::text 
  AND COALESCE(bu.land_use_code, 'res_home'::character varying)::text = lu.code::text
  ORDER BY co.name_firstpart, co.name_lastpart;

ALTER TABLE application.systematic_registration_certificates OWNER TO postgres;

ALTER TABLE "document"."document" ALTER description TYPE character varying(300);
ALTER TABLE "document"."document_historic" ALTER description TYPE character varying(300);


