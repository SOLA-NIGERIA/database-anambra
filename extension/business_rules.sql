----br 'public-display-check-complete-status'
update  system.br_definition
set  body = 'select
(select count(*)
FROM administrative.systematic_registration_listing WHERE (name = #{lastPart}) 
)*100/
(select count(*)
from 
cadastre.cadastre_object co,
cadastre.spatial_unit_group sg
where  ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
and sg.name = #{lastPart}
) > 90 as vl'
where br_id = 'public-display-check-complete-status';





----br_generator for administrative.title_nr_seq ------------------------------------------------------------------------------------------------
delete from system.br_definition  where br_id= 'generate-title-nr';
delete from system.br  where id= 'generate-title-nr';

insert into system.br(id, technical_type_code) values('generate-title-nr', 'sql');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('generate-title-nr', now(), 'infinity', 
'SELECT ''AN '' || trim(to_char(nextval(''administrative.title_nr_seq''), ''0000000000'')) AS vl;
');




-- BR for not Approving a Systematic Registration Claim if there has not been a public display

delete from system.br_validation where br_id= 'application-on-approve-check-systematic-reg-no-pubdisp';
delete from system.br_definition  where br_id= 'application-on-approve-check-systematic-reg-no-pubdisp';
delete from system.br  where id= 'application-on-approve-check-systematic-reg-no-pubdisp';

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('application-on-approve-check-systematic-reg-no-pubdisp', 'sql', 'There must have been a public display for the Systematic Registration Claim',
'Checks the absence of dispute for systematic registration service related to the application');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('application-on-approve-check-systematic-reg-no-pubdisp', now(), 'infinity', 
'  SELECT
(Select count (*)
FROM  application.application aa,
			  application.service s,
			  application.application_property ap
			    WHERE s.application_id = aa.id
			    AND   s.request_type_code::text =  ''systematicRegn''::text
                            AND   aa.id::text = ap.application_id::text
                            AND  aa.id = #{id}
) -	
(Select count(*)
FROM  application.application aa,
			  application.service s,
			  application.application_property ap
			    WHERE s.application_id = aa.id
			    AND   s.request_type_code::text = ''systematicRegn''::text
			    AND   aa.id::text = ap.application_id::text
			    AND ap.name_lastpart in 
                            ( select co.name_lastpart 
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg
                              where ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                               
                            ) 
			    AND ap.name_lastpart in (select co.name_lastpart 
                              from cadastre.cadastre_object co, cadastre.spatial_unit_group sg
                              where ST_Intersects(ST_PointOnSurface(co.geom_polygon), sg.geom)
                              and sg.name in( 
		                             select ss.reference_nr 
									from   source.source ss 
									where ss.type_code=''publicNotification''
									 )
                                             )     

       and  aa.id = #{id}) = 0  AS vl;');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-on-approve-check-systematic-reg-no-pubdisp', 'application', 'approve', 'critical', 603);

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-on-approve-check-systematic-reg-no-pubdisp', 'application', 'validate', 'critical', 602);




-- BR for not Approving a Systematic Registration Claim if there is a Dispute on the same parcel

delete from system.br_validation where br_id= 'application-on-approve-check-systematic-reg-no-dispute';
delete from system.br_definition  where br_id= 'application-on-approve-check-systematic-reg-no-dispute';
delete from system.br  where id= 'application-on-approve-check-systematic-reg-no-dispute';

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('application-on-approve-check-systematic-reg-no-dispute', 'sql', 'There must be no dispute on the same parcel of the Systematic Registration Claim',
'Checks the absence of dispute for systematic registration service related to the application');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('application-on-approve-check-systematic-reg-no-dispute', now(), 'infinity', 
'  SELECT (COUNT(*) = 0)  AS vl
FROM  application.application aasr,
      application.application aad,
      application.application_property apsr,
      application.application_property apd,  
      application.service ssr,
      application.service sd
  WHERE  ssr.application_id::text = aasr.id::text 
  AND    ssr.request_type_code::text = ''systematicRegn''::text
  AND    sd.application_id::text = aad.id::text 
  AND    sd.request_type_code::text = ''dispute''::text
  AND    (sd.status_code::text != ''cancelled''::text AND (aad.status_code != ''annulled''))
  AND    apsr.application_id = aasr.id
  AND    apd.application_id = aad.id
  AND    apsr.name_firstpart||apsr.name_lastpart = apd.name_firstpart||apd.name_lastpart
  AND    aasr.id::text = #{id};');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-on-approve-check-systematic-reg-no-dispute', 'application', 'approve', 'critical', 601);

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-on-approve-check-systematic-reg-no-dispute', 'application', 'validate', 'critical', 600);

--- BR for not being allowed to create a new parcel which overlaps with existing ones
delete from system.br_validation where br_id ='new-co-must-not-overlap-with-existing';
delete from system.br_definition where br_id ='new-co-must-not-overlap-with-existing';
delete from system.br where id ='new-co-must-not-overlap-with-existing';

insert into system.br(id, technical_type_code, feedback, technical_description) 
values('new-co-must-not-overlap-with-existing', 'sql', 
    'New polygons must not overlap with existing ones',
 '');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('new-co-must-not-overlap-with-existing', now(), 'infinity', 
'WITH tolerance AS (SELECT CAST(ABS(LOG((CAST (vl AS NUMERIC)^2))) AS INT) AS area FROM system.setting where name = ''map-tolerance'' LIMIT 1)

SELECT COALESCE(ROUND(CAST (ST_AREA(ST_UNION(co.geom_polygon))AS NUMERIC), (SELECT area FROM tolerance)) = 
		ROUND(CAST(SUM(ST_AREA(co.geom_polygon))AS NUMERIC), (SELECT area FROM tolerance)), 
		TRUE) AS vl
FROM cadastre.cadastre_object co  
');

INSERT INTO system.br_validation(br_id, target_code, target_reg_moment, target_request_type_code, severity_code, order_of_execution)
VALUES ('new-co-must-not-overlap-with-existing', 'cadastre_object', 'current', 'cadastreChange', 'critical', 115);

INSERT INTO system.br_validation(br_id, target_code, target_reg_moment, target_request_type_code, severity_code, order_of_execution)
VALUES ('new-co-must-not-overlap-with-existing', 'cadastre_object', 'pending', 'cadastreChange', 'critical', 425);

-----------------------------------------------------------------------------------------------------------
--LH # 14 DISABLE
--target-ba_unit-check-if-pending
--target-parcels-check-isapolygon
--target-parcels-check-nopending

-- other br disabled for first registration
--target-parcels-present
--target-and-new-union-the-same
--service-has-person-verification
update system.br_validation set target_application_moment  = null, target_service_moment = null, target_reg_moment = null where br_id='target-ba_unit-check-if-pending';
update system.br_validation set target_application_moment  = null, target_service_moment = null, target_reg_moment = null where br_id='target-parcels-check-isapolygon';
update system.br_validation set target_application_moment  = null, target_service_moment = null, target_reg_moment = null where br_id='target-parcels-check-nopending';
update system.br_validation set target_application_moment  = null, target_service_moment = null, target_reg_moment = null where br_id='target-parcels-present';
update system.br_validation set target_application_moment  = null, target_service_moment = null, target_reg_moment = null where br_id='target-and-new-union-the-same';
update system.br_validation set target_application_moment  = null, target_service_moment = null, target_reg_moment = null where br_id='service-has-person-verification';

--documents-present  this has to update the logic and enabled again 
update system.br_validation set target_application_moment  = null, target_service_moment = null, target_reg_moment = null where br_id='documents-present';

--LH # 15
--CHANGE cadastre-object-check-name for NIGERIA UPI Standard

CREATE OR REPLACE FUNCTION cadastre.cadastre_object_name_is_valid(name_firstpart character varying, name_lastpart character varying)
  RETURNS boolean AS
$BODY$

  
BEGIN
 if name_firstpart is null then return false; end if;
  if name_lastpart is null then return false; end if;
  if not (name_firstpart similar to 'NC[0-9]+' or name_firstpart similar to '[0-9]+') then return false;  end if;
  
  if name_lastpart not in (select sg.name 
			   from cadastre.spatial_unit_group sg
		           where  sg.hierarchy_level = 3) then return false;  end if;

  return true;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION cadastre.cadastre_object_name_is_valid(character varying, character varying) OWNER TO postgres;

-----------  BR FOR GROUND RENT -----------------------
----------------------------------------------------------------------------------------------------
delete from system.br_definition where br_id =  'generate_ground_rent';
delete from system.br  where id= 'generate_ground_rent';

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('generate_ground_rent', 'sql', 
'ground rent for the property',
'generates the grount rent for a property');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('generate_ground_rent', now(), 'infinity', 
'SELECT 
 CASE 	WHEN (substr(bu.land_use_code, 1, 3) = ''res'') THEN 0 
	WHEN (substr(bu.land_use_code, 1, 3) = ''bus'') THEN 0
	ELSE 0
	END AS vl
FROM administrative.ba_unit bu 
WHERE bu.id = #{id}
');

-------------  FUNCTION  FOR GROUND RENT ---------------
--DROP FUNCTION application.ground_rent(character varying);

CREATE OR REPLACE FUNCTION application.ground_rent(nr character varying)
  RETURNS numeric AS
$BODY$
declare
 rec record;
 ground_rent numeric;
  sqlSt varchar;
 resultFound boolean;
 nrTmp character varying;
 
begin

  nrTmp = '''||'||nr||'||''';
          SELECT  body
          into sqlSt
          FROM system.br_current WHERE (id = 'generate_ground_rent') ;


          sqlSt =  replace (sqlSt, '#{id}',''||nrTmp||'');
          sqlSt =  replace (sqlSt, '||','');
   

    resultFound = false;

    -- Loop through results
    
    FOR rec in EXECUTE sqlSt loop

      ground_rent:= rec.vl;

                 
     --   FOR SAVING THE GROUND_RENT IN THE PROPERTY TABLE
            
     --     update <TABLE>
     --     set ground_rent = ground_rent
     --     where property = rec.property
     --     ;
           
          return ground_rent;
          resultFound = true;
    end loop;
   
    if (not resultFound) then
        RAISE EXCEPTION 'no_result_found';
    end if;
    return ground_rent;
END;
$BODY$

  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION application.ground_rent(character varying) OWNER TO postgres;
COMMENT ON FUNCTION application.ground_rent(character varying) IS 'This function generates the ground rent for teh property.
It has to be overridden to apply the algorithm specific to the situation.';

