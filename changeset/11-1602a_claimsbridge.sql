
-- Function: get_geometry_with_srid(geometry)
DROP FUNCTION get_geometry_with_srid(geometry);

CREATE OR REPLACE FUNCTION get_geometry_with_srid(geom geometry)
  RETURNS geometry AS
$BODY$
declare
  srid_found integer;
  x float;
 last_part geometry;
 newGeom geometry;
begin
   ----if (select count(*) from system.crs) = 1 then
       -- srid_found = (select srid from system.crs);
       -- last_part := ST_SetSRID(geom,srid_found);
  ----end if;
x = st_x(st_transform(st_centroid(last_part), 4326));
srid_found = (select srid from system.crs where x >= from_long and x < to_long );

 --srid_found = (select srid from system.crs);
 last_part := ST_SetSRID(geom,srid_found);
  
return  ST_Transform(
   ST_GeomFromText(
   ST_AsText(last_part),4326),32632);  ---3857
end;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION get_geometry_with_srid(geometry)
  OWNER TO postgres;
COMMENT ON FUNCTION get_geometry_with_srid(geometry) IS 'This function assigns a srid found in the settings to the geometry passed as parameter. The srid is chosen based in the longitude where the centroid of the geometry is.';


DROP FUNCTION cadastre.get_new_cadastre_object_identifier_last_part(geometry, character varying);


CREATE OR REPLACE FUNCTION cadastre.get_new_cadastre_object_identifier_last_part(geom geometry, cadastre_object_type character varying)
  RETURNS character varying AS
$BODY$
declare
last_part geometry;
val_to_return character varying;
srid_found integer;
begin
 
 
  srid_found = (select srid from system.crs);
  last_part := ST_SetSRID(geom,srid_found);
   
 if cadastre_object_type != 'mapped_geometry' then   
   select name 
   into val_to_return
   from cadastre.spatial_unit_group sg
   where ST_Intersects(ST_PointOnSurface(last_part), sg.geom)
   and sg.hierarchy_level = 3;
 else
   select name into val_to_return
   from cadastre.spatial_unit_group sg
   where 
   ST_Intersects(ST_PointOnSurface(
   ST_Transform(
   ST_GeomFromText(
   ST_AsText(last_part),4326),32632)), sg.geom)
   and 
   sg.hierarchy_level = 3
   ;
 end if;

   if val_to_return is null then
    val_to_return := 'NO LGA/WARD';
   end if;

  return val_to_return;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION cadastre.get_new_cadastre_object_identifier_last_part(geometry, character varying)
  OWNER TO postgres;
COMMENT ON FUNCTION cadastre.get_new_cadastre_object_identifier_last_part(geometry, character varying) IS 'This function generates the last part of the cadastre object identifier.
It has to be overridden to apply the algorithm specific to the situation.';




INSERT INTO source.administrative_source_type(
            code, display_value, status, description, is_for_registration)
    VALUES ('claimSummary', 'OT Claim Summary', 'c', 'Extension to LADM to link opentenure claims', false);


--INSERT INTO application.request_type_requires_source_type(
  --          source_type_code, request_type_code)
    --VALUES ('claimSummary', 'systematicRegn');
  
 

-- Table: administrative.rrr_condition
DROP  TABLE  administrative.lease_condition  CASCADE;
-- DROP TABLE administrative.rrr_condition;

CREATE TABLE administrative.rrr_condition
(
  code character varying(20) NOT NULL,
  display_value character varying(250) NOT NULL,
  description character varying(5000) NOT NULL,
  status character(1) NOT NULL,
  CONSTRAINT rrr_condition_pkey PRIMARY KEY (code),
  CONSTRAINT rrr_condition_display_value_unique UNIQUE (display_value)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrative.rrr_condition
  OWNER TO postgres;
COMMENT ON TABLE administrative.rrr_condition
  IS 'Reference Table / Code list for standard rrr conditions
LADM Definition
Not Defined';



    -- Table: administrative.condition_for_rrr

DROP TABLE administrative.lease_condition_for_rrr CASCADE;
--DROP TABLE administrative.condition_for_rrr;

CREATE TABLE administrative.condition_for_rrr
(
  id character varying(40) NOT NULL,
  rrr_id character varying(40) NOT NULL,
  condition_code character varying(20),
  custom_condition_text character varying(500),
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
  rowversion integer NOT NULL DEFAULT 0,
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar,
  change_user character varying(50),
  change_time timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT condition_for_rrr_pkey PRIMARY KEY (id),
  CONSTRAINT condition_for_rrr_condition_code_fk130 FOREIGN KEY (condition_code)
      REFERENCES administrative.rrr_condition (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT condition_for_rrr_rrr_id_fk131 FOREIGN KEY (rrr_id)
      REFERENCES administrative.rrr (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrative.condition_for_rrr
  OWNER TO postgres;
COMMENT ON TABLE administrative.condition_for_rrr
  IS 'rrr conditions, related to RRR ';

-- Index: administrative.condition_for_rrr_index_on_rowidentifier

-- DROP INDEX administrative.condition_for_rrr_index_on_rowidentifier;

CREATE INDEX condition_for_rrr_index_on_rowidentifier
  ON administrative.condition_for_rrr
  USING btree
  (rowidentifier COLLATE pg_catalog."default");

-- Index: administrative.condition_for_rrr_condition_code_fk130_ind

-- DROP INDEX administrative.condition_for_rrr_condition_code_fk130_ind;

CREATE INDEX condition_for_rrr_condition_code_fk130_ind
  ON administrative.condition_for_rrr
  USING btree
  (condition_code COLLATE pg_catalog."default");

-- Index: administrative.condition_for_rrr_rrr_id_fk131_ind

-- DROP INDEX administrative.condition_for_rrr_rrr_id_fk131_ind;

CREATE INDEX condition_for_rrr_rrr_id_fk131_ind
  ON administrative.condition_for_rrr
  USING btree
  (rrr_id COLLATE pg_catalog."default");


-- Trigger: __track_changes on administrative.condition_for_rrr

-- DROP TRIGGER __track_changes ON administrative.condition_for_rrr;

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON administrative.condition_for_rrr
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

-- Trigger: __track_history on administrative.condition_for_rrr

-- DROP TRIGGER __track_history ON administrative.condition_for_rrr;

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON administrative.condition_for_rrr
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();

-- Table: administrative.condition_for_rrr_historic
 DROP TABLE administrative.lease_condition_for_rrr_historic;
-- DROP TABLE administrative.condition_for_rrr_historic;

	CREATE TABLE administrative.condition_for_rrr_historic
	(
	  id character varying(40),
	  rrr_id character varying(40),
	  condition_code character varying(20),
	  custom_condition_text character varying(500),
	  rowidentifier character varying(40),
	  rowversion integer,
	  change_action character(1),
	  change_user character varying(50),
	  change_time timestamp without time zone,
	  change_time_valid_until timestamp without time zone NOT NULL DEFAULT now()
	)
	WITH (
	  OIDS=FALSE
	);
	ALTER TABLE administrative.condition_for_rrr_historic
	  OWNER TO postgres;

	-- Index: administrative.condition_for_rrr_historic_index_on_rowidentifier

	-- DROP INDEX administrative.condition_for_rrr_historic_index_on_rowidentifier;

	CREATE INDEX condition_for_rrr_historic_index_on_rowidentifier
	  ON administrative.condition_for_rrr_historic
	  USING btree
	  (rowidentifier COLLATE pg_catalog."default");
