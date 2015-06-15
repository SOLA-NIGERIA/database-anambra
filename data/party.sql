--
-- PostgreSQL database dump
--

-- Dumped from database version 9.2.3
-- Dumped by pg_dump version 9.3.1
-- Started on 2015-06-10 17:35:33

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = party, pg_catalog;

--
-- TOC entry 3880 (class 0 OID 597319)
-- Dependencies: 226
-- Data for Name: party; Type: TABLE DATA; Schema: party; Owner: postgres
--

SET SESSION AUTHORIZATION DEFAULT;

ALTER TABLE party DISABLE TRIGGER ALL;
DELETE FROM party;

INSERT INTO party (id, ext_id, type_code, name, last_name, fathers_name, fathers_last_name, alias, gender_code, address_id, id_type_code, id_number, email, mobile, phone, fax, preferred_communication_code, rowidentifier, rowversion, change_action, change_user, change_time, dob, state, nationality) VALUES ('ab43c852-1c7b-4ca5-9e88-b74a75d08ce1', NULL, 'naturalPerson', 'john', 'smith', NULL, NULL, NULL, 'male', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '4aa04e02-6422-4e5f-9c2e-1ce6c6e44682', 1, 'i', 'test', '2015-06-10 17:32:09.344', '1976-06-02', NULL, 'Nigeria');
INSERT INTO party (id, ext_id, type_code, name, last_name, fathers_name, fathers_last_name, alias, gender_code, address_id, id_type_code, id_number, email, mobile, phone, fax, preferred_communication_code, rowidentifier, rowversion, change_action, change_user, change_time, dob, state, nationality) VALUES ('3bb1a694-f077-4495-af5e-374adef4609d', NULL, 'naturalPerson', 'Maggie', 'Joansson', NULL, NULL, NULL, 'female', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'af2249c2-e57d-4cc5-b017-3d6af9f43675', 1, 'i', 'test', '2015-06-10 17:33:12.146', '1977-10-22', NULL, 'Anambra');


ALTER TABLE party ENABLE TRIGGER ALL;

-- Completed on 2015-06-10 17:35:33

--
-- PostgreSQL database dump complete
--

