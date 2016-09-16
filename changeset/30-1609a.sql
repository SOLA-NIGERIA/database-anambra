-- Function: administrative.get_improvementPremium(character varying)
--select administrative.get_improvementPremium('8be78a84-3eb8-4968-a259-910bddc29c54');
-- DROP FUNCTION administrative.get_improvementPremium(character varying);
  
CREATE OR REPLACE FUNCTION administrative.get_improvementPremium(inputid character varying)
  RETURNS character varying AS
$BODY$
declare
  rec record;
  returnValue character varying ;
  --integer;
   
BEGIN

returnValue = 0;

 
select
 CASE 	WHEN (rrr.rot_code = 'P') THEN ltr.premium_non_state_land
	WHEN (rrr.rot_code = 'G') THEN ltr.premium_state_land
		ELSE  	0
 END 	 										      
into returnValue
FROM
 cadastre.lga_tarrif_rate ltr,  
 administrative.rrr rrr,
 administrative.ba_unit bu, 
 cadastre.land_use_type lu
WHERE
bu.id::text = rrr.ba_unit_id::text
AND COALESCE(bu.land_use_code, 'res_home'::character varying)::text = lu.code::text
AND lu.tarrif_code = ltr.tarrif_type
AND is_primary
AND ltr.sug_id = "substring"(bu.name_lastpart::text,0, "position"("substring"(bu.name_lastpart::text, "position"(bu.name_lastpart::text, '/'::text)+1), '/'::text)+"position"(bu.name_lastpart::text, '/'::text))
AND rrr.ba_unit_id = inputid;


	
return returnValue;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION administrative.get_improvementPremium(character varying)
  OWNER TO postgres;
