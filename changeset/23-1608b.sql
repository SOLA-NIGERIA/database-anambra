-------------  INSERT  -------------------------------------------------------------
--
-- PostgreSQL database dump
--
 
 
-- Dumped from database version 9.2.3
-- Dumped by pg_dump version 9.3.1
-- Started on 2015-08-06 16:41:13

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = administrative, pg_catalog;

--
-- TOC entry 3731 (class 0 OID 682221)
-- Dependencies: 381
-- Data for Name: ba_unit_detail_type; Type: TABLE DATA; Schema: administrative; Owner: postgres
--

SET SESSION AUTHORIZATION DEFAULT;


---administrative.rrr_occupancy_type ------
--INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('estate', 'Estate', 'Estate type', 'x', 'cofo', 'TEXT', 0);



--- Table: cadastre.lga

-- DROP TABLE cadastre.lga_type;

CREATE TABLE cadastre.lga_type
(
  code character varying(20) NOT NULL, -- LADM Definition: The code for the lga.
  display_value character varying(500) NOT NULL, -- LADM Definition: Displayed value of the lga.
  description character varying(1000), -- LADM Definition: Description of the lga.
  status character(1) NOT NULL DEFAULT 't'::bpchar, -- SOLA Extension: Status of the lga
  CONSTRAINT lga_pkey PRIMARY KEY (code),
  CONSTRAINT lga_type_display_value_unique UNIQUE (display_value)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cadastre.lga_type
  OWNER TO postgres;
COMMENT ON TABLE cadastre.lga_type
  IS 'Code list of lgas.. 
  Tags: Reference Table, LADM Reference Object';
COMMENT ON COLUMN cadastre.lga_type.code IS 'LADM Definition: The code for the lga.';
COMMENT ON COLUMN cadastre.lga_type.display_value IS 'LADM Definition: Displayed value of the lga.';
COMMENT ON COLUMN cadastre.lga_type.description IS 'LADM Definition: Description of the lga.';
COMMENT ON COLUMN cadastre.lga_type.status IS 'SOLA Extension: Status of the lga';

--- Table: cadastre.zone_type

-- DROP TABLE cadastre.zone_type;

CREATE TABLE cadastre.zone_type
(
  code character varying(20) NOT NULL, -- LADM Definition: The code for the zone.
  display_value character varying(500) NOT NULL, -- LADM Definition: Displayed value of the zone.
  description character varying(1000), -- LADM Definition: Description of the zone.
  status character(1) NOT NULL DEFAULT 't'::bpchar, -- SOLA Extension: Status of the zone
  CONSTRAINT zone_pkey PRIMARY KEY (code),
  CONSTRAINT zone_type_display_value_unique UNIQUE (display_value)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cadastre.zone_type
  OWNER TO postgres;
COMMENT ON TABLE cadastre.zone_type
  IS 'Code list of zones.. 
  Tags: Reference Table, LADM Reference Object';
COMMENT ON COLUMN cadastre.zone_type.code IS 'LADM Definition: The code for the zone.';
COMMENT ON COLUMN cadastre.zone_type.display_value IS 'LADM Definition: Displayed value of the zone.';
COMMENT ON COLUMN cadastre.zone_type.description IS 'LADM Definition: Description of the zone.';
COMMENT ON COLUMN cadastre.zone_type.status IS 'SOLA Extension: Status of the zone';



-- DROP TABLE cadastre.lga_type;

CREATE TABLE administrative.rrr_occupancy_type
(
  code character varying(20) NOT NULL, -- LADM Definition: The code for the lga.
  display_value character varying(500) NOT NULL, -- LADM Definition: Displayed value of the lga.
  description character varying(1000), -- LADM Definition: Description of the lga.
  status character(1) NOT NULL DEFAULT 't'::bpchar, -- SOLA Extension: Status of the lga
  CONSTRAINT rot_pkey PRIMARY KEY (code),
  CONSTRAINT rot_display_value_unique UNIQUE (display_value)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrative.rrr_occupancy_type
  OWNER TO postgres;
COMMENT ON TABLE administrative.rrr_occupancy_type
  IS 'Code list of rot.. 
  Tags: Reference Table, LADM Reference Object';
COMMENT ON COLUMN administrative.rrr_occupancy_type.code IS 'LADM Definition: The code for the rot.';
COMMENT ON COLUMN administrative.rrr_occupancy_type.display_value IS 'LADM Definition: Displayed value of the rot.';
COMMENT ON COLUMN administrative.rrr_occupancy_type.description IS 'LADM Definition: Description of the rot.';
COMMENT ON COLUMN administrative.rrr_occupancy_type.status IS 'SOLA Extension: Status of the rot';


INSERT INTO administrative.rrr_occupancy_type(
            code, display_value,  
            description, status)
    VALUES ('G',  'Government', 'cofo extension', 'c');


 INSERT INTO administrative.rrr_occupancy_type(
            code, display_value,  
            description, status)
    VALUES ('P',  'Private','cofo extension', 'c');




--ALTER TABLE administrative.condition_type DISABLE TRIGGER ALL;
--DELETE FROM condition_type  where is_for = 'cofo';
--
-- TOC entry 3753 (class 0 OID 686347)
-- Dependencies: 381
-- Data for Name: ba_unit_detail_type; Type: TABLE DATA; Schema: administrative; Owner: postgres
--

--INSERT INTO administrative.condition_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('valueTodevelope', 'Value of the buildings/other works', 'the value of the buildings to be erected or the additional works to be completed in the specified period of time', 'c', 'cofo', 'NUMBER', 8);
--INSERT INTO administrative.condition_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('yearsTodevelope', 'Years to develope', 'Within the specified number of years the piece of land has to be developed by erecting buildings or other works', 'c', 'cofo', 'NUMBER', 9);

--ALTER TABLE administrative.condition_type ENABLE TRIGGER ALL;


ALTER TABLE administrative.rrr DISABLE TRIGGER ALL;

--INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('instrumentRegistrationNo', 'Instrument Number', 'Registration Instrument Number', 'x', 'cofo', 'TEXT', 0);
-- UPDATE administrative.ba_unit_detail_type  SET code='instrumentRegistrationNo' WHERE code='instrnum';
ALTER TABLE administrative.rrr
  ADD COLUMN instrument_registration_no character varying(255);
ALTER TABLE administrative.rrr_historic
  ADD COLUMN instrument_registration_no character varying(255);



--INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('dateCommenced', 'Date Commenced', 'Date in which the occupancy started', 'c', 'cofo', 'DATE', 4);
--UPDATE administrative.ba_unit_detail_type  SET code='dateCommenced' WHERE code='startdate';
ALTER TABLE administrative.rrr
  ADD COLUMN date_commenced date;
ALTER TABLE administrative.rrr_historic
  ADD COLUMN date_commenced date;

--INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('dateSigned', 'Date Signed', 'Date when governor signed', 'c', 'plan', 'DATE', 15);
--UPDATE administrative.ba_unit_detail_type  SET code='dateSigned' WHERE code='dateissued';
ALTER TABLE administrative.rrr
  ADD COLUMN date_signed date;
ALTER TABLE administrative.rrr_historic
  ADD COLUMN date_signed date;

--INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('cOfO', 'CofO Number', 'Existing Certificate number', 'c', 'cofo', 'TEXT', 1);
--UPDATE administrative.ba_unit_detail_type  SET code='cOfO' WHERE code='cofonum';
ALTER TABLE administrative.rrr
  ADD COLUMN cofo character varying(255);
ALTER TABLE administrative.rrr_historic
  ADD COLUMN cofo character varying(255);


--INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('term', 'Term of Occupancy', 'The term the occupancy will last', 'c', 'cofo', 'NUMBER', 3);
ALTER TABLE administrative.rrr
  ADD COLUMN term integer;
ALTER TABLE administrative.rrr_historic
  ADD COLUMN term integer;



--INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('cOfO', 'CofO Number', 'Existing Certificate number', 'c', 'cofo', 'TEXT', 1);
--UPDATE administrative.ba_unit_detail_type  SET code='zone' WHERE code='zone';
ALTER TABLE administrative.rrr
  ADD COLUMN zone_code character varying(255);
ALTER TABLE administrative.rrr_historic
  ADD COLUMN zone_code character varying(255);
ALTER TABLE administrative.rrr
  ADD CONSTRAINT rrr_zone_type_code_fk46 FOREIGN KEY (zone_code) REFERENCES cadastre.zone_type (code) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE administrative.rrr
  ADD COLUMN rot_code character varying(255);
ALTER TABLE administrative.rrr_historic
  ADD COLUMN rot_code character varying(255);
ALTER TABLE administrative.rrr
  ADD CONSTRAINT rrr_rot_code_fk47 FOREIGN KEY (rot_code) REFERENCES administrative.rrr_occupancy_type (code) ON UPDATE CASCADE ON DELETE CASCADE;



--INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('advancePayment', 'Advance Payment', 'Payment in advance', 'c', 'cofo', 'NUMBER', 6);
--UPDATE administrative.ba_unit_detail_type  SET code='advancePayment' WHERE code='advpayment';
ALTER TABLE administrative.rrr
  ADD COLUMN advance_payment numeric(29,0);
ALTER TABLE administrative.rrr_historic
  ADD COLUMN advance_payment numeric(29,0);

--INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('yearlyRent', 'Yearly Rent', 'Amount of yearly rent', 'c', 'cofo', 'NUMBER', 5);
--UPDATE administrative.ba_unit_detail_type  SET code='yearlyRent' WHERE code='rent';
ALTER TABLE administrative.rrr
  ADD COLUMN yearly_rent numeric(19,0);
ALTER TABLE administrative.rrr_historic
  ADD COLUMN yearly_rent numeric(19,0);


--INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('reviewPeriod', 'Review Period', 'The divided period of term of occupancy', 'c', 'cofo', 'NUMBER', 7);
--UPDATE administrative.ba_unit_detail_type  SET code='reviewPeriod' WHERE code='revperiod';
ALTER TABLE administrative.rrr
  ADD COLUMN review_period integer;
ALTER TABLE administrative.rrr_historic
  ADD COLUMN review_period integer;

ALTER TABLE administrative.rrr ENABLE TRIGGER ALL;

--INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('dateRegistered', 'Registration Date', 'Date when the CofO has been registered', 'c', 'cofo', 'DATE', 14);
--UPDATE administrative.ba_unit_detail_type  SET code='dateRegistered' WHERE code='dateregistered';
-- RRR REGISTRATION DATE



ALTER TABLE cadastre.cadastre_object DISABLE TRIGGER ALL;

---  CADASTRE OBJECT -----------
--INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('cOfOtype', 'Occupancy Right Purpose', 'Purpose of Occupancy', 'c', 'cofo', 'COMBO', 2);
-- UPDATE administrative.ba_unit_detail_type  SET code='cOfOtype' WHERE code='purpose';
-- CADASTRE OBJECT LAND USE
--INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('location', 'Location', 'Location of the property', 'c', 'cofo', 'TEXT', 10);
-- CADASTRE OBJECT LOCATION

--INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('layoutPlan', 'Layout Plan', 'Layout Plan', 'c', 'plan', 'TEXT', 11);
--UPDATE administrative.ba_unit_detail_type  SET code='layoutPlan' WHERE code='plan';
---------source_reference------------------
--ALTER TABLE cadastre.cadastre_object
  --ADD COLUMN layout_plan character varying(255);
--ALTER TABLE cadastre.cadastre_object_historic
  --ADD COLUMN layout_plan character varying(255);

--INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('block', 'Block', 'Block', 'c', 'plan', 'TEXT', 12);
ALTER TABLE cadastre.cadastre_object
  ADD COLUMN block character varying(255);
ALTER TABLE cadastre.cadastre_object_historic
  ADD COLUMN block character varying(255);
 
--INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('plotNum', 'Plot Number', 'Plot number', 'c', 'plan', 'TEXT', 13);
--UPDATE administrative.ba_unit_detail_type  SET code='plotNum' WHERE code='plot';
ALTER TABLE cadastre.cadastre_object
  ADD COLUMN plot_num character varying(255);
ALTER TABLE cadastre.cadastre_object_historic
  ADD COLUMN plot_num character varying(255);

--INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('LGA', 'LGA', 'Lga', 'x', 'cofo', 'TEXT', 0);
--UPDATE administrative.ba_unit_detail_type  SET code='LGA' WHERE code='lga';
ALTER TABLE cadastre.cadastre_object
  ADD COLUMN lga_code character varying(255);
ALTER TABLE cadastre.cadastre_object_historic
  ADD COLUMN lga_code character varying(255);

--INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('zone', 'Zone', 'Zonal areas', 'x', 'cofo', 'TEXT', 0);
--ALTER TABLE cadastre.cadastre_object
--  ADD COLUMN zone_code character varying(255);
--ALTER TABLE cadastre.cadastre_object_historic
--  ADD COLUMN zone_code character varying(255);

--INSERT INTO ba_unit_detail_type (code, display_value, description, status, is_for, field_type, order_view) VALUES ('IntellMapSheet', 'Sheet Number', 'Sheet Number', 'c', 'plan', 'TEXT', 16);
ALTER TABLE cadastre.cadastre_object
  ADD COLUMN intell_map_sheet character varying(255);
ALTER TABLE cadastre.cadastre_object_historic
  ADD COLUMN intell_map_sheet character varying(255);

-- Completed on 2015-09-14 09:53:36

--
-- PostgreSQL database dump complete
--
ALTER TABLE cadastre.cadastre_object ENABLE TRIGGER ALL;




---------------------------------------------------------------------------
DROP VIEW application.systematic_registration_certificates;
CREATE OR REPLACE VIEW application.systematic_registration_certificates AS 
  SELECT DISTINCT 
    
--	TBV  ------------------------------------------------------------------------------------------
--    sg.name::text 									AS name, 
--    aa.nr 										AS nr, 
--    aa.id::text 									AS appid, 
--    ( SELECT lga.label
--           FROM cadastre.spatial_unit_group lga
--          WHERE lga.hierarchy_level = 3 AND co.name_lastpart::text = lga.name::text) 	AS ward, 
--    (( SELECT count(s.id) AS count
--           FROM source.source s
--           WHERE s.description::text ~~ 
--           ((('TOTAL_'::text || 'title'::text) || '%'::text) 
--           || replace(sg.name::text, '/'::text, '-'::text))))::integer 			AS cofo, 

--------------------------------------------------------------------------------------------------------

    co.id											AS id, 
    co.name_firstpart										AS name_firstpart, 
    co.name_lastpart										AS name_lastpart, 
    su.ba_unit_id										AS ba_unit_id, 
    round(sa.size) 										AS size, 
    administrative.get_parcel_share(su.ba_unit_id) 						AS owners, 

--	SYSTEM.SETTING TABLE
--	system.setting.system_id
    ( SELECT setting.vl
             from system.setting
             WHERE setting.name::text = 'state'::text) 					AS state, 
          
-- 	system.setting.surveyor
    ( SELECT setting.vl
           FROM system.setting
          WHERE setting.name::text = 'surveyor'::text) 						AS surveyor, 


--	system.setting.rank
    ( SELECT setting.vl
           FROM system.setting
          WHERE setting.name::text = 'surveyorRank'::text) 					AS rank,



--	SYSTEM.CONFIG_MAP_LAYER_METADATA TABLE

-- 	imagerydate
    ( SELECT config_map_layer_metadata.value
           FROM system.config_map_layer_metadata
          WHERE config_map_layer_metadata.name_layer::text = 'orthophoto'::text 
          AND config_map_layer_metadata.name::text = 'date'::text) 				AS imagerydate, 
--	imageryresolution
    ( SELECT config_map_layer_metadata.value
           FROM system.config_map_layer_metadata
          WHERE config_map_layer_metadata.name_layer::text = 'orthophoto'::text 
          AND config_map_layer_metadata.name::text = 'resolution'::text) 			AS imageryresolution, 
--	imagerysource
    ( SELECT config_map_layer_metadata.value
           FROM system.config_map_layer_metadata
          WHERE config_map_layer_metadata.name_layer::text = 'orthophoto'::text 
          AND config_map_layer_metadata.name::text = 'data-source'::text) 			AS imagerysource, 

--    	BA UNIT DETAIL TABLE
--   	 lga 
    --administrative.get_baunit_detail(su.ba_unit_id, 'LGA') 
      lga.display_value										AS lga, 
        
--   	 zone 
    --administrative.get_baunit_detail(su.ba_unit_id, 'zone') 				
    zone.display_value										AS zone, 

--   	 location 
    --administrative.get_baunit_detail(su.ba_unit_id, 'location') 				
    ad.description										AS location, 

--    	 plan        
    --administrative.get_baunit_detail(su.ba_unit_id, 'layoutPlan') 				
    co.source_reference										AS plan, 

-- 	 sheetnr  
    --administrative.get_baunit_detail(su.ba_unit_id, 'IntellMapSheet') 				
    co.intell_map_sheet										AS sheetnr, 

-- 	 date commenced
    --administrative.get_baunit_detail(su.ba_unit_id, 'dateCommenced')  			
    rrr.date_commenced										AS commencingdate, 

--  	 purpose     
    --administrative.get_baunit_detail(su.ba_unit_id, 'cOfOtype')   			
    lu.display_value										AS purpose, 

--  	 term     
    --administrative.get_baunit_detail(su.ba_unit_id, 'term')	              		
    rrr.term											AS term,

--       rent
    --administrative.get_baunit_detail(su.ba_unit_id, 'yearlyRent')	              		
    rrr.yearly_rent										AS  rent

   FROM 
    cadastre.cadastre_object co, 
    administrative.ba_unit bu, 
    cadastre.land_use_type lu, 
    cadastre.lga_type lga,
    cadastre.zone_type zone, 
    cadastre.spatial_value_area sa, 
    administrative.ba_unit_contains_spatial_unit su,
    administrative.rrr rrr,
    address.address ad,
    cadastre.spatial_unit_address  sad
    
  WHERE 
  bu.id::text = su.ba_unit_id::text
  AND bu.id::text = rrr.ba_unit_id::text
  AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  AND sa.spatial_unit_id::text = co.id::text 
  AND sa.type_code::text = 'officialArea'::text 
  AND COALESCE(co.land_use_code, 'residential'::character varying)::text = lu.code::text
  AND coalesce(co.lga_code::text, 'Katsina')  = lga.code::text 
  AND rrr.zone_code::text = zone.code::text
  AND ad.id =  sad.address_id
  AND co.id =  sad.spatial_unit_id
  AND rrr.type_code = 'ownership'
  ORDER BY co.name_firstpart, co.name_lastpart;
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

