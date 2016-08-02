INSERT INTO system.version SELECT '1607b' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1607b');

ALTER TABLE administrative.rrr ADD COLUMN cofo_type text;
COMMENT ON COLUMN administrative.rrr.cofo_type IS 'type of cofo';


ALTER TABLE administrative.rrr_historic ADD COLUMN cofo_type text;

CREATE TABLE administrative.cofo_type
(
  code character varying(20) NOT NULL, 
  display_value character varying(500) NOT NULL, 
  status character(1) NOT NULL DEFAULT 't'::bpchar, 
  description character varying(1000) ,
  CONSTRAINT cofo_type_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrative.cofo_type
  OWNER TO postgres;

INSERT INTO administrative.cofo_type(
            code, display_value, status, description)
    VALUES ('building', 'Building', 'c', '');
INSERT INTO administrative.cofo_type(
            code, display_value, status, description)
     VALUES ('agriculture', 'Agriculture', 'c', '');


ALTER TABLE administrative.rrr ADD CONSTRAINT rrr_cofo_type_code_fk46 FOREIGN KEY (cofo_type)
      REFERENCES administrative.cofo_type (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;