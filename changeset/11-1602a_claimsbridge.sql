
INSERT INTO source.administrative_source_type(
            code, display_value, status, description, is_for_registration)
    VALUES ('claimForm', 'OT Claim Summary', 'c', 'Extension to LADM to link opentenure claims', false);


INSERT INTO application.request_type_requires_source_type(
            source_type_code, request_type_code)
    VALUES ('claimForm', 'systematicRegn');


