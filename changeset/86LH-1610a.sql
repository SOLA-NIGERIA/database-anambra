﻿--Add BR to be applied on approval of SLTR Claim Application that checks that the following fields are populated : Estate, Area, Purpose, Date Commenced, term

--- stamp duty
-- Function: administrative.get_stampDuty(character varying)
-- DROP FUNCTION administrative.get_stampDuty(character varying);
  
CREATE OR REPLACE FUNCTION administrative.get_stampDuty(inputid character varying)
  RETURNS numeric AS
$BODY$
declare
  rec record;
  returnValue numeric ;
  --integer;
   
BEGIN

returnValue = 0;
 											
 
select
 CASE 	WHEN (rrr.rot_code = 'P') THEN ltr.rent_non_state_land * round(sa.size)
	WHEN (rrr.rot_code = 'G') THEN ltr.rent_state_land *round(sa.size)
		ELSE  	0
 END 	 										      
into returnValue
FROM
 cadastre.lga_tarrif_rate ltr, 
 cadastre.spatial_value_area sa, 
 administrative.rrr rrr,
 administrative.ba_unit bu, 
 cadastre.land_use_type lu, 
 administrative.ba_unit_contains_spatial_unit su,
 cadastre.cadastre_object co
WHERE
bu.id::text = rrr.ba_unit_id::text
AND bu.id::text = su.ba_unit_id::text 
AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
AND co.id::text = sa.spatial_unit_id::text 
AND COALESCE(bu.land_use_code, 'res_home'::character varying)::text = lu.code::text
AND lu.tarrif_code = ltr.tarrif_type
AND is_primary
AND ltr.sug_id = "substring"(bu.name_lastpart::text,0, "position"("substring"(bu.name_lastpart::text, "position"(bu.name_lastpart::text, '/'::text)+1), '/'::text)+"position"(bu.name_lastpart::text, '/'::text))
AND sa.type_code::text = 'officialArea'::text 
AND rrr.ba_unit_id = inputid;


	
return returnValue;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION administrative.get_stampDuty(character varying)
  OWNER TO postgres;



-- yearly rent
  
-- Function: administrative.get_yearlyRent(character varying)
-- DROP FUNCTION administrative.get_yearlyRent(character varying);
  
CREATE OR REPLACE FUNCTION administrative.get_yearlyRent(inputid character varying)
  RETURNS numeric AS
$BODY$
declare
  rec record;
  returnValue numeric ;
  --integer;
   
BEGIN

returnValue = 0;
 											
 
select
CASE WHEN (SELECT (tarrif_type = 'residential') AND ( ( SELECT lga.label
           FROM cadastre.spatial_unit_group lga
          WHERE lga.hierarchy_level = 2 AND co.name_lastpart::text ~~ (lga.name::text || '/%'::text)) = 'AN/AWKA SOUTH')) THEN  5 * size 
			WHEN (SELECT (tarrif_type = 'commercial') AND ( ( SELECT lga.label
           FROM cadastre.spatial_unit_group lga
          WHERE lga.hierarchy_level = 2 AND co.name_lastpart::text ~~ (lga.name::text || '/%'::text)) = 'AN/AWKA SOUTH')) THEN  5 * size 
			WHEN (SELECT (tarrif_type = 'industrial') AND ( ( SELECT lga.label
           FROM cadastre.spatial_unit_group lga
          WHERE lga.hierarchy_level = 2 AND co.name_lastpart::text ~~ (lga.name::text || '/%'::text)) = 'AN/AWKA SOUTH')) THEN  5 * size 
			WHEN (SELECT (tarrif_type = 'agricultural') AND ( ( SELECT lga.label
           FROM cadastre.spatial_unit_group lga
          WHERE lga.hierarchy_level = 2 AND co.name_lastpart::text ~~ (lga.name::text || '/%'::text)) = 'AN/AWKA SOUTH')) THEN  5 * size
			WHEN (SELECT (tarrif_type = 'zero')) THEN  0      	
			ELSE 5 * size 
END										      
into returnValue
FROM
 cadastre.lga_tarrif_rate ltr, 
 cadastre.spatial_value_area sa, 
 administrative.rrr rrr,
 administrative.ba_unit bu, 
 cadastre.land_use_type lu, 
 administrative.ba_unit_contains_spatial_unit su,
 cadastre.cadastre_object co
WHERE
bu.id::text = rrr.ba_unit_id::text
AND bu.id::text = su.ba_unit_id::text 
AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
AND co.id::text = sa.spatial_unit_id::text 
AND COALESCE(bu.land_use_code, 'res_home'::character varying)::text = lu.code::text
AND lu.tarrif_code = ltr.tarrif_type
AND is_primary
AND ltr.sug_id = "substring"(bu.name_lastpart::text,0, "position"("substring"(bu.name_lastpart::text, "position"(bu.name_lastpart::text, '/'::text)+1), '/'::text)+"position"(bu.name_lastpart::text, '/'::text))
AND sa.type_code::text = 'officialArea'::text 
AND rrr.ba_unit_id = inputid;


	
return returnValue;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION administrative.get_yearlyRent(character varying)
  OWNER TO postgres;


--- dispute transaction to be saved when the service is started
ALTER TABLE administrative.dispute
  ADD COLUMN transaction_id character varying(40);
ALTER TABLE administrative.dispute_historic
  ADD COLUMN transaction_id character varying(40);