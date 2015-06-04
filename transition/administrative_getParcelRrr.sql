
-- Function: administrative.get_parcel_rrr(character varying)

-- DROP FUNCTION administrative.get_parcel_rrr(character varying);

CREATE OR REPLACE FUNCTION administrative.get_parcel_rrr(baunit_id character varying)
  RETURNS character varying AS
$BODY$
declare
  rec record;
  rrr character varying;
  
BEGIN
  rrr = '';
   
	for rec in 
              select distinct (rrrt.display_value)  as value
              from party.party pp,
		     administrative.party_for_rrr  pr,
		     administrative.rrr rrr,
		     administrative.rrr_share  rrrsh,
		     administrative.rrr_type  rrrt
		where pp.id=pr.party_id
		and   pr.rrr_id=rrr.id
		and rrrsh.id = pr.share_id
		AND rrr.type_code = rrrt.code
		and   rrr.ba_unit_id= baunit_id
	loop
           rrr = rrr || ', ' || rec.value;
	end loop;

        if rrr = '' then
	  rrr = 'No Other rrr claimed ';
       end if;

	if substr(rrr, 1, 1) = ',' then
          rrr = substr(rrr,2);
        end if;
return rrr;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION administrative.get_parcel_rrr(character varying) OWNER TO postgres;