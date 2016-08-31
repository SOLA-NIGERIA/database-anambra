-- View: application.systematic_registration_certificates
DROP VIEW application.systematic_registration_certificates;
   CREATE OR REPLACE VIEW application.systematic_registration_certificates AS 
 SELECT DISTINCT aa.nr, co.name_firstpart, co.name_lastpart, su.ba_unit_id, 
    sg.name::text AS name, aa.id::text AS appid, 
    --aa.change_time AS commencingdate, 
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
          WHERE setting.name::text = 'surveyorRank'::text) AS rank,
	 rrr.date_commenced										AS commencingdate, 
         rrr.term											AS term,
         rrr.yearly_rent										AS  rent,
         rrr.rot_code                                                                                   AS estate
    
   FROM cadastre.spatial_unit_group sg, cadastre.cadastre_object co, 
    administrative.ba_unit bu, cadastre.land_use_type lu, 
    cadastre.spatial_value_area sa, 
    administrative.ba_unit_contains_spatial_unit su, 
    application.application_property ap, application.application aa, 
    application.service s,
	administrative.rrr rrr,
    address.address ad
  WHERE sg.hierarchy_level = 4 AND st_intersects(st_pointonsurface(co.geom_polygon), sg.geom) AND (co.name_firstpart::text || co.name_lastpart::text) = (ap.name_firstpart::text || ap.name_lastpart::text)
   AND (co.name_firstpart::text || co.name_lastpart::text) = (bu.name_firstpart::text || bu.name_lastpart::text) AND aa.id::text = ap.application_id::text AND s.application_id::text = aa.id::text 
   AND s.request_type_code::text = 'systematicRegn'::text AND (aa.status_code::text = 'approved'::text OR aa.status_code::text = 'archived'::text) AND bu.id::text = su.ba_unit_id::text 
   AND su.spatial_unit_id::text = sa.spatial_unit_id::text AND sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text 
   AND COALESCE(bu.land_use_code, 'res_home'::character varying)::text = lu.code::text
   AND bu.id::text = rrr.ba_unit_id::text
  ORDER BY co.name_firstpart, co.name_lastpart;


  INSERT INTO system.setting(
            name, vl, active, description)
    VALUES ('governor', 'NAME OF THE GOVERNOR', true, 'the name of the governor of the state who will sign the CofO');

INSERT INTO system.setting(
            name, vl, active, description)
    VALUES ('percStampDuty', '0.0003', true, 'fee/tax percentage of the Improvement Premium');


-- Sequence: administrative.cofo_nr_seq

--DROP SEQUENCE administrative.cofo_nr_seq;

CREATE SEQUENCE administrative.cofo_nr_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9999
  START 509
  CACHE 1
  CYCLE;
ALTER TABLE administrative.cofo_nr_seq
  OWNER TO postgres;
COMMENT ON SEQUENCE administrative.cofo_nr_seq
  IS 'Sequence number used as the basis for the CofO numbering. This sequence is used by the generate-cofo-nr business rule.';


