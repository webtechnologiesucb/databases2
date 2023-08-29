CREATE TABLE list_actors(
	actor_id INT,
	nombre_completo VARCHAR(100),
	PRIMARY KEY(actor_id));

DELETE FROM list_actors; -- Borrar todas las filas sin reiniciar seriales-autoincrementales

-- TRUNCATE TABLE list_actors; -- Vaciar tabla con reinicio de seriales-autoincrementales

INSERT INTO list_actors(actor_id, nombre_completo)
SELECT actor_id, first_name ||' '|| last_name 
FROM actor;
-- CRUD (altas, lecturas, modificaciones y borrado)

UPDATE list_actors 
SET nombre_completo ='JACK STALLONE'
WHERE actor_id = 44;

DELETE FROM list_actors WHERE actor_id=90; -- borrado fisico

-- borrado logico -> un campo control
ALTER TABLE list_actors ADD vigente INT DEFAULT 1;

UPDATE list_actors SET vigente = 1;

UPDATE list_actors SET vigente = 0
WHERE actor_id=90; -- BORRADO LOGICO

SELECT actor_id, nombre_completo
FROM list_actors 
WHERE vigente = 1; -- todos los registros validos

-- UPDATE MULTIPLE
SELECT a.actor_id, a.last_name
FROM actor a 
INNER JOIN film_actor fa 
ON a.actor_id=fa.actor_id
WHERE a.last_name='GRANT';

-- Reemplazar al actor STALLONE por GRANT en sus PELICULAS
UPDATE film_actor 
SET actor_id= consulta.actor_id
FROM (
	SELECT a.actor_id, fa.film_id 
	FROM actor a 
	INNER JOIN film_actor fa 
	ON a.actor_id=fa.actor_id
	WHERE a.last_name='GRANTI') consulta
WHERE film_actor.actor_id IN (
	SELECT actor_id 
	FROM actor 
	WHERE Last_name='STALLONES') ;

-- borrado multiple
DELETE FROM film_actor  
WHERE actor_id IN (
	SELECT fa.actor_id
	FROM film_actor fa 
	INNER JOIN actor a 
	ON a.actor_id=fa.actor_id
	WHERE a.last_name='MORGAN');

/*
PRACTICA
1. CREAR LA TABLA ListFilmActors
QUE TENGA film_id, title, full_name_actor
2. INSERTAR DATOS
3. ACTUALIZAR LAS PELICULAS DEL ACTOR GRANT A STALLONE
4. ELIMINAR LAS PELICULAS DE 'FREEMAN'
*/

-- 1. CREAR LA TABLA ListFilmActors QUE TENGA film_id, title, full_name_actor
CREATE TABLE ListFilmActors(
	film_id INT, title VARCHAR(255), full_name_actor VARCHAR(255)
);
-- 2. INSERTAR DATOS
INSERT INTO ListFilmActors(film_id,title,full_name_actor)
SELECT f.film_id, f.title, a.first_name ||' '|| a.last_name
FROM actor a 
INNER JOIN film_actor fa ON fa.actor_id = a.actor_id 
INNER JOIN film f ON f.film_id = fa.film_id;
-- 3. ACTUALIZAR LAS PELICULAS DEL ACTOR GRANT A STALLONE
UPDATE film_actor 
SET actor_id= consulta.actor_id
FROM (
	SELECT a.actor_id, fa.film_id 
	FROM actor a 
	INNER JOIN film_actor fa 
	ON a.actor_id=fa.actor_id
	WHERE a.last_name='STALLONE') consulta
WHERE film_actor.actor_id IN (
	SELECT actor_id 
	FROM actor 
	WHERE Last_name='GRANT') ;
-- 4. ELIMINAR LAS PELICULAS DE 'FREEMAN'
DELETE FROM film_actor  
WHERE actor_id IN (
	SELECT fa.actor_id
	FROM film_actor fa 
	INNER JOIN actor a 
	ON a.actor_id=fa.actor_id
	WHERE a.last_name='FREEMAN');
