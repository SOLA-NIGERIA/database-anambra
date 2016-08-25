update system.config_map_layer set active = false, visible_in_start = false where name = 'sug_hierarchy';

 
update system.config_map_layer set active = false, visible_in_start = false where name = 'road-centerlines-for-parcel-plan';

update administrative.rrr_type set display_value = 'Statutory Right of Occupancy' where code = 'ownership';

update source.administrative_source_type set status = 'c' where code = 'idVerification';

update application.request_type set notation_template = 'Certificate of Occupancy issued at the completion of Systematic Land Title Registration' where code = 'systematicRegn';

delete from application.request_type_requires_source_type where source_type_code = 'sketchMap' and  request_type_code ='systematicRegn';


--9466423a-0a5f-11e6-98cd-001c42ccfbc0
update system.br set display_name = 'app-public-display-complete', feedback = 'The public display period must be completed' where id = 'application-on-approve-check-public-display';

--928bcc7b-0a5f-11e6-a927-001c42ccfbc0
update system.br set display_name = 'app-no-dispute' where id = 'application-on-approve-check-systematic-reg-no-dispute';

--9468b344-0a5f-11e6-98cf-001c42ccfbc0
update system.br set display_name = 'app-public-display-needed' where id = 'application-on-approve-check-systematic-reg-no-pubdisp';

--9233b88a-0a5f-11e6-8465-001c42ccfbc0
update system.br set display_name = 'generate-dispute-nr' where id = 'generate-dispute-nr';

--928969e2-0a5f-11e6-a923-001c42ccfbc0
update system.br set display_name = 'generate-title-nr' where id = 'generate-title-nr';

--0765357e-589f-11e6-a7ba-87e1e0cd4b90
update system.br set display_name = 'generate_ground_rent' where id = 'generate_ground_rent';

--928bcc7e-0a5f-11e6-a92a-001c42ccfbc0
update system.br set display_name = 'new-old-polyg-do-not-overlap' where id = 'new-co-must-not-overlap-with-existing';

--91d14a06-0a5f-11e6-86b9-001c42ccfbc0
update system.br set display_name = 'spatial-unit-group-name-unique' where id = 'spatial-unit-group-name-unique';

--91d295be-0a5f-11e6-86bb-001c42ccfbc0
update system.br set display_name = 'spatial-unit-group-not-overlap' where id = 'spatial-unit-group-not-overlap';


      
	----------------------------------------------------------------------------------------------------------
	--- update the generators

	---'generate-title-nr'

	update system.br_definition
	set  body = 'select sg.id ||''-''|| trim(to_char(nextval(''administrative.title_nr_seq''), ''0000000000'')) AS vl from cadastre.spatial_unit_group sg where sg.hierarchy_level=''2'' and sg.seq_nr >0'
	where br_id = 'generate-title-nr';


	-- generate-dispute-nr
	update system.br_definition
	set  body = 'select sg.id ||''-''||to_char(now(), ''yymm'') || trim(to_char(nextval(''administrative.dispute_nr_seq''), ''0000'')) AS vl from cadastre.spatial_unit_group sg where sg.hierarchy_level=''2'' and sg.seq_nr >0'
	where br_id = 'generate-dispute-nr';


	----------------------------------------------------------------------------------------------------
	---generate-application-nr
	update system.br_definition
	set  body = 'select sg.id ||''-''||to_char(now(), ''yymm'') || trim(to_char(nextval(''application.application_nr_seq''), ''0000'')) AS vl from cadastre.spatial_unit_group sg where sg.hierarchy_level=''2'' and sg.seq_nr >0'
	where br_id = 'generate-application-nr';


	----------------------------------------------------------------------------------------------------
	---'generate-notation-reference-nr'
	update system.br_definition
	set  body = 'select sg.id ||''-''||to_char(now(), ''yymmdd'') || ''-'' || trim(to_char(nextval(''administrative.notation_reference_nr_seq''), ''0000'')) AS vl from cadastre.spatial_unit_group sg where sg.hierarchy_level=''2'' and sg.seq_nr >0'
	where br_id = 'generate-notation-reference-nr';

	----------------------------------------------------------------------------------------------------
	----'generate-rrr-nr'
	update system.br_definition
	set  body = 'select sg.id ||''-''||to_char(now(), ''yymmdd'') || ''-'' || trim(to_char(nextval(''administrative.rrr_nr_seq''), ''0000'')) AS vl from cadastre.spatial_unit_group sg where sg.hierarchy_level=''2'' and sg.seq_nr >0'
	where br_id = 'generate-rrr-nr';

	----------------------------------------------------------------------------------------------------
	-----'generate-source-nr'

	update system.br_definition
	set  body = 'select sg.id ||''-''||to_char(now(), ''yymmdd'') || ''-'' || trim(to_char(nextval(''source.source_la_nr_seq''), ''000000000'')) AS vl from cadastre.spatial_unit_group sg where sg.hierarchy_level=''2'' and sg.seq_nr >0'
	where br_id = 'generate-source-nr';

	----------------------------------------------------------------------------------------------------
	---- 'generate-baunit-nr'
	 
	update system.br_definition
	set  body = 'select sg.id ||''-''||  to_char(now(), ''yymmdd'') || ''-'' ||  trim(to_char(nextval(''administrative.ba_unit_first_name_part_seq''), ''0000''))
	|| ''/'' || trim(to_char(nextval(''administrative.ba_unit_last_name_part_seq''), ''0000'')) AS vl from cadastre.spatial_unit_group sg where sg.hierarchy_level=''2'' and sg.seq_nr >0'
	where br_id = 'generate-baunit-nr';
