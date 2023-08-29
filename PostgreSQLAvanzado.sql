-- Funciones

-- Funcion Escalar: Calcular ingresos por cliente
CREATE OR REPLACE FUNCTION calcular_total_ingresos
(cliente_id integer)
RETURNS numeric AS $$
DECLARE
 total_ingresos numeric := 0;
BEGIN
 SELECT SUM(amount) INTO total_ingresos
 FROM payment
 WHERE customer_id = cliente_id;
 RETURN total_ingresos;
END;
$$ LANGUAGE plpgsql;
-- uso de la funcion
SELECT calcular_total_ingresos(3) ingresos_cliente;

-- Funcion Tabular: Obtener las peliculas alquiladas por clientes
DROP FUNCTION obtener_peliculas_alquiladas;

CREATE OR REPLACE FUNCTION obtener_peliculas_alquiladas
(cliente_id integer)
RETURNS TABLE (pelicula_id integer, titulo varchar(255)) 
AS $$
BEGIN
 RETURN QUERY
 SELECT f.film_id, f.title
 FROM film f
 JOIN inventory i ON f.film_id = i.film_id
 JOIN rental r ON i.inventory_id = r.inventory_id
 WHERE r.customer_id = cliente_id;
END;
$$ LANGUAGE plpgsql;
-- uso de la funcion
SELECT * FROM obtener_peliculas_alquiladas(3);

-- Triggers
-- AFTER INSERT/UPDATE: Trigger para Mantener un Registro de Cambios en Alquileres
-- Crear la tabla para almacenar los logs 
CREATE TABLE alquileres_log (accion VARCHAR(255), fecha DATE, rental_id INT);
-- Crear la funcion base del trigger
CREATE OR REPLACE FUNCTION registro_cambios_alquileres()
RETURNS TRIGGER AS $$
BEGIN
INSERT INTO alquileres_log (accion, fecha, rental_id)
VALUES (TG_OP, NOW(), NEW.rental_id);
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- crear el trigger que invoca a la funcion anterior
CREATE TRIGGER alquileres_registro
AFTER INSERT OR UPDATE ON rental
FOR EACH ROW
EXECUTE FUNCTION registro_cambios_alquileres();
-- hacemos un UPDATE para probar
UPDATE rental SET return_date = now() WHERE rental_id = 1;
-- mostrar la tabla destino del trigger alquileres_log
SELECT * 
FROM alquileres_log;

-- 2. DELETE: Trigger para Evitar Eliminación de Películas
-- crear la funcion base del trigger para bloquear eliminacion
CREATE OR REPLACE FUNCTION evitar_eliminacion_peliculas()
RETURNS TRIGGER AS $$
BEGIN
IF OLD.rating = 'PG-13' OR OLD.rating = 'R' THEN
RAISE EXCEPTION 'No se permite eliminar películas con clasificación PG-13 o R';
ELSE
RETURN OLD;
END IF;
END;
$$ LANGUAGE plpgsql;
-- crear el trigger que invoca a la funcion anterior
CREATE TRIGGER peliculas_evitar_eliminacion
BEFORE DELETE ON film
FOR EACH ROW
EXECUTE FUNCTION evitar_eliminacion_peliculas();
-- Probamos el borrado, el mensaje sale como una excepcion forzada
DELETE FROM film WHERE film_id = 7;

-- Vistas
-- 1. Crear una vista con las peliculas populares de acuerdo a la cantidad de veces alquiladas.
CREATE OR REPLACE VIEW peliculas_populares AS
SELECT f.film_id, f.title, COUNT(r.rental_id) AS veces_alquilada
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id, f.title
ORDER BY veces_alquilada DESC;
-- consultar la vista creada
SELECT * 
FROM peliculas_populares;
-- 2. Vista de Clientes y Sus Últimos Alquileres
CREATE OR REPLACE VIEW clientes_ultimos_alquileres AS
SELECT c.customer_id, c.first_name || ' ' || c.last_name AS nombre_cliente,
 r.rental_date, f.title AS pelicula_alquilada
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE r.rental_date = (SELECT MAX(rental_date) FROM rental WHERE customer_id =
c.customer_id)
ORDER BY c.customer_id;
-- consultar la vista creada
SELECT * 
FROM clientes_ultimos_alquileres;

-- Procedimientos almacenados 
-- Cargar campos a la tabla rental
ALTER TABLE rental ADD rental_rate NUMERIC(9,2) DEFAULT 2.5;
ALTER TABLE rental ADD rental_fee NUMERIC(9,2) DEFAULT 0.0;
-- Crear el procedimiento para Actualizar el Alquiler y la Devolución de una Película
-- Supongamos que deseamos crear un procedimiento almacenado que actualice la fecha de devolución 
-- y el cargo por alquiler en la tabla rental cuando se devuelve una película.
CREATE OR REPLACE PROCEDURE devolver_pelicula(p_rental_id integer)
LANGUAGE plpgsql
AS $$
BEGIN
 UPDATE rental
 SET return_date = CURRENT_TIMESTAMP,
 rental_fee = rental_rate * 
 DATE_PART('day', CURRENT_TIMESTAMP - rental_date)
 WHERE rental_id = p_rental_id;
END;
$$;
-- ejecutamos el procedimiento almacenado
CALL devolver_pelicula(2);
-- revisamso los cambios efectuados por el procedimiento
SELECT rental_rate, rental_fee FROM rental WHERE rental_id=2;

-- recuperar codigo de un proc/vista/funcion
SELECT pg_get_functiondef(oid) -- funcion para ver def.
FROM pg_proc
WHERE proname = 'devolver_pelicula';

-- Procedimiento para Obtener Detalles de un Cliente
CREATE OR REPLACE PROCEDURE obtener_detalle_cliente
(p_customer_id integer, INOUT _result_one refcursor = 'rs_resultone')
LANGUAGE plpgsql
AS $$
BEGIN
 open _result_one for
 SELECT first_name, last_name, email/*, address, city, country*/
 FROM customer
 WHERE customer_id = p_customer_id;
END;
$$;
-- Invocamos al procedimiento especial ejecutando las dos siguientes consultas juntas
CALL obtener_detalle_cliente(3);
FETCH ALL FROM "rs_resultone";
 
-- Procedimiento para obtener datos generados desde PL-PGSQL
 CREATE OR REPLACE PROCEDURE test_get_data_single(
    _itemID int, 
    INOUT _message text = '', 
    INOUT _result_one refcursor = 'rs_resultone',
    INOUT _returnCode text = '')
LANGUAGE plpgsql
AS
$$
BEGIN
    _message := 'Test message for item ' || COALESCE(_itemID, 0);
    _returnCode := '';

  open _result_one for 
    SELECT * 
    FROM (values (1,2,3, 'fruit', current_timestamp - INTERVAL '5 seconds'), 
                 (4,5,6, 'veggie', current_timestamp)) as t(a,b,c,d,e);

END;
$$;
-- Ejecucion
    CALL test_get_data_single(2);
    FETCH ALL FROM "rs_resultone";