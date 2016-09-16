-- DROP VIEW application.sltr_status;
  
CREATE OR REPLACE VIEW application.sltr_status AS 
 SELECT DISTINCT aa.id AS appid, 
        CASE
            WHEN s.status_code::text = 'lodged'::text AND aa.status_code::text = 'lodged'::text THEN 'Sltr Claim application lodged'::text
            WHEN s.status_code::text = 'pending'::text AND aa.status_code::text = 'lodged'::text THEN 'Entering Sltr Claim details'::text
            WHEN s.status_code::text = 'completed'::text AND aa.status_code::text = 'lodged'::text THEN 'Ready for public display'::text
            WHEN s.status_code::text = 'completed'::text AND aa.status_code::text = 'lodged'::text AND swu.public_display_start_date IS NOT NULL AND 'now'::text::date > swu.public_display_start_date AND 'now'::text::date < (swu.public_display_start_date + set.vl::integer) THEN 'In Public Display'::text
            WHEN s.status_code::text = 'completed'::text AND aa.status_code::text = 'approved'::text THEN 'Public Display period completed'::text
            WHEN s.status_code::text = 'completed'::text AND aa.status_code::text = 'approved'::text AND (sg.name::text IN ( SELECT ss.reference_nr
               FROM source.source ss
              WHERE ss.type_code::text = 'title'::text AND ss.reference_nr::text = sg.name::text)) THEN 'Certificates Generated'::text
            ELSE 'other'::text
        END AS sltr_status
   FROM 
    application.application aa, 
    application.service s, 
    cadastre.spatial_unit_group sg, 
    cadastre.sr_work_unit swu,
    system.setting set
  WHERE 
  s.application_id::text = aa.id::text 
  AND s.request_type_code::text = 'systematicRegn'::text 
  AND (s.status_code::text = 'completed'::text OR s.status_code::text = 'pending'::text OR s.status_code::text = 'lodged'::text) 
  ;

ALTER TABLE application.sltr_status
  OWNER TO postgres;
  