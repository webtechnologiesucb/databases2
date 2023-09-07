-- Crear una tabla temporal llamada rental_temp 
que almacena alquileres del último mes.

CREATE TEMP TABLE rental_temp AS
SELECT *
FROM rental
WHERE rental_date >= now() - interval '216 month';

SELECT *
FROM rental_temp;
