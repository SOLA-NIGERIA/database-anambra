ALTER TABLE administrative.ba_unit
  ADD COLUMN address_for_notice character varying(255);
ALTER TABLE administrative.ba_unit_historic
  ADD COLUMN address_for_notice character varying(255);
INSERT INTO system.version SELECT '1608a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1608a');