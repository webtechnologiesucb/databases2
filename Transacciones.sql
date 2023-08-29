BEGIN; -- Iniciar la transacción

-- Declarar variables para los IDs de cliente, película e inventario
DECLARE
    customer_id integer;
    film_id integer;
    inventory_id integer;
BEGIN
    -- Obtener el ID del cliente y la película (puedes ajustar estos valores)
    SELECT customer_id INTO customer_id FROM customer WHERE email = 'cliente@example.com';
    SELECT film_id INTO film_id FROM film WHERE title = 'Película de ejemplo';

    -- Verificar si hay inventario disponible para la película
    SELECT inventory_id INTO inventory_id
    FROM inventory
    WHERE film_id = film_id AND store_id = 1 AND NOT rented;

    IF inventory_id IS NULL THEN
        RAISE EXCEPTION 'No hay inventario disponible para la película seleccionada';
    END IF;

    -- Registrar el alquiler
    INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id)
    VALUES (NOW(), inventory_id, customer_id, 1);

    -- Marcar el inventario como alquilado
    UPDATE inventory SET rented = TRUE WHERE inventory_id = inventory_id;

    COMMIT; -- Confirmar la transacción exitosa
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- Revertir la transacción en caso de error
        RAISE; -- Relanzar la excepción para que se propague
END;

CREATE OR REPLACE FUNCTION obtener_alquileres(tabla text) RETURNS SETOF rental AS $$
DECLARE
    query text;
BEGIN
    -- Construir la consulta SQL dinámica
    query := 'SELECT * FROM ' || tabla;

    -- Ejecutar la consulta dinámica
    RETURN QUERY EXECUTE query;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dynamic_sql_example(table_name text) RETURNS void AS $$
BEGIN
    -- Define a dynamic SQL command
    EXECUTE 'DELETE FROM ' || table_name || ' WHERE rental_date < $1'
    USING now() - interval '30 days';
END;
$$ LANGUAGE plpgsql;