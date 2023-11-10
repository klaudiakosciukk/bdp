create database lab6;
create schema cw6;
create extension postgis;

--0
Create table obiekty(id int primary key, name varchar(15), geom geometry);

insert into obiekty(id, name, geom) values(1,'obiekt1', St_GeomFromEWKT('SRID=0;MULTICURVE(LINESTRING(0 1, 1 1),
CIRCULARSTRING(1 1,2 0, 3 1), CIRCULARSTRING(3 1, 4 2, 5 1),LINESTRING(5 1, 6 1))'));

insert into obiekty(id, name, geom) values(2,'obiekt2', ST_GeomFromEWKT('SRID=0;CURVEPOLYGON(COMPOUNDCURVE(LINESTRING(10 6, 14 6), CIRCULARSTRING(14 6, 16 4, 14 2),
							  CIRCULARSTRING(14 2, 12 0, 10 2), LINESTRING(10 2, 10 6)), CIRCULARSTRING(11 2, 13 2, 11 2))'));

insert into obiekty(id, name, geom) values(3,'obiekt3', ST_GeomFromEWKT('SRID=0;POLYGON((7 15, 10 17, 12 13, 7 15))'));

insert into obiekty(id, name, geom) values(4,'obiekt4', ST_GeomFromEWKT('SRID=0;MULTILINESTRING((20 20, 25 25), (25 25, 27 24), (27 24, 25 22),
							  (25 22, 26 21), (26 21, 22 19), (22 19, 20.5 19.5))'));

insert into obiekty(id, name, geom) values(5,'obiekt5', ST_GeomFromEWKT('SRID=0; MULTIPOINT((30 30 59),(38 32 234))'));

insert into obiekty(id, name, geom) values(6, 'obiekt6', ST_GeomFromEWKT('SRID=0; GEOMETRYCOLLECTION(LINESTRING(1 1, 3 2),POINT(4 2))'));


--1
select ST_Area(ST_Buffer(ST_ShortestLine(ob3.geom, ob4.geom), 5)) as Pole
from obiekty as ob3, obiekty as ob4
where ob3.name = 'obiekt3' and ob4.name = 'obiekt44';

--2
select ST_GeometryType(ob.geom) from obiekty as ob where ob.name='obiekt4';
--sprawdzenie czy jest closed
SELECT ST_IsClosed((ST_Dump(geom)).geom) AS is_closed
FROM obiekty
WHERE name = 'obiekt4';
--nie jest
UPDATE obiekty
SET geom = ST_MakePolygon(ST_LineMerge(ST_CollectionHomogenize(ST_Collect(geom, 'LINESTRING(20.5 19.5, 20 20)'))))
WHERE name = 'obiekt4';


--3
insert into obiekty values (7, 'obiekt7', ST_Collect((SELECT geom FROM obiekty WHERE name = 'obiekt3'),
                                                     (SELECT geom FROM obiekty WHERE name = 'obiekt4')));

SELECT * FROM obiekty;

--4
select Sum(ST_Area(ST_Buffer(obiekty.geom, 5))) as totalpole
from obiekty
where ST_HasArc(obiekty.geom)=false;
