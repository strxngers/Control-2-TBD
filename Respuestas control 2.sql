-- Desarrollo control 2 TBD
-- Integrantes Grupo 1: Elena Guzmán, Paolo Demarchi, Ignacio Moreira, Fernando Pérez, Gaspar Catalán.

-- Pregunta 1:
-- Se le agrega a la tabla minimarkets_gs una columna en la que se tienen las ubicaciones como punto
ALTER TABLE minimarkets_gs ADD COLUMN geom GEOMETRY;
UPDATE minimarkets_gs SET geom = ST_SetSRID(ST_MakePoint(longitud,latitud),4326);

-- Se elimina la tabla si existe una con este nombre anteriormente
DROP TABLE IF EXISTS zc_500m;

-- Creación de tabla con todas las zonas censales que se encuentren a menos de 500 metros de algún minimarket
CREATE TABLE zc_500m AS(
	SELECT zona.id, zona.comuna, zona.nom_comuna, zona.geom, zona.cod_distri, zona.cod_zona, zona.geocodigo, zona.shape_leng, zona.shape_area
	FROM zonas_censales_gs AS zona
	LEFT JOIN minimarkets_gs mini ON ST_DWithin(ST_Transform(mini.geom, 32719), zona.geom, 500)
	WHERE mini.nombre IS NULL);
	
	
	
-- Pregunta 2:

-- Se elimina la tabla si existe una con este nombre anteriormente
DROP TABLE IF EXISTS comunas_ptje_mini;

-- Creación tabla de porcentajes por comuna en cuanto a las áreas de censales en las 
-- cuales habia una distancia mayor a 500 metros
-- Para calcular el porcentaje de cada comuna debemos obtener el total de zonas censales
-- y luego el total de zonas censales por comuna
-- Y finalmente para obtener el porcentaje se debe dividir 
-- el total de zonas censales por comuna en el total de zonas censales y se multiplica por 100
CREATE TABLE comunas_ptje_mini AS
SELECT z1.comuna, z1.nom_comuna,
       ROUND((z1.total * 100.0 / z2.total),2) AS porcentaje
FROM (
    SELECT z.comuna, z.nom_comuna, COUNT(z.id) AS total
    FROM zc_500m AS z
    GROUP BY z.comuna, z.nom_comuna
) AS z1
JOIN (
    SELECT z.comuna, z.nom_comuna, COUNT(z.id) AS total
    FROM zonas_censales_gs AS z
    GROUP BY z.comuna, z.nom_comuna
) AS z2 ON z1.comuna = z2.comuna
        AND z1.nom_comuna = z2.nom_comuna;