delete from system.br_definition where br_id = 'generate-cofo-nr';
delete from system.br where id = 'generate-cofo-nr';
INSERT INTO system.br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-cofo-nr', 'generate-cofo-nr', 'sql', '...::::::::...::::::::::::::::...::::::::...', NULL, '');
INSERT INTO system.br_definition (br_id, active_from, active_until, body) VALUES ('generate-cofo-nr', '2014-02-20', 'infinity', 'SELECT coalesce(system.get_setting(''system-id''), '''') || to_char(now(), ''yymm'') || trim(to_char(nextval(''administrative.cofo_nr_seq''), ''0000'')) AS vl');
    





-----------  BR FOR GROUND RENT -----------------------

UPDATE cadastre.land_use_type
   SET display_value='COMMERCIAL'
 WHERE code = 'bus_commercial';

 UPDATE cadastre.land_use_type
   SET display_value='AGRICULTURAL'
 WHERE code = 'bus_agric';


 UPDATE cadastre.land_use_type
   SET display_value='INDUSTRIAL'
 WHERE code = 'bus_industrial';




-------------------------------------------------------------------------
delete from system.br_definition where br_id =  'generate_ground_rent';
delete from system.br  where id= 'generate_ground_rent';

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('generate_ground_rent', 'sql', 
'ground rent for the property',
'generates the grount rent for a property');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('generate_ground_rent', now(), 'infinity', 
'SELECT 	CASE 	WHEN (SELECT (landuse like ''%RESIDENTIAL%'')and (name like ''%AWKA%'') and (estate = ''P'')) THEN  200*size 
         	WHEN (SELECT (landuse like ''%COMMERCIAL%'')and (name like ''%AWKA%'') and (estate = ''P'')) THEN  400*size
         	WHEN (SELECT (landuse like ''%INDUSTRIAL%'')and (name like ''%AWKA%'') and (estate = ''P'')) THEN  150*size
         	WHEN (SELECT (landuse like ''%AGRICULTURAL%'')and (name like ''%AWKA%'') and (estate = ''P'')) THEN  25*size 

                WHEN (SELECT (landuse like ''%RESIDENTIAL%'')and (name like ''%ONITSHA%'') and (estate = ''P'')) THEN  350*size 
         	WHEN (SELECT (landuse like ''%COMMERCIAL%'')and (name like ''%ONITSHA%'') and (estate = ''P'')) THEN  500*size
         	WHEN (SELECT (landuse like ''%INDUSTRIAL%'')and (name like ''%ONITSHA%'') and (estate = ''P'')) THEN  250*size
         	WHEN (SELECT (landuse like ''%AGRICULTURAL%'')and (name like ''%ONITSHA%'') and (estate = ''P'')) THEN  25*size

         	WHEN (SELECT (landuse like ''%RESIDENTIAL%'')and (name like ''%NNEWI%'') and (estate = ''P'')) THEN  200*size 
         	WHEN (SELECT (landuse like ''%COMMERCIAL%'')and (name like ''%NNEWI%'') and (estate = ''P'')) THEN  400*size
         	WHEN (SELECT (landuse like ''%industrial%'')and (name like ''%NNEWI%'') and (estate = ''P'')) THEN  250*size
         	WHEN (SELECT (landuse like ''%agric%'')and (name like ''%NNEWI%'') and (estate = ''P'')) THEN  25*size

         	WHEN (SELECT (landuse like ''%RESIDENTIAL%'')and (name like ''%AWKA%'') and (estate = ''G'')) THEN  400*size 
         	WHEN (SELECT (landuse like ''%COMMERCIAL%'')and (name like ''%AWKA%'') and (estate = ''G'')) THEN  800*size
         	WHEN (SELECT (landuse like ''%INDUSTRIAL%'')and (name like ''%AWKA%'') and (estate = ''G'')) THEN  300*size
         	WHEN (SELECT (landuse like ''%AGRICULTURAL%'')and (name like ''%AWKA%'') and (estate = ''G'')) THEN  50*size 

                WHEN (SELECT (landuse like ''%RESIDENTIAL%'')and (name like ''%ONITSHA%'') and (estate = ''G'')) THEN  700*size 
         	WHEN (SELECT (landuse like ''%COMMERCIAL%'')and (name like ''%ONITSHA%'') and (estate = ''G'')) THEN  1000*size
         	WHEN (SELECT (landuse like ''%INDUSTRIAL%'')and (name like ''%ONITSHA%'') and (estate = ''G'')) THEN  500*size
         	WHEN (SELECT (landuse like ''%AGRICULTURAL%'')and (name like ''%ONITSHA%'') and (estate = ''G'')) THEN  50*size

         	WHEN (SELECT (landuse like ''%RESIDENTIAL%'')and (name like ''%NNEWI%'') and (estate = ''G'')) THEN  400*size 
         	WHEN (SELECT (landuse like ''%COMMERCIAL%'')and (name like ''%NNEWI%'') and (estate = ''G'')) THEN  800*size
         	WHEN (SELECT (landuse like ''%industrial%'')and (name like ''%NNEWI%'') and (estate = ''G'')) THEN  500*size
         	WHEN (SELECT (landuse like ''%agric%'')and (name like ''%NNEWI%'') and (estate = ''G'')) THEN  50*size
         	
		ELSE 0
	END AS vl
FROM application.systematic_registration_certificates 
WHERE ba_unit_id = #{id}
');

-------------  FUNCTION  FOR GROUND RENT ---------------
DROP FUNCTION application.ground_rent(character varying);

CREATE OR REPLACE FUNCTION application.ground_rent(buid character varying)
  RETURNS numeric AS
$BODY$
declare
 rec record;
 tmp_ground_rent numeric;
  sqlSt varchar;
 resultFound boolean;
 buidTmp character varying;
 
begin

  buidTmp = '''||'||buid||'||''';
          SELECT  body
          into sqlSt
          FROM system.br_current WHERE (id = 'generate_ground_rent') ;


          sqlSt =  replace (sqlSt, '#{id}',''||buidTmp||'');
          sqlSt =  replace (sqlSt, '||','');
   

    resultFound = false;

    -- Loop through results
    
    FOR rec in EXECUTE sqlSt loop

      tmp_ground_rent:= rec.vl;

                 
     --   FOR SAVING THE GROUND_RENT IN THE PROPERTY TABLE
            
          update administrative.ba_unit
          set ground_rent = tmp_ground_rent
          where id = buid
          ;
           
          return tmp_ground_rent;
          resultFound = true;
    end loop;
   
    if (not resultFound) then
        RAISE EXCEPTION 'no_result_found';
    end if;
    return tmp_ground_rent;
END;
$BODY$

  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application.ground_rent(character varying) OWNER TO postgres;
COMMENT ON FUNCTION application.ground_rent(character varying) IS 'This function generates the ground rent for teh property.
It has to be overridden to apply the algorithm specific to the situation.';

