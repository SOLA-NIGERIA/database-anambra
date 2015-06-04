CREATE OR REPLACE FUNCTION cadastre.get_new_cadastre_object_identifier_first_part(
 last_part varchar
  , cadastre_object_type varchar
) RETURNS varchar 
AS $$
declare
newseqnr integer;
parcel_number_exists integer;
val_to_return character varying;

apponewseqnr  character varying;
   
begin
   if last_part != 'NO LGA/WARD' then    
          
          select cadastre.spatial_unit_group.seq_nr+1
          into newseqnr
          from cadastre.spatial_unit_group
          where name=last_part
          and cadastre.spatial_unit_group.hierarchy_level = 3;

          select count (*) 
          into parcel_number_exists
          from cadastre.cadastre_object
          where name_firstpart||name_lastpart= newseqnr||last_part;
        if parcel_number_exists > 0 then
          select max (name_firstpart)
          into apponewseqnr
          from  cadastre.cadastre_object
          where name_lastpart= last_part;
          apponewseqnr:= replace( apponewseqnr, 'X ', '0');
          apponewseqnr:= replace( apponewseqnr, 'NC', '0');
          newseqnr:=apponewseqnr;
          newseqnr:=newseqnr+1;
        end if;  

          
      if newseqnr is not null then

          update cadastre.spatial_unit_group
          set seq_nr = newseqnr
          where name=last_part
          and cadastre.spatial_unit_group.hierarchy_level = 3;
      end if;
   else
       RAISE EXCEPTION 'no_lga/ward_found';

   end if;

  val_to_return := 'X '||newseqnr;
  return val_to_return;        
end;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION cadastre.get_new_cadastre_object_identifier_first_part(
 last_part varchar
  , cadastre_object_type varchar
) IS 'This function generates the first part of the cadastre object identifier.
It has to be overridden to apply the algorithm specific to the situation.';

-- Function cadastre.get_new_cadastre_object_identifier_last_part --
CREATE OR REPLACE FUNCTION cadastre.get_new_cadastre_object_identifier_last_part(
 geom geometry
  , cadastre_object_type varchar
) RETURNS varchar 
AS $$
declare
last_part geometry;
val_to_return character varying;
srid_found integer;
begin
  
  srid_found = (select srid from system.crs);
  
   
   last_part := ST_SetSRID(geom,srid_found);

   select name 
   into val_to_return
   from cadastre.spatial_unit_group sg
   where ST_Intersects(ST_PointOnSurface(last_part), sg.geom)
   and sg.hierarchy_level = 3
   ;

   if val_to_return is null then
    val_to_return := 'NO LGA/WARD';
   end if;

  return val_to_return;
end;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION cadastre.get_new_cadastre_object_identifier_last_part(
 geom geometry
  , cadastre_object_type varchar
) IS 'This function generates the last part of the cadastre object identifier.
It has to be overridden to apply the algorithm specific to the situation.';
    