-- Table: cadastre.tarrif_type

DROP TABLE IF EXISTS cadastre.tarrif_type CASCADE;

CREATE TABLE cadastre.tarrif_type
(
  code character varying(20) NOT NULL,
  display_value character varying(250) NOT NULL,
  description character varying(555),
  status character(1) NOT NULL DEFAULT 't'::bpchar,
  CONSTRAINT tarrif_type_pkey PRIMARY KEY (code),
  CONSTRAINT tarrif_type_display_value_unique UNIQUE (display_value)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cadastre.tarrif_type
  OWNER TO postgres;
COMMENT ON TABLE cadastre.tarrif_type
  IS 'Reference Table / Code list for registration transaction tarrifs
LADM Reference Object 
None
LADM Definition
Not Defined';

INSERT INTO cadastre.tarrif_type(code, display_value, description, status) VALUES ('zero', 'Zero rated', 'Zero rated transaction', 'c');
INSERT INTO cadastre.tarrif_type(code, display_value, description, status) VALUES ('residential', 'Residential', 'Residential transaction', 'c');
INSERT INTO cadastre.tarrif_type(code, display_value, description, status) VALUES ('agricultural', 'Agricultural', 'Agricultural transaction', 'c');
INSERT INTO cadastre.tarrif_type(code, display_value, description, status) VALUES ('commercial', 'Commercial', 'Commercial transaction', 'c');
INSERT INTO cadastre.tarrif_type(code, display_value, description, status) VALUES ('industrial', 'Industrial', 'Industrial transaction', 'c');

ALTER TABLE cadastre.land_use_type DROP Column IF EXISTS tarrif_code;
ALTER TABLE cadastre.land_use_type ADD Column tarrif_code character varying(20);

UPDATE cadastre.land_use_type SET tarrif_code = 'residential'  where code = 'res_home_comm';
UPDATE cadastre.land_use_type SET tarrif_code = 'residential'  where code  ='res_home';
UPDATE cadastre.land_use_type SET tarrif_code = 'residential'  where code  ='res_home_agric';
UPDATE cadastre.land_use_type SET tarrif_code = 'commercial'  where code  ='bus_commercial';
UPDATE cadastre.land_use_type SET tarrif_code = 'industrial'  where code  ='bus_industrial';
UPDATE cadastre.land_use_type SET tarrif_code = 'residential'  where code  ='bus_fstation';
UPDATE cadastre.land_use_type SET tarrif_code = 'agricultural'  where code  ='bus_agric';
UPDATE cadastre.land_use_type SET tarrif_code = 'commercial'  where code  ='bus_other';
UPDATE cadastre.land_use_type SET tarrif_code = 'zero'  where code  ='rel_mosque';
UPDATE cadastre.land_use_type SET tarrif_code = 'zero'  where code  ='rel_church';
UPDATE cadastre.land_use_type SET tarrif_code = 'zero'  where code  ='rel_other';
UPDATE cadastre.land_use_type SET tarrif_code = 'zero'  where code  ='gov_federal';
UPDATE cadastre.land_use_type SET tarrif_code = 'zero'  where code  ='gov_state';
UPDATE cadastre.land_use_type SET tarrif_code = 'zero'  where code  ='inst_school';
UPDATE cadastre.land_use_type SET tarrif_code = 'zero'  where code  ='inst_hosp';
UPDATE cadastre.land_use_type SET tarrif_code = 'zero'  where code  ='inst_other';
UPDATE cadastre.land_use_type SET tarrif_code = 'zero'  where code  ='comm_community_land';


ALTER TABLE cadastre.land_use_type ADD CONSTRAINT tarrif_type_code FOREIGN KEY (tarrif_code)
      REFERENCES cadastre.tarrif_type (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;

-- Table: cadastre.lga_tarrif_rate

DROP TABLE IF EXISTS cadastre.lga_tarrif_rate CASCADE;

CREATE TABLE cadastre.lga_tarrif_rate
(
  id  character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
  sug_id character varying(40) NOT NULL,
  tarrif_type character varying(20) NOT NULL,
  premium_state_land integer NOT NULL,
  premium_non_state_land integer NOT NULL,
  rent_state_land integer NOT NULL DEFAULT 5,
  rent_non_state_land integer NOT NULL DEFAULT 5,
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
  rowversion integer NOT NULL DEFAULT 0,
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar,
  change_user character varying(50),
  change_time timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT lga_tarrif_rate_pkey PRIMARY KEY (id),
  CONSTRAINT lga_rate_tarrif_sug_id FOREIGN KEY (sug_id)
      REFERENCES cadastre.spatial_unit_group (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT tarrif_type_code_fk84 FOREIGN KEY (tarrif_type)
      REFERENCES cadastre.tarrif_type (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cadastre.lga_tarrif_rate

  OWNER TO postgres;
COMMENT ON TABLE cadastre.lga_tarrif_rate

  IS 'relates spatial_unit_group and registration tarrif rates specific for each LGA';

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON cadastre.lga_tarrif_rate

  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

-- Trigger: __track_history on cadastre.lga_tarrif_rate

-- DROP TRIGGER __track_history ON cadastre.lga_tarrif_rate;

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON cadastre.lga_tarrif_rate

  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();

DROP TABLE IF EXISTS cadastre.lga_tarrif_rate_historic CASCADE;

CREATE TABLE cadastre.lga_tarrif_rate_historic
(
  id character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
  sug_id character varying(40) NOT NULL,
  tarrif_type character varying(20) NOT NULL,
  premium_state_land integer NOT NULL,
  premium_non_state_land integer NOT NULL,
  rent_state_land integer NOT NULL DEFAULT 5,
  rent_non_state_land integer NOT NULL DEFAULT 5,
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
ALTER TABLE cadastre.lga_tarrif_rate_historic
  OWNER TO postgres;

-- Index: cadastre.lga_tarrif_rate_historic_index_on_rowidentifier

-- DROP INDEX cadastre.lga_tarrif_rate_historic_index_on_rowidentifier;

CREATE INDEX lga_tarrif_rate_historic_index_on_rowidentifier
  ON cadastre.lga_tarrif_rate_historic
  USING btree
  (rowidentifier COLLATE pg_catalog."default");

INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/AGUATA', 'residential', 400, 200, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/AGUATA', 'commercial', 800, 400, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/AGUATA', 'industrial', 500, 250, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/AGUATA', 'agricultural', 50, 25, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/AGUATA', 'zero', 0, 0, 5, 5);

INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ANAMBRA EAST', 'residential', 700, 350, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ANAMBRA EAST', 'commercial', 1000, 500, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ANAMBRA EAST', 'industrial', 500, 250, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ANAMBRA EAST', 'agricultural', 50, 25, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ANAMBRA EAST', 'zero', 0, 0, 5, 5);

INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ANAMBRA WEST', 'residential', 700, 350, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ANAMBRA WEST', 'commercial', 1000, 500, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ANAMBRA WEST', 'industrial', 500, 250, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ANAMBRA WEST', 'agricultural', 50, 25, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ANAMBRA WEST', 'zero', 0, 0, 5, 5);

INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ANAOCHA', 'residential', 400, 200, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ANAOCHA', 'commercial', 800, 400, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ANAOCHA', 'industrial', 300, 150, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ANAOCHA', 'agricultural', 50, 25, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ANAOCHA', 'zero', 0, 0, 5, 5);

INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/AWKA NORTH', 'residential', 400, 200, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/AWKA NORTH', 'commercial', 800, 400, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/AWKA NORTH', 'industrial', 300, 150, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/AWKA NORTH', 'agricultural', 50, 25, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/AWKA NORTH', 'zero', 0, 0, 5, 5);

INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/AWKA SOUTH', 'residential', 400, 200, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/AWKA SOUTH', 'commercial', 800, 400, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/AWKA SOUTH', 'industrial', 300, 150, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/AWKA SOUTH', 'agricultural', 50, 25, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/AWKA SOUTH', 'zero', 0, 0, 5, 5);

INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/AYAMELUM', 'residential', 700, 350, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/AYAMELUM', 'commercial', 1000, 500, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/AYAMELUM', 'industrial', 500, 250, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/AYAMELUM', 'agricultural', 50, 25, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/AYAMELUM', 'zero', 0, 0, 5, 5);

INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/DUNUKOFIA', 'residential', 400, 200, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/DUNUKOFIA', 'commercial', 800, 400, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/DUNUKOFIA', 'industrial', 300, 150, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/DUNUKOFIA', 'agricultural', 50, 25, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/DUNUKOFIA', 'zero', 0, 0, 5, 5);

INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/EKWUSIGO', 'residential', 400, 200, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/EKWUSIGO', 'commercial', 800, 400, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/EKWUSIGO', 'industrial', 500, 250, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/EKWUSIGO', 'agricultural', 50, 25, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/EKWUSIGO', 'zero', 0, 0, 5, 5);

INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/IDEMILI NORTH', 'residential', 700, 350, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/IDEMILI NORTH', 'commercial', 1000, 500, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/IDEMILI NORTH', 'industrial', 500, 250, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/IDEMILI NORTH', 'agricultural', 50, 25, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/IDEMILI NORTH', 'zero', 0, 0, 5, 5);

INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/IDEMILI SOUTH', 'residential', 700, 350, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/IDEMILI SOUTH', 'commercial', 1000, 500, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/IDEMILI SOUTH', 'industrial', 500, 250, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/IDEMILI SOUTH', 'agricultural', 50, 25, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/IDEMILI SOUTH', 'zero', 0, 0, 5, 5);

INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/IHIALA', 'residential', 400, 200, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/IHIALA', 'commercial', 800, 400, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/IHIALA', 'industrial', 500, 250, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/IHIALA', 'agricultural', 50, 25, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/IHIALA', 'zero', 0, 0, 5, 5);

INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/NJIKOKA', 'residential', 400, 200, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/NJIKOKA', 'commercial', 800, 400, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/NJIKOKA', 'industrial', 300, 150, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/NJIKOKA', 'agricultural', 50, 25, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/NJIKOKA', 'zero', 0, 0, 5, 5);


INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/NNEWI NORTH', 'residential', 400, 200, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/NNEWI NORTH', 'commercial', 800, 400, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/NNEWI NORTH', 'industrial', 500, 250, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/NNEWI NORTH', 'agricultural', 50, 25, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/NNEWI NORTH', 'zero', 0, 0, 5, 5);

INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/NNEWI SOUTH', 'residential', 400, 200, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/NNEWI SOUTH', 'commercial', 800, 400, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/NNEWI SOUTH', 'industrial', 500, 250, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/NNEWI SOUTH', 'agricultural', 50, 25, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/NNEWI SOUTH', 'zero', 0, 0, 5, 5);

INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/OGBARU', 'residential', 400, 200, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/OGBARU', 'commercial', 800, 400, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/OGBARU', 'industrial', 500, 250, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/OGBARU', 'agricultural', 50, 25, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/OGBARU', 'zero', 0, 0, 5, 5);

INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ONITSHA NORTH', 'residential', 700, 350, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ONITSHA NORTH', 'commercial', 1000, 500, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ONITSHA NORTH', 'industrial', 500, 250, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ONITSHA NORTH', 'agricultural', 50, 25, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ONITSHA NORTH', 'zero', 0, 0, 5, 5);

INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ONITSHA SOUTH', 'residential', 700, 350, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ONITSHA SOUTH', 'commercial', 1000, 500, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ONITSHA SOUTH', 'industrial', 500, 250, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ONITSHA SOUTH', 'agricultural', 50, 25, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ONITSHA SOUTH', 'zero', 0, 0, 5, 5);

INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ORUMBA NORTH', 'residential', 400, 200, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ORUMBA NORTH', 'commercial', 800, 400, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ORUMBA NORTH', 'industrial', 500, 250, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ORUMBA NORTH', 'agricultural', 50, 25, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ORUMBA NORTH', 'zero', 0, 0, 5, 5);

INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ORUMBA SOUTH', 'residential', 400, 200, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ORUMBA SOUTH', 'commercial', 800, 400, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ORUMBA SOUTH', 'industrial', 500, 250, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ORUMBA SOUTH', 'agricultural', 50, 25, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/ORUMBA SOUTH', 'zero', 0, 0, 5, 5);

INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/OYI', 'residential', 700, 350, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/OYI', 'commercial', 1000, 500, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/OYI', 'industrial', 500, 250, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/OYI', 'agricultural', 50, 25, 5, 5);
INSERT INTO cadastre.lga_tarrif_rate(sug_id, tarrif_type, premium_state_land, premium_non_state_land, rent_state_land, rent_non_state_land) VALUES ('AN/OYI', 'zero', 0, 0, 5, 5);

DELETE FROM system.br WHERE id ='generate-premium';
INSERT INTO system.br VALUES ('generate-premium', 'generate-premium', 'sql', 'calculates the improvement premium for the property', NULL, 'calculates the premium improvement for a property');

DELETE FROM system.br_definition WHERE br_id ='generate-premium';
INSERT INTO system.br_definition VALUES ('generate-premium', '2016-09-04', 'infinity', 
	'WITH tarrifRecs AS	(SELECT rot_code, premium_state_land, premium_non_state_land FROM application.systematic_registration_certificates srCerts
				INNER JOIN cadastre.land_use_type lut ON (srCerts.landuse = lut.code)
				INNER JOIN cadastre.lga_tarrif_rate tr ON (lut.tarrif_code = tr.tarrif_type)
				INNER JOIN administrative.rrr pr ON ((srCerts.ba_unit_id = pr.ba_unit_id) AND is_primary)
				WHERE srCerts.ba_unit_id= #{id})

SELECT	CASE 	WHEN (SELECT (rot_code = ''P'') THEN premium_non_state_land
		WHEN (SELECT (rot_code = ''G'') THEN premium_state_land
		ELSE  NULL
	END AS vl FROM tarrifRecs
ORDER BY 1
LIMIT 1
');

DELETE FROM system.br WHERE id ='generate-stamp-duty';
INSERT INTO system.br VALUES ('generate-stamp-duty', 'generate-stamp-duty', 'sql', 'calculates the stamp duty for registration of new CofO', NULL, 'calculates the stamp duty for registration of new CofO');

DELETE FROM system.br_definition WHERE br_id ='generate-stamp-duty';
INSERT INTO system.br_definition VALUES ('generate-stamp-duty', '2016-09-04', 'infinity', 
	'WITH tarrifRecs AS	(SELECT rot_code, premium_state_land, premium_non_state_land FROM application.systematic_registration_certificates srCerts
				INNER JOIN cadastre.land_use_type lut ON (srCerts.landuse = lut.code)
				INNER JOIN cadastre.lga_tarrif_rate tr ON (lut.tarrif_code = tr.tarrif_type)
				INNER JOIN administrative.rrr pr ON ((srCerts.ba_unit_id = pr.ba_unit_id) AND is_primary)
				WHERE srCerts.ba_unit_id= #{id})

SELECT	CASE 	WHEN (SELECT (rot_code = ''P'') THEN 0.0003 * premium_non_state_land
		WHEN (SELECT (rot_code = ''G'') THEN 0.0003 * premium_state_land
		ELSE  NULL
	END AS vl FROM tarrifRecs
ORDER BY 1
LIMIT 1
');


DELETE FROM system.br WHERE id ='generate-rent';
INSERT INTO system.br VALUES ('generate-rent', 'generate-rent', 'sql', 'calculates the annual rent for the property', NULL, 'calculates the annual rent for a property');

DELETE FROM system.br_definition WHERE br_id ='generate-rent';
INSERT INTO system.br_definition VALUES ('generate-rent', '2016-09-04', 'infinity', 
	'WITH tarrifRecs AS	(SELECT size, rot_code, rent_state_land, rent_non_state_land FROM application.systematic_registration_certificates srCerts
				INNER JOIN cadastre.land_use_type lut ON (srCerts.landuse = lut.code)
				INNER JOIN cadastre.lga_tarrif_rate tr ON (lut.tarrif_code = tr.tarrif_type)
				INNER JOIN administrative.rrr pr ON ((srCerts.ba_unit_id = pr.ba_unit_id) AND is_primary)
				WHERE srCerts.ba_unit_id= #{id})

SELECT	CASE 	WHEN (SELECT (rot_code = ''P'') THEN rent_non_state_land * size
		WHEN (SELECT (rot_code = ''G'') THEN rent_state_land *size
		ELSE  NULL
	END AS vl FROM tarrifRecs
ORDER BY 1
LIMIT 1
');


