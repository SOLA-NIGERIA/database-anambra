INSERT INTO system.version SELECT '1607a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1607a');

ALTER TABLE administrative.rrr ADD COLUMN lease_conditions text;
COMMENT ON COLUMN administrative.rrr.lease_conditions IS 'Lease conditions text';

ALTER TABLE administrative.rrr_historic ADD COLUMN lease_conditions text;

CREATE TABLE administrative.lease_condition_template
(
  id character varying(40) NOT NULL DEFAULT uuid_generate_v1(), 
  template_name character varying(250) NOT NULL, 
  rrr_type character varying(20), 
  template_text text NOT NULL, 
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(), 
  rowversion integer NOT NULL DEFAULT 0, 
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar, 
  change_user character varying(50),
  change_time timestamp without time zone NOT NULL DEFAULT now(), 
  CONSTRAINT id PRIMARY KEY (id),
  CONSTRAINT template_name_unique UNIQUE (template_name),
  CONSTRAINT lease_condition_template_rrr_type FOREIGN KEY (rrr_type)
      REFERENCES administrative.rrr_type (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT
)
WITH (
  OIDS=FALSE
);
ALTER TABLE administrative.lease_condition_template
  OWNER TO postgres;
COMMENT ON TABLE administrative.lease_condition_template
  IS 'A list of lease condions templates which can be used for creating new leases. LADM extension.';
COMMENT ON COLUMN administrative.lease_condition_template.id IS 'Identifier of the lease condition template.';
COMMENT ON COLUMN administrative.lease_condition_template.template_name IS 'Lease condition template name';
COMMENT ON COLUMN administrative.lease_condition_template.rrr_type IS 'RRR type code for filtering templates when creating new lease. Can be null.';
COMMENT ON COLUMN administrative.lease_condition_template.template_text IS 'The actual text of lease conditions';
COMMENT ON COLUMN administrative.lease_condition_template.rowidentifier IS 'Identifies the all change records for the row in the lease_condition_template table';
COMMENT ON COLUMN administrative.lease_condition_template.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN administrative.lease_condition_template.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN administrative.lease_condition_template.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN administrative.lease_condition_template.change_time IS 'The date and time the row was last modified.';

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON administrative.lease_condition_template
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON administrative.lease_condition_template
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();
  
CREATE TABLE administrative.lease_condition_template_historic
(
  id character varying(40), 
  template_name character varying(250), 
  rrr_type character varying(20), 
  template_text text, 
  rowidentifier character varying(40), 
  rowversion integer, 
  change_action character(1), 
  change_user character varying(50),
  change_time timestamp without time zone, 
  change_time_valid_until timestamp without time zone NOT NULL DEFAULT now()
);

DROP TABLE administrative.condition_for_rrr;
DROP TABLE administrative.condition_for_rrr_historic;

