
ALTER TABLE application.request_type
  ADD COLUMN "display_group_code" character varying(20);
  
ALTER TABLE application.request_type
  ADD COLUMN "service_panel_code" character varying(20);

ALTER TABLE application.request_type
  ADD COLUMN "sdisplay_order" integer;

ALTER TABLE administrative.rrr_type
  ADD COLUMN "rrr_panel_code" character varying(20);





INSERT INTO system.setting(
            name, vl, active, description)
    VALUES ('product-code', 'ssr', true, 'SOLA product code. sr - SOLA Registry, ssr - SOLA Systematic Registration, ssl - SOLA State Land, scs - SOLA Community Server');
INSERT INTO system.setting(
            name, vl, active, description)
    VALUES ('product-name', 'SOLA Systematic Registration', true, 'SOLA product name');


INSERT INTO system.setting(
            name, vl, active, description)
    VALUES ('ot-community-area','POLYGON((7.101600587066585 6.188732761678772,7.101600587066585 6.179175661205594,7.117050110992304 6.180455640034611,7.117736756500165 6.18950073546694,7.101600587066585 6.188732761678772))',TRUE,'Open Tenure community area where parcels can be claimed'
);



-- Table: application.request_display_group

-- DROP TABLE application.request_display_group;

CREATE TABLE application.request_display_group
(
  code character varying(20) NOT NULL, -- The code for the request display group.
  display_value character varying(250) NOT NULL, -- Displayed value of the request display group.
  description text, -- Description of the request display group.
  status character(1) NOT NULL, -- Status of the negotiation type (c - current, x - no longer valid).
  CONSTRAINT request_display_group_pkey PRIMARY KEY (code),
  CONSTRAINT request_display_group_display_value_unique UNIQUE (display_value)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE application.request_display_group
  OWNER TO postgres;
COMMENT ON TABLE application.request_display_group
  IS 'Code list identifying the display groups that can be used for request types
Tags: SOLA State Land Extension, Reference Table';
COMMENT ON COLUMN application.request_display_group.code IS 'The code for the request display group.';
COMMENT ON COLUMN application.request_display_group.display_value IS 'Displayed value of the request display group.';
COMMENT ON COLUMN application.request_display_group.description IS 'Description of the request display group.';
COMMENT ON COLUMN application.request_display_group.status IS 'Status of the negotiation type (c - current, x - no longer valid).';

-- Table: system.panel_launcher_group

-- DROP TABLE system.panel_launcher_group;

CREATE TABLE system.panel_launcher_group
(
  code character varying(20) NOT NULL, -- The code for the panel launcher group
  display_value character varying(500) NOT NULL, -- The user friendly name for the panel launcher group
  description character varying(1000), -- Description for the panel launcher group
  status character(1) NOT NULL DEFAULT 't'::bpchar, -- Status of this panel launcher group
  CONSTRAINT panel_launcher_group_pkey PRIMARY KEY (code),
  CONSTRAINT panel_launcher_group_display_value_unique UNIQUE (display_value)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE system.panel_launcher_group
  OWNER TO postgres;
COMMENT ON TABLE system.panel_launcher_group
  IS 'Used to group the panel launcher configuration values to make the PanelLancher logic flexible. 
Tags: FLOSS SOLA Extension, Reference Table';
COMMENT ON COLUMN system.panel_launcher_group.code IS 'The code for the panel launcher group';
COMMENT ON COLUMN system.panel_launcher_group.display_value IS 'The user friendly name for the panel launcher group';
COMMENT ON COLUMN system.panel_launcher_group.description IS 'Description for the panel launcher group';
COMMENT ON COLUMN system.panel_launcher_group.status IS 'Status of this panel launcher group';



-- Table: system.config_panel_launcher

-- DROP TABLE system.config_panel_launcher;

CREATE TABLE system.config_panel_launcher
(
  code character varying(20) NOT NULL, -- The code for the panel to launch
  display_value character varying(500) NOT NULL, -- The user friendly name for the panel to launch
  description character varying(1000), -- Description for the panel to launch
  status character(1) NOT NULL DEFAULT 't'::bpchar, -- Status of this configuration record.
  launch_group character varying(20) NOT NULL, -- The launch group for the panel.
  panel_class character varying(100), -- The full package and class name for the panel to launch. e.g. org.sola.clients.swing.desktop.administrative.PropertyPanel
  message_code character varying(50), -- The code of the message to display when opening the panel. See the ClientMessage class for a list of codes.
  card_name character varying(50), -- The MainContentPanel card name for the panel to launch
  CONSTRAINT config_panel_launcher_pkey PRIMARY KEY (code),
  CONSTRAINT config_panel_launcher_launch_group_fkey FOREIGN KEY (launch_group)
      REFERENCES system.panel_launcher_group (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT config_panel_launcher_display_value_unique UNIQUE (display_value)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE system.config_panel_launcher
  OWNER TO postgres;
COMMENT ON TABLE system.config_panel_launcher
  IS 'Configuration data used by the PanelLauncher to determine the appropriate panel or form to display to the user when starting a Service or opening an RRR. 
Tags: FLOSS SOLA Extension, Reference Table';
COMMENT ON COLUMN system.config_panel_launcher.code IS 'The code for the panel to launch';
COMMENT ON COLUMN system.config_panel_launcher.display_value IS 'The user friendly name for the panel to launch';
COMMENT ON COLUMN system.config_panel_launcher.description IS 'Description for the panel to launch';
COMMENT ON COLUMN system.config_panel_launcher.status IS 'Status of this configuration record.';
COMMENT ON COLUMN system.config_panel_launcher.launch_group IS 'The launch group for the panel.';
COMMENT ON COLUMN system.config_panel_launcher.panel_class IS 'The full package and class name for the panel to launch. e.g. org.sola.clients.swing.desktop.administrative.PropertyPanel';
COMMENT ON COLUMN system.config_panel_launcher.message_code IS 'The code of the message to display when opening the panel. See the ClientMessage class for a list of codes. ';
COMMENT ON COLUMN system.config_panel_launcher.card_name IS 'The MainContentPanel card name for the panel to launch';


-- Index: system.config_panel_launcher_launch_group_fkey_ind

-- DROP INDEX system.config_panel_launcher_launch_group_fkey_ind;

CREATE INDEX config_panel_launcher_launch_group_fkey_ind
  ON system.config_panel_launcher
  USING btree
  (launch_group COLLATE pg_catalog."default");
  
 
-- View: system.user_pword_expiry

-- DROP VIEW system.user_pword_expiry;

CREATE OR REPLACE VIEW system.user_pword_expiry AS 
 WITH pw_change_all AS (
                 SELECT u.username, u.change_time, u.change_user, u.rowversion
                   FROM system.appuser u
                  WHERE NOT (EXISTS ( SELECT uh2.id
                           FROM system.appuser_historic uh2
                          WHERE uh2.username::text = u.username::text AND uh2.rowversion = (u.rowversion - 1) AND uh2.passwd::text = u.passwd::text))
        UNION 
                 SELECT uh.username, uh.change_time, uh.change_user, 
                    uh.rowversion
                   FROM system.appuser_historic uh
                  WHERE NOT (EXISTS ( SELECT uh2.id
                           FROM system.appuser_historic uh2
                          WHERE uh2.username::text = uh.username::text AND uh2.rowversion = (uh.rowversion - 1) AND uh2.passwd::text = uh.passwd::text))
        ), pw_change AS (
         SELECT pall.username AS uname, pall.change_time AS last_pword_change, 
            pall.change_user AS pword_change_user
           FROM pw_change_all pall
          WHERE pall.rowversion = (( SELECT max(p2.rowversion) AS max
                   FROM pw_change_all p2
                  WHERE p2.username::text = pall.username::text))
        )
 SELECT p.uname, p.last_pword_change, p.pword_change_user, 
        CASE
            WHEN (EXISTS ( SELECT r.username
               FROM system.user_roles r
              WHERE r.username::text = p.uname::text AND (r.rolename::text = ANY (ARRAY['ManageSecurity'::character varying::text, 'NoPasswordExpiry'::character varying::text])))) THEN true
            ELSE false
        END AS no_pword_expiry, 
        CASE
            WHEN s.vl IS NULL THEN NULL::integer
            ELSE p.last_pword_change::date - now()::date + s.vl::integer
        END AS pword_expiry_days
   FROM pw_change p
   LEFT JOIN system.setting s ON s.name::text = 'pword-expiry-days'::text AND s.active;

ALTER TABLE system.user_pword_expiry
  OWNER TO postgres;
COMMENT ON VIEW system.user_pword_expiry
  IS 'Determines the number of days until the users password expires. Once the number of days reaches 0, users will not be able to log into SOLA unless they have the ManageSecurity role (i.e. role to change manage user accounts) or the NoPasswordExpiry role. To configure the number of days before a password expires, set the pword-expiry-days setting in system.setting table. If this setting is not in place, then a password expiry does not apply.';



-- View: system.active_users

-- DROP VIEW system.active_users;

CREATE OR REPLACE VIEW system.active_users AS 
 SELECT u.username, u.passwd
   FROM system.appuser u, system.user_pword_expiry ex
  WHERE u.active = true AND ex.uname::text = u.username::text AND (COALESCE(ex.pword_expiry_days, 1) > 0 OR ex.no_pword_expiry = true);

ALTER TABLE system.active_users
  OWNER TO postgres;
COMMENT ON VIEW system.active_users
  IS 'Identifies the users currently active in the system. If the users password has expired, then they are treated as inactive users, unless they are System Administrators. This view is intended to replace the system.appuser table in the SolaRealm configuration in Glassfish.';
