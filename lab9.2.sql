create extension postgis;
create extension postgis_raster;

SELECT * FROM public."eksporty";

-- Tworzenie tabeli dla wyników scalenia
CREATE TABLE public.MergedResults AS
SELECT 
  ST_Union(geom) AS merged_geom -- Kolumna dla scalonej geometrii
FROM 
  public."eksporty";

SELECT * FROM public.MergedResults;
Select *FROM public.ex4;