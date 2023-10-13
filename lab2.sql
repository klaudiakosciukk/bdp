create extension postgis;
create schema lab2;
create database lab2;

create table budynki(id integer primary key not null, geometry geometry, name varchar(20));
create table drogi(id integer primary key not null, geometry geometry, name varchar(20));
create table punkty_info(id integer primary key not null, geometry geometry, name varchar(20));

--budynki
insert into budynki(id, geometry, name) values (1, ST_GeomFromText('POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))',0), 'BuildingA');
insert into budynki(id, geometry, name) values (2, ST_GeomFromText('POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))',0), 'BuildingB');
insert into budynki(id, geometry, name) values (3, ST_GeomFromText('POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))',0), 'BuildingC');
insert into budynki(id, geometry, name) values (4, ST_GeomFromText('POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))',0), 'BuildingD');
insert into budynki(id, geometry, name) values (5, ST_GeomFromText('POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))',0), 'BuildingE');

--select * from budynki

--punkty
insert into punkty_info(id, geometry, name) values (1, ST_GeomFromText('POINT(1 3.5)',0), 'G');
insert into punkty_info(id, geometry, name) values (2, ST_GeomFromText('POINT(5.5 1.5)',0), 'H');
insert into punkty_info(id, geometry, name) values (3, ST_GeomFromText('POINT(9.5 6)',0), 'I');
insert into punkty_info(id, geometry, name) values (4, ST_GeomFromText('POINT(6.5 6)',0), 'J');
insert into punkty_info(id, geometry, name) values (5, ST_GeomFromText('POINT(6 9.5)',0), 'K');

--drogi
insert into drogi(id, geometry, name) values (1, ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)',0), 'RoadX');
insert into drogi(id, geometry, name) values (2, ST_GeomFromText('LINESTRING(7.5 10.5, 7.5 0)',0), 'RoadY');

--6A
SELECT SUM(ST_Length(geometry)) AS "Calkowita długosc drog" FROM drogi;

--6B
SELECT
  ST_AsText(geometry) AS "Geometria (WKT)", --ST_AsEWKT
  ST_Area(geometry) AS "Pole Powierzchni",
  ST_Perimeter(geometry) AS "Obwod"
FROM budynki
WHERE name = 'BuildingA';

--6C
SELECT budynki.name, ST_Area(budynki.geometry) AS Powierzchnia
FROM budynki
ORDER BY budynki.name;

--6D
SELECT budynki.name, ST_Perimeter(budynki.geometry) AS Obwod
FROM budynki
ORDER BY ST_Area(budynki.geometry) desc limit 2;

--6E
SELECT
  ST_Distance(b.geometry, p.geometry) AS "Najkrotsza odległosc"
FROM budynki AS b, punkty_info AS p
WHERE b.name = 'BuildingC' AND p.name = 'G';

--6F
SELECT ST_Area(ST_Difference((SELECT budynki.geometry
				  FROM budynki
				  WHERE budynki.name='BuildingC'), ST_buffer((SELECT budynki.geometry
				  FROM budynki
				  WHERE budynki.name='BuildingB'),0.5))) AS Powierzchnia;

--6G
SELECT budynki.name
FROM budynki, drogi
WHERE ST_Y(ST_Centroid(budynki.geometry)) > ST_Y(ST_Centroid(drogi.geometry)) and drogi.name='RoadX';

--6H
SELECT ST_Area(ST_Symdifference((SELECT budynki.geometry
				  from budynki
				  where budynki.name='BuildingC'),ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))',0))) AS Powierzchnia;
