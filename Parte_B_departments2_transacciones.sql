-- ============================================================
-- Trabajo: Indices y restricciones en Oracle - Julio y Jusef
-- Parte B: departments2, sesiones y transacciones
-- Ejecutar conectado como HR (localhost:1521/xepdb1)
-- ============================================================
SET ECHO ON
SET SERVEROUTPUT ON

-- 3.1 Crear un duplicado de departments
CREATE TABLE departments2 AS SELECT * FROM departments;

SELECT COUNT(*) AS filas FROM departments2;   -- 27

-- Que se copio realmente
SELECT constraint_name, constraint_type FROM user_constraints WHERE table_name = 'DEPARTMENTS2';
SELECT index_name FROM user_indexes WHERE table_name = 'DEPARTMENTS2';

-- 3.2 Insertar tres filas (SIN COMMIT)
INSERT INTO departments2 VALUES (280, 'Pruebas', NULL, 1700);
INSERT INTO departments2 VALUES (290, 'Calidad', NULL, 1700);
INSERT INTO departments2 VALUES (300, 'Soporte', NULL, 1700);

SELECT * FROM departments2 WHERE department_id >= 280;
SELECT COUNT(*) AS filas FROM departments2;   -- 30

-- 3.3 Cerrar sesion: desde SQL Developer, clic derecho sobre la conexion -> Desconectar.
--     Despues volver a conectar y ejecutar:
SELECT COUNT(*) AS filas FROM departments2;
SELECT * FROM departments2 WHERE department_id >= 280;

-- 3.4 Bloque anonimo con inicio y finalizacion de una transaccion
DECLARE
  v_id VARCHAR2(100);
BEGIN
  SET TRANSACTION NAME 'TX_DEPARTMENTS2';   -- inicio explicito de la transaccion
  DBMS_OUTPUT.PUT_LINE('INICIO de la transaccion: ' ||
                       TO_CHAR(SYSTIMESTAMP, 'DD/MM/YYYY HH24:MI:SS'));

  INSERT INTO departments2 VALUES (310, 'Transaccion A', NULL, 1700);
  UPDATE departments2 SET department_name = 'Transaccion A (act.)'
   WHERE department_id = 310;

  v_id := DBMS_TRANSACTION.LOCAL_TRANSACTION_ID;
  DBMS_OUTPUT.PUT_LINE('ID de la transaccion: ' || v_id);

  COMMIT;                                    -- fin de la transaccion
  DBMS_OUTPUT.PUT_LINE('FIN de la transaccion (COMMIT): ' ||
                       TO_CHAR(SYSTIMESTAMP, 'DD/MM/YYYY HH24:MI:SS'));
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('FIN de la transaccion (ROLLBACK): ' || SQLERRM);
    RAISE;
END;
/

SELECT * FROM departments2 WHERE department_id = 310;

-- 4.1 Como deshacer una transaccion: ejemplo con ROLLBACK TO SAVEPOINT
SELECT COUNT(*) AS antes FROM departments2;

SAVEPOINT antes_borrado;
DELETE FROM departments2 WHERE department_id >= 280;
SELECT COUNT(*) AS tras_delete FROM departments2;     -- menos filas

ROLLBACK TO antes_borrado;                            -- deshace solo el DELETE
SELECT COUNT(*) AS tras_rollback FROM departments2;   -- igual que antes

ROLLBACK;                                             -- cierra la transaccion
