-- sample 1
DO $$ 
DECLARE
    numero1 INTEGER := 10;
    numero2 INTEGER := 5;
    suma INTEGER;
BEGIN
    suma := numero1 + numero2;
    RAISE NOTICE 'La suma de % y % es %', numero1, numero2, suma;
END;
$$;

-- sample 2
DO $$
DECLARE
    numero INTEGER := 17; -- Cambia este valor al número que quieras verificar
    es_primo BOOLEAN := TRUE;
    divisor INTEGER := 2;
BEGIN
    IF numero <= 1 THEN
        es_primo := FALSE;
    ELSE
        WHILE divisor <= sqrt(numero) LOOP
            IF numero % divisor = 0 THEN
                es_primo := FALSE;
                EXIT;
            END IF;
            divisor := divisor + 1;
        END LOOP;
    END IF;
    
    IF es_primo THEN
        RAISE NOTICE '% es un número primo', numero;
    ELSE
        RAISE NOTICE '% no es un número primo', numero;
    END IF;
END;
$$;

-- sample 3
DO $$
DECLARE
    numero INTEGER := 5; -- Cambia este valor al número para el cual deseas calcular el factorial
    factorial BIGINT := 1;
    i INTEGER;
BEGIN
    IF numero < 0 THEN
        RAISE EXCEPTION 'El factorial no está definido para números negativos';
    END IF;

    FOR i IN 1..numero LOOP
        factorial := factorial * i;
    END LOOP;

    RAISE NOTICE 'El factorial de % es %', numero, factorial;
END;
$$;

-- Crear una tabla temporal para almacenar información sobre los alquileres del mes de enero de 2023
DROP TABLE alquileres_enero_2023;

CREATE TEMPORARY TABLE alquileres_enero_2023 AS
SELECT 
    r.rental_id,
    r.rental_date,
    r.return_date,
    c.first_name AS customer_first_name,
    c.last_name AS customer_last_name,
    f.title AS film_title
FROM
    rental r
    JOIN customer c ON r.customer_id = c.customer_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
WHERE
    EXTRACT(YEAR FROM r.rental_date) = 2005 AND EXTRACT(MONTH FROM r.rental_date) = 5;

-- Realizar consultas en la tabla temporal
SELECT * FROM alquileres_enero_2023;

-- Pivot en posgresql
SELECT 
    customer_id,
    MAX(first_name) AS first_name,
    MAX(last_name) AS last_name,
    MAX(email) AS email,
    MAX(address) AS address,
    MAX(phone) AS phone,
    MAX(city) AS city,
    MAX(country) AS country,
    MAX(zip_code) AS zip_code,
    COUNT(CASE WHEN title = 'Film1' THEN 1 END) AS Film1,
    COUNT(CASE WHEN title = 'Film2' THEN 1 END) AS Film2,
    COUNT(CASE WHEN title = 'Film3' THEN 1 END) AS Film3,
    -- Agregar más columnas para otras películas
    
FROM (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        a.address,
        a.phone,
        ci.city,
        co.country,
        a.postal_code AS zip_code,
        f.title
    FROM
        customer c
        JOIN address a ON c.address_id = a.address_id
        JOIN city ci ON a.city_id = ci.city_id
        JOIN country co ON ci.country_id = co.country_id
        JOIN rental r ON c.customer_id = r.customer_id
        JOIN inventory i ON r.inventory_id = i.inventory_id
        JOIN film f ON i.film_id = f.film_id
) AS subquery
GROUP BY customer_id
ORDER BY customer_id;
-- uso del WITH
WITH AlquileresRecientes AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        r.rental_date,
        COUNT(*) AS cantidad_alquileres
    FROM
        customer c
        JOIN rental r ON c.customer_id = r.customer_id
    WHERE
        r.rental_date >= NOW() - INTERVAL '30 days'
    GROUP BY
        c.customer_id, c.first_name, c.last_name, c.email, r.rental_date
)
SELECT
    ar.customer_id,
    ar.first_name,
    ar.last_name,
    ar.email,
    ar.rental_date,
    ar.cantidad_alquileres
FROM
    AlquileresRecientes ar
ORDER BY
    ar.customer_id, ar.rental_date;
	
-- Pronostico Ventas
CREATE OR REPLACE FUNCTION calcular_pronostico_rentas() RETURNS TABLE (
    fecha date,
    rentas_pronosticadas integer
) AS $$
DECLARE
    fecha_inicio date;
    fecha_fin date;
BEGIN
    -- Definir el período de pronóstico (por ejemplo, próximo mes)
    fecha_inicio := CURRENT_DATE + INTERVAL '1 month';
    fecha_fin := fecha_inicio + INTERVAL '1 month' - INTERVAL '1 day';

    -- Realizar cálculo promedio de rentas en el período
    RETURN QUERY
    SELECT
        fecha,
        ROUND(AVG(rentals), 0) AS rentas_pronosticadas
    FROM (
        SELECT
            DATE_TRUNC('day', rental_date) AS fecha,
            COUNT(*) AS rentals
        FROM
            rental
        WHERE
            rental_date BETWEEN fecha_inicio AND fecha_fin
        GROUP BY
            fecha
    ) subquery
    GROUP BY
        fecha
    ORDER BY
        fecha;
END;
$$ LANGUAGE plpgsql;