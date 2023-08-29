CREATE OR REPLACE FUNCTION actualizar_con_transaccion() RETURNS void AS
$$
DECLARE
    registros_afectados integer;
BEGIN
    -- Iniciar la transacción
    BEGIN;
    
    -- Realizar la actualización en la tabla sakila aquí
    UPDATE sakila.tabla
    SET columna = nuevo_valor
    WHERE condicion;
    
    -- Obtener la cantidad de registros afectados
    GET DIAGNOSTICS registros_afectados = ROW_COUNT;
    
    -- Confirmar la transacción si no hay errores
    COMMIT;
    
    -- Imprimir mensaje
    RAISE NOTICE 'Se actualizaron % registros.', registros_afectados;
EXCEPTION
    -- Manejar errores y revertir la transacción si es necesario
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE EXCEPTION 'Error al actualizar la tabla: %', SQLERRM;
END;
$$
LANGUAGE plpgsql;

CALL actualizar_con_transaccion();

-- Comenzar la transacción
BEGIN;

-- Obtener el inventory_id de una película disponible para alquilar
DECLARE
    v_inventory_id INT;
BEGIN
    SELECT inventory_id
    INTO v_inventory_id
    FROM inventory
    WHERE film_id = <film_id> AND store_id = <store_id>
    AND inventory_in_stock(inventory_id); -- Función para verificar disponibilidad
    -- Si la película está disponible, actualizar el inventario
    IF FOUND THEN
        UPDATE inventory
        SET inventory_in_stock = false
        WHERE inventory_id = v_inventory_id;
    ELSE
        -- Si la película no está disponible, lanzar una excepción
        RAISE EXCEPTION 'La película no está disponible para alquilar';
    END IF;
END;

-- Realizar otras operaciones relacionadas con la transacción aquí

-- Confirmar la transacción si no hay errores
COMMIT;

CREATE OR REPLACE FUNCTION intercambiar_valores(
    INOUT valor1 INT,
    INOUT valor2 INT
) RETURNS VOID AS
$$
DECLARE
    temp INT;
BEGIN
    temp := valor1;
    valor1 := valor2;
    valor2 := temp;
END;
$$
LANGUAGE plpgsql;
