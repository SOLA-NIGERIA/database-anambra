DROP TABLE IF EXISTS party.state_type;

CREATE TABLE party.state_type
(
  code character varying(20) NOT NULL,
  display_value character varying(250) NOT NULL,
  status character(1) NOT NULL DEFAULT 't'::bpchar,
  description character varying(555),
  CONSTRAINT state_type_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE party.state_type OWNER TO postgres;
COMMENT ON TABLE party.state_type IS 'Reference Table / Code list of states
LADM Reference Object 
LA_
LADM Definition
State';

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.0.3
-- Dumped by pg_dump version 9.0.3
-- Started on 2014-07-17 16:13:46

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = party, pg_catalog;

--
-- TOC entry 3713 (class 0 OID 1453213)
-- Dependencies: 3389
-- Data for Name: state_type; Type: TABLE DATA; Schema: party; Owner: postgres
--

INSERT INTO state_type (code, display_value, status, description) VALUES ('01', 'Anambra', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('02', 'Adamawa', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('03', 'Abia', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('04', 'Bauchi', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('05', 'Bayelsa', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('06', 'Benue', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('07', 'Borno', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('08', 'Cross River', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('09', 'Delta', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('10', 'Ebonyi', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('11', 'Edo', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('12', 'Ekiti', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('13', 'Gombe', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('14', 'Imo', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('15', 'Jigawa', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('16', 'Kaduna', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('17', 'Kano', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('18', 'Katsina', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('19', 'Kebbi', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('20', 'Kogi', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('21', 'Kwara', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('22', 'Lagos', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('23', 'Nasarawa', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('24', 'Niger', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('25', 'Ogun', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('26', 'Ondo', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('27', 'Osun', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('28', 'Oyo', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('29', 'Plateau', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('30', 'Rivers', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('31', 'Sokoto', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('32', 'Taraba', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('33', 'Yobe', 'c', NULL);
INSERT INTO state_type (code, display_value, status, description) VALUES ('34', 'Zamfara', 'c', NULL);


-- Completed on 2014-07-17 16:13:46

--
-- PostgreSQL database dump complete
--

