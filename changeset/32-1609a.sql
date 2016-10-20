-- create new fields in administrative.rrr table including historic (yearly_rent, improvement_premium and stamp_duty)
DROP VIEW IF EXISTS application.systematic_registration_certificates;

ALTER TABLE administrative.rrr DROP Column IF EXISTS yearly_rent;
ALTER TABLE administrative.rrr ADD Column yearly_rent numeric(19,0);
ALTER TABLE administrative.rrr_historic DROP Column IF EXISTS yearly_rent;
ALTER TABLE administrative.rrr_historic ADD Column yearly_rent numeric(19,0);

ALTER TABLE administrative.rrr DROP Column IF EXISTS improvement_premium;
ALTER TABLE administrative.rrr ADD Column improvement_premium numeric(19,0);
ALTER TABLE administrative.rrr_historic DROP Column IF EXISTS improvement_premium;
ALTER TABLE administrative.rrr_historic ADD Column improvement_premium numeric(19,0);

ALTER TABLE administrative.rrr DROP Column IF EXISTS stamp_duty;
ALTER TABLE administrative.rrr ADD Column stamp_duty numeric(19,0);
ALTER TABLE administrative.rrr_historic DROP Column IF EXISTS stamp_duty;
ALTER TABLE administrative.rrr_historic ADD Column stamp_duty numeric(19,0);


--modification to View application.systematic_registration_certificates to add new and revised fields (improvement_premium, yearly_rent and stamp_duty)

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
    rrr.improvement_premium AS premium,
    rrr.stamp_duty AS stamp_duty,
    rrr.rot_code AS estate,
    ltr.tarrif_type AS tarrif_type
--    ltr.premium_state_land,
--    ltr.premium_non_state_land AS premium_non_state,
--        CASE
--            WHEN rrr.rot_code::text = 'P'::text THEN ltr.rent_non_state_land::numeric * sa.size
--            WHEN rrr.rot_code::text = 'G'::text THEN ltr.rent_state_land::numeric * sa.size
--            ELSE 0::numeric
--        END AS stamp_duty
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

--correction to interim BR to calculate annual rent, improvement premium and stamp duty

DELETE FROM system.br WHERE id ='generate-rent';
INSERT INTO system.br VALUES ('generate-rent', 'generate-rent', 'sql', 'calculates the annual rent for the property', NULL, 'calculates the annual rent for a property');

