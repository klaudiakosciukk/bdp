
create extension postgis;
create extension postgis_raster;
SELECT PostGIS_Version();

SELECT * FROM public."Exports";

-- Tworzenie tabeli dla wyników scalenia
CREATE TABLE public.MergedResults AS
SELECT 
  ST_Union(geom) AS merged_geom -- Kolumna dla scalonej geometrii
FROM 
  public."Exports";

SELECT * FROM public.MergedResults;
