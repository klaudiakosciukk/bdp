create extension postgis;

select*from alaska;

--1
select count(popp.f_codedesc) as budynki
into tabelaB
from popp, majrivers
where ST_DWithin(popp.geom, majrivers.geom, 1000.0) and f_codedesc='Building';
select*from tabelaB;

--2
select airports.name, airports.geom,airports.elev
into table airportsNew
from airports;
select*from airportsnew;

--a
select (select airportsNew.name
	from airportsNew
	order by st_Ymin(geom) limit 1) as wschod,
	(select airportsNew.name
	 from airportsNew
	order by st_Ymin(geom) desc limit 1) as zachod;

--b
insert into airportsNew values (
    'airportB',
    (select st_centroid (
    ST_MakeLine (
        (select geom from airportsNew where name = 'NIKOLSKI AS'),
        (select geom from airportsNew where name = 'NOATAK')
    ))),
	2115);

select * from airportsNew;

--G
select ST_area(St_buffer(st_ShortestLine(airports.geom, lakes.geom), 1000)) as pole
from airports, lakes
where lakes.names='Iliamna Lake' and airports.name='AMBLER';

--7
select vegdesc as typ, Sum(ST_Area(trees.geom)) as powierzchnia
from trees,swamp,tundra
where ST_Contains(tundra.geom, trees.geom) or ST_Contains(swamp.geom, trees.geom)
group by vegdesc;
