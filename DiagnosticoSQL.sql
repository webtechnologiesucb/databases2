-- 1.	Películas ‘Épicas’ (Epic) o ‘Brillantes’ (brilliant) que duren más de 180 minutos
SELECT f.title, f.length 
FROM film f, film_category fc, category c
WHERE f.length>180 AND fc.film_id = f.film_id AND fc.category_id = c.category_id 
AND (lower(c."name")= 'epic' OR lower(c."name")= 'brilliant');

-- 2.	Películas que cuesten 0.99, 2.99 y tengan un rating ‘g’ o ‘r’ y que hablen de cocodrilos (cocodrile)
SELECT f.title, f.rental_rate, f.rating
FROM film f 
WHERE f.rental_rate IN(0.99,2.99) AND f.rating IN('G','R') 
AND lower(f.title) LIKE '%cocodrile%';

-- 3.	Obtener en cuántas películas ha participado cada actor. 
SELECT a.first_name, a.last_name, count(a.actor_id) total_peliculas
FROM actor a 
INNER JOIN film_actor fa ON fa.actor_id = a.actor_id 
GROUP BY a.first_name, a.last_name;

-- 4.	Generar una consulta que regresa todas las películas que duran 2 horas junto con los actores que participaron en cada película. 
SELECT f.title, a.first_name, a.last_name
FROM actor a 
INNER JOIN film_actor fa ON fa.actor_id = a.actor_id 
INNER JOIN film f ON f.film_id = fa.film_id
WHERE f.length = 120;

-- 5.	Se desea saber con cuáles actores han trabajado con cierto actor Stallone. 
SELECT a.first_name ||' '|| a.last_name Actores, f.title Pelicula
FROM actor a 
INNER JOIN film_actor fa ON fa.actor_id = a.actor_id 
INNER JOIN film f ON f.film_id = fa.film_id
AND fa.film_id IN(
	SELECT fa.film_id
	FROM actor a
	INNER JOIN film_actor fa ON fa.actor_id = a.actor_id
	WHERE lower(a.last_name)='stallone')

-- 6.	Mostrar la consulta y el resultado que obtenga el par de actores que han trabajado en más películas juntos. Por ejemplo, quizá Cristopher y Bela Walken han trabajado en 50 películas. La consulta debe regresar a los dos actores y el número de películas 
SELECT CONCAT(a1.first_name, ' ', a1.last_name) actor1,
       CONCAT(a2.first_name, ' ', a2.last_name) actor2,
       COUNT(*) veces_actuaron_juntos
FROM film_actor fa1
JOIN film_actor fa2 ON fa1.film_id = fa2.film_id AND fa1.actor_id < fa2.actor_id
JOIN actor a1 ON fa1.actor_id = a1.actor_id
JOIN actor a2 ON fa2.actor_id = a2.actor_id
GROUP BY actor1, actor2
HAVING COUNT(*) > 1
ORDER BY veces_actuaron_juntos DESC;

-- 7.	Obtener el promedio de rentas por día de la semana.
SET lc_time = 'es_ES';

SELECT to_char(r.rental_date, 'Day') AS dia_semana,
       AVG(p.amount) AS promedio_renta
FROM rental r
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY to_char(r.rental_date, 'Day') 
ORDER BY to_char(r.rental_date, 'Day');

-- 8.	Clientes que alquilaron películas para ello debemos utilizar inner join entre las tablas CUSTOMER y rental 
SELECT c.customer_id, c.first_name||' '|| c.last_name nomcliente, COUNT(r.rental_id) total_alquileres
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name||' '|| c.last_name
ORDER BY total_alquileres DESC;

-- 9.	Obtener el cliente que más películas ha alquilado. 
SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id) AS total_alquileres
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_alquileres DESC
LIMIT 1;

-- 10.	Queremos saber que alquileres están atrasados en su devolución, para ello debemos buscar en la tabla del rental las peliculas con una fecha de regreso = null, y que la fecha de alquiler supere el tiempo o cantidad de dias establecidos que puede conservar el cliente la pelicula. 
SELECT r.rental_id, c.first_name AS cliente_nombre, c.last_name AS cliente_apellido,
       i.inventory_id, f.title AS titulo_pelicula, r.rental_date, r.return_date AS fecha_devolucion_esperada
FROM rental r
INNER JOIN customer c ON r.customer_id = c.customer_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f ON i.film_id = f.film_id
WHERE r.return_date < NOW() AND r.return_date IS NOT NULL;