DELETE FROM system.br_definition WHERE br_id ='generate-rent';
INSERT INTO system.br_definition VALUES ('generate-rent', '2016-09-04', 'infinity', 
	'SELECT CASE 	WHEN (SELECT (tarrif_type = ''residential'') AND (propLocation = ''Awka South'')) THEN  5 * size 
			WHEN (SELECT (tarrif_type = ''commercial'') AND (propLocation = ''Awka South'')) THEN  5 * size 
			WHEN (SELECT (tarrif_type = ''industrial'') AND (propLocation = ''Awka South'')) THEN  5 * size 
			WHEN (SELECT (tarrif_type = ''agricultural'') AND (propLocation = ''Awka South'')) THEN  5 * size
			WHEN (SELECT (tarrif_type = ''zero'')) THEN  0      	
			ELSE 5 * size
	END AS vl
FROM application.systematic_registration_certificates 
WHERE ba_unit_id = #{id}
');

DELETE FROM system.br WHERE id ='generate-premium';
INSERT INTO system.br VALUES ('generate-premium', 'generate-premium', 'sql', 'calculates the improvement premium for the property', NULL, 'calculates the improvement premium for a property');

DELETE FROM system.br_definition WHERE br_id ='generate-premium';
INSERT INTO system.br_definition VALUES ('generate-premium', '2016-09-04', 'infinity', 
	'SELECT CASE 	WHEN (SELECT (tarrif_type = ''residential'') AND (propLocation = ''Awka South'') AND (estate = ''P'')) THEN  200 * size 
			WHEN (SELECT (tarrif_type = ''commercial'') AND (propLocation = ''Awka South'') AND (estate = ''P'')) THEN  400 * size 
			WHEN (SELECT (tarrif_type = ''industrial'') AND (propLocation = ''Awka South'') AND (estate = ''P'')) THEN  150 * size 
			WHEN (SELECT (tarrif_type = ''agricultural'') AND (propLocation = ''Awka South'') AND (estate = ''P'')) THEN  25 * size
			WHEN (SELECT (tarrif_type = ''residential'') AND (propLocation = ''Awka South'') AND (estate = ''G'')) THEN  400 * size 
			WHEN (SELECT (tarrif_type = ''commercial'') AND (propLocation = ''Awka South'') AND (estate = ''G'')) THEN  800 * size 
			WHEN (SELECT (tarrif_type = ''industrial'') AND (propLocation = ''Awka South'') AND (estate = ''G'')) THEN  300 * size 
			WHEN (SELECT (tarrif_type = ''agricultural'') AND (propLocation = ''Awka South'') AND (estate = ''G'')) THEN  50 * size
			WHEN (SELECT (tarrif_type = ''zero'')) THEN  0      	
			ELSE 400 * size
	END AS vl
FROM application.systematic_registration_certificates 
WHERE ba_unit_id = #{id}
');


DELETE FROM system.br WHERE id ='generate-stamp-duty';
INSERT INTO system.br VALUES ('generate-stamp-duty', 'generate-stamp-duty', 'sql', 'Calculates the stamp duty for the registration of the Certificate of Occupancy', NULL, 'Calculates the stamp duty for the registration of the Certificate of Occupancy');

DELETE FROM system.br_definition WHERE br_id ='generate-stamp-duty';
INSERT INTO system.br_definition VALUES ('generate-stamp-duty', '2016-09-04', 'infinity', 
	'SELECT CASE 	WHEN (SELECT (tarrif_type = ''residential'') AND (propLocation = ''Awka South'') AND (estate = ''P'')) THEN  200 * size 
			WHEN (SELECT (tarrif_type = ''commercial'') AND (propLocation = ''Awka South'') AND (estate = ''P'')) THEN  400 * size * 0.0003
			WHEN (SELECT (tarrif_type = ''industrial'') AND (propLocation = ''Awka South'') AND (estate = ''P'')) THEN  150 * size * 0.0003 
			WHEN (SELECT (tarrif_type = ''agricultural'') AND (propLocation = ''Awka South'') AND (estate = ''P'')) THEN  25 * size * 0.0003
			WHEN (SELECT (tarrif_type = ''residential'') AND (propLocation = ''Awka South'') AND (estate = ''G'')) THEN  400 * size * 0.0003 
			WHEN (SELECT (tarrif_type = ''commercial'') AND (propLocation = ''Awka South'') AND (estate = ''G'')) THEN  800 * size * 0.0003 
			WHEN (SELECT (tarrif_type = ''industrial'') AND (propLocation = ''Awka South'') AND (estate = ''G'')) THEN  300 * size * 0.0003 
			WHEN (SELECT (tarrif_type = ''agricultural'') AND (propLocation = ''Awka South'') AND (estate = ''G'')) THEN  50 * size * 0.0003
			WHEN (SELECT (tarrif_type = ''zero'')) THEN  0      	
			ELSE 400 * size * 0.0003
	END AS vl
FROM application.systematic_registration_certificates 
WHERE ba_unit_id = #{id}
');

-- add functions so as to utilise BR for generating values for annual rent, improvement premium and stamp duty fields (in adminstrative.rrr)
DROP FUNCTION IF EXISTS administrative.get_yearly_rent(buid character varying);

CREATE OR REPLACE FUNCTION administrative.get_yearly_rent(buid character varying)
  RETURNS numeric AS
$BODY$
DECLARE
	rec record;
	tmp_yearly_rent numeric;
	sqlSt varchar;
	resultFound boolean;
	buidTmp character varying;
 
BEGIN
	buidTmp = '''||'||buid||'||''';
          SELECT  body
          into sqlSt
          FROM system.br_current WHERE (id = 'generate-rent') ;

          sqlSt =  replace (sqlSt, '#{id}',''||buidTmp||'');
          sqlSt =  replace (sqlSt, '||','');
   
	resultFound = false;
    -- Loop through results  
    FOR rec in EXECUTE sqlSt LOOP
	tmp_yearly_rent:= rec.vl;       
     --   FOR SAVING THE yearly_rent IN THE rrr TABLE           
        UPDATE administrative.rrr
        SET yearly_rent = tmp_yearly_rent
        WHERE ba_unit_id = buid
        ;          
        return tmp_yearly_rent;
        resultFound = true;
    END LOOP;
   
    if (not resultFound) then
        RAISE EXCEPTION 'no_result_found';
    end if;
    RETURN tmp_yearly_rent;
END;
$BODY$

  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION administrative.get_yearly_rent(character varying) OWNER TO postgres;
COMMENT ON FUNCTION administrative.get_yearly_rent(character varying) IS 'This function generates the yearly rent for the property.
It has to be overridden to apply the business rule algorithm specific to calculating the yearly rent.';

DROP FUNCTION IF EXISTS administrative.get_improvement_premium(buid character varying);

CREATE OR REPLACE FUNCTION administrative.get_improvement_premium(buid character varying)
  RETURNS numeric AS
$BODY$
DECLARE
	rec record;
	tmp_premium numeric;
	sqlSt varchar;
	resultFound boolean;
	buidTmp character varying;
 
BEGIN
	buidTmp = '''||'||buid||'||''';
          SELECT  body
          into sqlSt
          FROM system.br_current WHERE (id = 'generate-premium') ;

          sqlSt =  replace (sqlSt, '#{id}',''||buidTmp||'');
          sqlSt =  replace (sqlSt, '||','');
   
	resultFound = false;
    -- Loop through results  
    FOR rec in EXECUTE sqlSt LOOP
	tmp_premium:= rec.vl;       
     --   FOR SAVING THE yearly_rent IN THE rrr TABLE           
        UPDATE administrative.rrr
        SET improvement_premium = tmp_premium
        WHERE ba_unit_id = buid
        ;          
        return tmp_premium;
        resultFound = true;
    END LOOP;
   
    if (not resultFound) then
        RAISE EXCEPTION 'no_result_found';
    end if;
    RETURN tmp_premium;
END;
$BODY$

  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION administrative.get_improvement_premium(character varying) OWNER TO postgres;
COMMENT ON FUNCTION administrative.get_improvement_premium(character varying) IS 'This function generates the improvement premium for the property.
It has to be overridden to apply the business rule algorithm specific to calculating the improvement premium.';

DROP FUNCTION IF EXISTS administrative.get_stamp_duty(buid character varying);

CREATE OR REPLACE FUNCTION administrative.get_stamp_duty(buid character varying)
  RETURNS numeric AS
$BODY$
DECLARE
	rec record;
	tmp_stamp_duty numeric;
	sqlSt varchar;
	resultFound boolean;
	buidTmp character varying;
 
BEGIN
	buidTmp = '''||'||buid||'||''';
          SELECT  body
          into sqlSt
          FROM system.br_current WHERE (id = 'generate-stamp-duty') ;

          sqlSt =  replace (sqlSt, '#{id}',''||buidTmp||'');
          sqlSt =  replace (sqlSt, '||','');
   
	resultFound = false;
    -- Loop through results  
    FOR rec in EXECUTE sqlSt LOOP
	tmp_stamp_duty:= rec.vl;       
     --   FOR SAVING THE yearly_rent IN THE rrr TABLE           
        UPDATE administrative.rrr
        SET stamp_duty = tmp_stamp_duty
        WHERE ba_unit_id = buid
        ;          
        return tmp_stamp_duty;
        resultFound = true;
    END LOOP;
   
    if (not resultFound) then
        RAISE EXCEPTION 'no_result_found';
    end if;
    RETURN tmp_stamp_duty;
END;
$BODY$

  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION administrative.get_stamp_duty(character varying) OWNER TO postgres;
COMMENT ON FUNCTION administrative.get_stamp_duty(character varying) IS 'This function generates the stamp duty for the CofO registration.
It has to be overridden to apply the business rule algorithm specific to calculating the stamp duty.';

--delete any database functions and BR made redundant by these changes
--TO BE DONE

--modify system settings for Awka SLTR Pilot
DELETE FROM system.setting WHERE name ='surveyor';
INSERT INTO system.setting VALUES ('surveyor', 'Surv Chux Nzomiwu', true, 'Name of Surveyor');

DELETE FROM system.setting WHERE name ='surveyorRank';
INSERT INTO system.setting VALUES ('surveyorRank', 'Surveyor', true, 'The rank of the Surveyor');

DELETE FROM system.setting WHERE name ='surveyorGeneral';
INSERT INTO system.setting VALUES ('surveyorGeneral', 'I.K. Ajoku', true, 'The name of the Surveyor General');

DELETE FROM system.setting WHERE name ='governorName';
INSERT INTO system.setting VALUES ('governorName', 'CHIEF (DR.) WILLIE M. OBIANO', true, 'The full name (with titles) of the Governor - to appear on Certificates of Occupancy');

--modify default notation text for Awka SLTR Pilot

UPDATE application.request_type SET notation_template = 'Certificate of Occupancy results from Systematic Land Title Registration' WHERE code = 'systematicRegn';
UPDATE application.request_type SET notation_template = 'In favour of <<parcel1 number>>/AN/AWKA SOUTH/ISH over <<parcel2 number>>' WHERE code = 'servitude';
UPDATE application.request_type SET display_value = 'Right of Way' WHERE code = 'servitude';
UPDATE administrative.rrr_type  SET display_value = 'Right of Way' WHERE code = 'servitude';

-- Improve formatting of conditions
UPDATE administrative.lease_condition_template SET template_text='This certificate of occupancy is issued subject to the following covenants and conditions being observed by the holder/holders:
(a)	To pay such compensations to the inhabitants of the area of the land which is the subject of the Certificate of Occupancy and may 
	be fixed by the GOVERNOR or his authorized agents for the disturbances of the inhabitants in their use or occupation of the land.
(b)	During the first two years of the term of the agricultural certificate of occupancy to expend on cultivation and clearing a sum at least
	equivalent to N 500.00 (FIVE HUNDRED) NAIRA per hectare of the total area held under the certificate.
(c)	In each of the first eight years of the term created by the certificate of occupancy to bring into cultivation at least one-eighth of the
	cultivable portion of the land which is subject of the said certificate, and thereafter to keep in cultivation the whole of the cultivable
	portion of the such land to the satisfaction of the GOVERNOR.
(d)	Should livestock be brought on the land, to erect and maintain such fences as shall prevent such stock from straying off such land.
(e)	Not to construct upon the land any dwelling-house or any permanent structure except farmhouses and legitimate dwelling-houses 
	for farm workers and buildings to be used for storing agricultural machinery, tools or produce or for any other purpose directly 
	connected with the carrying of cultivation, planting or farming or housing of livestock as specifically approved by the GOVERNOR.
(f)	Not to plant or erect any hut or building within fifteen meters of the centre of any main road or in the case of a highway twenty-
	three meters from the center of the road or in the case of an express highway, forty-five meters from the center of the express 
	highway.
(g)	If any question shall arise as to whether any portion of the land is cultivable the decision of the GOVERNOR, if the land is within
	urban area, or the Local Government, if the land is outside urban area, shall be final.
(h)	All rights of inhabitants in respect of water, sacred trees and grasses of the land held under the certificate of occupancy are 
	reserved.
(i)	The formation of labourers camp shall be subject to the following conditions:
	  i	that officers of the Government and Local Government shall at all times have the right of access to such camps,
	 ii	that the camp is kept in a thorough sanitary state, and
	iii	that no fees or rental are charged to the persons therein for their use.
(j)	When inhabitants are, at the date of the issue of the agricultural certificate of occupancy, occupying any part of the land which is 
	the subject of the certificate of occupancy, the compensation to be paid to them by the holder of the certificate for improvement 
	and disturbance shall be assessed in accordance with the Act as soon as convenient after the date of the certificate of occupancy, 
	and any such inhabitants shall have the option either:
	  i	to vacate immediately the land and receive the compensation assessed, or
	 ii	to remain on the land until the holder requires them to vacate or until they desire to vacate the land; and on vacating the
		land to receive from the holder the compensation as aforesaid, or
	iii	that no fees or rental are charged to the persons therein for their use.
	Provided that the holder of the Certificate of Occupancy permits persons whether in occupation of the land at the date of the 
	Certificate of Occupancy or allowed by the said holder subsequently to occupy any part of the land to make improvements upon the 
	land after the date of the Certificate of Occupancy, the said holder shall be liable to pay compensation for such improvements 
	upon requiring the persons to vacate the land.' WHERE template_name = 'Agricultural';
	
	UPDATE administrative.lease_condition_template SET template_text='This certificate of occupancy is issued subject to the following covenants and conditions being observed by the holder/holders:
(a)	Not to erect or build or permit to be erected or built on the Land hereby granted any building other than those covenanted to be 
	erected by virtue of this Certificate of Occupancy and the regulations under the said Act not to make or permit to be made any 
	addition or alteration to the said buildings to be erected except in accordance with plans and specifications approved by the 
	Anambra State Urban Development Board of the Anambra State of Nigeria or any other officer appointed by the board.
(b)	To keep the exterior and interior of the buildings to be erected and all outbuildings and erections which may at any time during the 
	term hereby created be erected on the Land hereby granted and all additions to such buildings and outbuildings and the walls, 
	fences and appurtenances thereof in good and tenantable repair and condition. 
(c)	Not to use the buildings on the said land whether now erected or to be erected here after thereon for any purpose other than that 
	FOR WHICH THE LAND WAS GRANTED.
(d)	Not to alienate the right of Certificate of Occupancy hereby granted or any part thereof by sale, assignment, mortgage, transfer of 
	possession, sublease or bequest or otherwise howsoever without the consent of the GOVERNOR first having been obtained.
(e)	Not to permit anything to be used or done upon any part of the granted premises which shall be noxious, noisy or offensive or be of 
	any inconvenience or annoyance to tenants or occupiers of premises adjoining or near thereto.
(f)	To maintain standards of accommodation and sanitary and living conditions conformable with standards obtaining in the 
	neighbourhood.
(g)	To pay forthwith or without demand to the DIRECTOR OF LANDS or other persons appointed by him before the issue of this 
	certificate, all survey fees, registration fees, the improvement premium specified above and other charges due in respect of 
	preparation and issue and registration of this certificate.
(h)	To Install and operate water home sewage system within six months from the date the buildings erected on the plot are connected
	to a piped water-supply.
(i)	To pay with or without demand within the month of January each year the annual rent (specified above) reserved in these presents 
	or as may be revised in future.' WHERE template_name = 'Agricultural';
--Update software version

INSERT INTO system.version SELECT '1609a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1609a');