-- Codigo pl/pgsql para sumar dos numeros
CREATE OR REPLACE FUNCTION sumar_numeros(num1 INTEGER, num2 INTEGER)
RETURNS INTEGER AS $$
DECLARE
    resultado INTEGER;
BEGIN
    resultado := num1 + num2;
    RETURN resultado;
END;
$$ LANGUAGE plpgsql;
-- usar funciones
SELECT sumar_numeros(5, 8); -- Devolverá 13

-- Desarrolla codigo pl/pgsql para determinar si un numero es primo o no
CREATE OR REPLACE FUNCTION es_primo(numero INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
    divisor INTEGER;
BEGIN
    IF numero <= 1 THEN
        RETURN FALSE; -- Los números menores o iguales a 1 no son primos
    END IF;

    FOR divisor IN 2..(numero / 2) LOOP
        IF numero % divisor = 0 THEN
            RETURN FALSE; -- Si el número es divisible por algún valor entre 2 y numero/2, no es primo
        END IF;
    END LOOP;

    RETURN TRUE; -- Si el número no fue divisible por ningún valor, es primo
END;
$$ LANGUAGE plpgsql;
-- usar funciones
SELECT es_primo(7); -- Devolverá TRUE, ya que 7 es un número primo
SELECT es_primo(10); -- Devolverá FALSE, ya que 10 no es un número primo

-- Desarrolla codigo pl/pgsql para obtener el factorial de un numero
CREATE OR REPLACE FUNCTION factorial(numero INTEGER)
RETURNS BIGINT AS $$
DECLARE
    resultado BIGINT := 1;
    i INTEGER;
BEGIN
    IF numero < 0 THEN
        RAISE EXCEPTION 'El factorial no está definido para números negativos';
    END IF;

    FOR i IN 1..numero LOOP
        resultado := resultado * i;
    END LOOP;

    RETURN resultado;
END;
$$ LANGUAGE plpgsql;
-- usar funciones
SELECT factorial(5); -- Devolverá 120 (5! = 5 * 4 * 3 * 2 * 1)
SELECT factorial(0); -- Devolverá 1 (0! = 1)

-- Manejo de excepciones
CREATE OR REPLACE FUNCTION division_segura(dividendo FLOAT, divisor FLOAT)
RETURNS FLOAT AS $$
DECLARE
    resultado FLOAT;
BEGIN
    BEGIN
        IF divisor = 0 THEN
            RAISE EXCEPTION 'División por cero no permitida';
        END IF;
        
        resultado := dividendo / divisor;
        RETURN resultado;
    EXCEPTION
        WHEN OTHERS THEN
            -- Manejo de la excepción
            resultado := NULL; -- O cualquier valor que desees
            RETURN resultado;
    END;
END;
$$ LANGUAGE plpgsql;






