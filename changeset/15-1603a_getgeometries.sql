-- Function: get_geometry_with_srid(geometry)

-- DROP FUNCTION get_geometry_with_srid(geometry);

CREATE OR REPLACE FUNCTION get_geometry_with_srid(geom geometry)
  RETURNS geometry AS
$BODY$
declare
  srid_found integer;
  x float;
begin
  if (select count(*) from system.crs) = 1 then
    return geom;
  end if;
  x = st_x(st_transform(st_centroid(geom), 4326));
  srid_found = (select srid from system.crs where x >= from_long and x < to_long );
  return st_transform(geom, srid_found);
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION get_geometry_with_srid(geometry)
  OWNER TO postgres;
COMMENT ON FUNCTION get_geometry_with_srid(geometry) IS 'This function assigns a srid found in the settings to the geometry passed as parameter. The srid is chosen based in the longitude where the centroid of the geometry is.';



-- Function: get_geometry_with_srid(geometry, integer)

-- DROP FUNCTION get_geometry_with_srid(geometry, integer);

CREATE OR REPLACE FUNCTION get_geometry_with_srid(geom geometry, hierarchy_level_v integer)
  RETURNS geometry AS
$BODY$
declare
  srid_found integer;
  x float;
 last_part geometry;
 newGeom geometry;
begin

   

  ----if (select count(*) from system.crs) = 1 then
       -- srid_found = (select srid from system.crs);
       -- last_part := ST_SetSRID(geom,srid_found);
  ----end if;
--x = st_x(st_transform(st_centroid(last_part), 4326));
--srid_found = (select srid from system.crs where x >= from_long and x < to_long );

 srid_found = (select srid from system.crs);
 last_part := ST_SetSRID(geom,srid_found);
  
return  ST_Transform(
   ST_GeomFromText(
   ST_AsText(last_part),4326),32632);  ---3857
end;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION get_geometry_with_srid(geometry, integer)
  OWNER TO postgres;
COMMENT ON FUNCTION get_geometry_with_srid(geometry, integer) IS 'This function assigns a srid found in the settings to the geometry passed as parameter. The srid is chosen based in the longitude where the centroid of the geometry is.';
