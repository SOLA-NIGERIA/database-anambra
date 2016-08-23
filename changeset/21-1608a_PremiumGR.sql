
-----------  BR FOR GROUND RENT -----------------------
-------------------------------------------------------------------------
delete from system.br_definition where br_id =  'generate_ground_rent';
delete from system.br  where id= 'generate_ground_rent';

INSERT INTO system.br(id, technical_type_code, feedback, technical_description) 
VALUES('generate_ground_rent', 'sql', 
'ground rent for the property',
'generates the grount rent for a property');

INSERT INTO system.br_definition(br_id, active_from, active_until, body) 
VALUES('generate_ground_rent', now(), 'infinity', 
'SELECT 	CASE 	WHEN (SELECT (landuse like ''%res_%'')and (name like ''%AWKA%'')) THEN  200*size 
         	WHEN (SELECT (landuse like ''%commercial%'')and (name like ''%AWKA%'')) THEN  400*size
         	WHEN (SELECT (landuse like ''%industrial%'')and (name like ''%AWKA%'')) THEN  150*size
         	WHEN (SELECT (landuse like ''%agric%'')and (name like ''%AWKA%'')) THEN  25*size 

                WHEN (SELECT (landuse like ''%res_%'')and (name like ''%ONITSHA%'')) THEN  350*size 
         	WHEN (SELECT (landuse like ''%commercial%'')and (name like ''%ONITSHA%'')) THEN  500*size
         	WHEN (SELECT (landuse like ''%industrial%'')and (name like ''%ONITSHA%'')) THEN  250*size
         	WHEN (SELECT (landuse like ''%agric%'')and (name like ''%ONITSHA%'')) THEN  25*size

         	WHEN (SELECT (landuse like ''%res_%'')and (name like ''%NNEWI%'')) THEN  200*size 
         	WHEN (SELECT (landuse like ''%commercial%'')and (name like ''%NNEWI%'')) THEN  400*size
         	WHEN (SELECT (landuse like ''%industrial%'')and (name like ''%NNEWI%'')) THEN  250*size
         	WHEN (SELECT (landuse like ''%agric%'')and (name like ''%NNEWI%'')) THEN  25*size
         	
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

