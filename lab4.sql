--1
--Znajdź budynki, które zostały wybudowane lub wyremontowane na przestrzeni roku (zmiana
--pomiędzy 2018 a 2019).

CREATE TABLE NewBuildings AS
SELECT b2019.gid, b2019.polygon_id, b2019.name, b2019.type, b2019.height, b2019.geom
FROM t2019_kar_buildings AS b2019
LEFT JOIN t2018_kar_buildings AS b2018
ON b2019.polygon_id = b2018.polygon_id
WHERE b2018.gid IS NULL
   OR b2018.height <> b2019.height
   OR b2018.type <> b2019.type
   OR ST_Equals(b2018.geom, b2019.geom) = false;
select*from NewBuildings;


--2
--Znajdź ile nowych POI pojawiło się w promieniu 500 m od wyremontowanych lub
--wybudowanych budynków, które znalezione zostały w zadaniu 1. Policz je wg ich kategorii.

CREATE TABLE NewPOI AS
SELECT p2019.type, COUNT(*) AS count
FROM t2019_kar_poi_table AS p2019
WHERE EXISTS (
    SELECT 1
    FROM NewBuildings AS b
    WHERE ST_DWithin(b.geom, p2019.geom, 500)
)
GROUP BY p2019.type;

SELECT * FROM NewPOI;

--3
--Utwórz nową tabelę o nazwie ‘streets_reprojected’, która zawierać będzie dane z tabeli
--T2019_KAR_STREETS przetransformowane do układu współrzędnych DHDN.Berlin/Cassini.
CREATE TABLE streets_reprojected AS
SELECT gid, link_id, st_name, ref_in_id, nref_in_id, func_class, speed_Cat,
       fr_speed_l, to_speed_l, dir_travel, ST_Transform(geom, 3068) AS geom
FROM T2019_KAR_STREETS;
select*from streets_reprojected;

--4
--. Stwórz tabelę o nazwie ‘input_points’ i dodaj do niej dwa rekordy o geometrii punktowej.
--Użyj następujących współrzędnych:
CREATE TABLE input_points (
	p_id INT PRIMARY KEY,
	geom GEOMETRY(POINT, 4326)
);
INSERT INTO input_points (p_id, geom)
VALUES
	(1, ST_GeomFromText('POINT(8.36093 49.03174)', 4326)),
	(2, ST_GeomFromText('POINT(8.39876 49.00644)', 4326));
select*from input_points;

--5
--Zaktualizuj dane w tabeli ‘input_points’ tak, aby punkty te były w układzie współrzędnych
--DHDN.Berlin/Cassini. Wyświetl współrzędne za pomocą funkcji ST_AsText().

ALTER TABLE input_points
ALTER COLUMN geom TYPE GEOMETRY(Point, 3068) USING ST_SetSRID(geom, 3068);

UPDATE input_points
SET geom = ST_Transform(geom, 3068);

SELECT p_id, ST_AsText(geom) AS geom_text
FROM input_points;

--6
--Znajdź wszystkie skrzyżowania, które znajdują się w odległości 200 m od linii zbudowanej
--z punktów w tabeli ‘input_points’. Wykorzystaj tabelę T2019_STREET_NODE. Dokonaj
--reprojekcji geometrii, aby była zgodna z resztą tabel
-- Znajdź skrzyżowania w odległości 200 m od linii zbudowanej z punktów
CREATE TABLE Crossings AS
SELECT sn.*
FROM t2019_kar_street_node AS sn
JOIN (
    SELECT ST_MakeLine(geom ORDER BY p_id) AS line
    FROM input_points
) AS line_geom
ON ST_DWithin(ST_Transform(sn.geom, 3068), line_geom.line, 200);

--7
-- Policz jak wiele sklepów sportowych (‘Sporting Goods Store’ - tabela POIs) znajduje się
--w odległości 300 m od parków (LAND_USE_A).
SELECT COUNT(DISTINCT(poi.geom)) FROM T2019_KAR_LAND_USE_A AS lu, T2019_KAR_POI_TABLE AS poi
WHERE
poi.type = 'Sporting Goods Store'
AND ST_DWithin(lu.geom, poi.geom, 300)
AND lu.type = 'Park (City/County)';

--8
-- Znajdź punkty przecięcia torów kolejowych (RAILWAYS) z ciekami (WATER_LINES). Zapisz
--znalezioną geometrię do osobnej tabeli o nazwie ‘T2019_KAR_BRIDGES’.
CREATE TABLE T2019_KAR_BRIDGES AS
(
	SELECT DISTINCT(ST_Intersection(rail.geom, water.geom))
	FROM t2019_kar_railways AS rail,t2019_kar_water_lines AS water
);

SELECT * FROM T2019_KAR_BRIDGES;