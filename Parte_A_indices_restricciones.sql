-- ============================================================
-- Trabajo: Indices y restricciones en Oracle - Julio y Jusef
-- Parte A: indices y restricciones de EMPLOYEES y DEPARTMENTS
-- Ejecutar conectado como HR (localhost:1521/xepdb1) con F5
-- ============================================================
SET ECHO ON
SET LINESIZE 200
SET PAGESIZE 100

-- 2.1 Iniciar sesion con el usuario hr
SELECT USER AS usuario_actual FROM dual;

-- 2.2 Consultar los indices de employees y departments
SELECT table_name, index_name, index_type, uniqueness, status
FROM user_indexes
WHERE table_name IN ('EMPLOYEES','DEPARTMENTS')
ORDER BY table_name, index_name;

SELECT table_name, index_name, column_name, column_position
FROM user_ind_columns
WHERE table_name IN ('EMPLOYEES','DEPARTMENTS')
ORDER BY table_name, index_name, column_position;

-- 2.3 Estado inicial de las restricciones
SELECT table_name, constraint_name, constraint_type, status, validated
FROM user_constraints
WHERE table_name IN ('EMPLOYEES','DEPARTMENTS')
ORDER BY table_name, constraint_type, constraint_name;

-- 2.4 Desactivar las restricciones
-- DEPARTMENTS
ALTER TABLE departments DISABLE CONSTRAINT dept_mgr_fk;
ALTER TABLE departments DISABLE CONSTRAINT dept_loc_fk;
ALTER TABLE departments DISABLE CONSTRAINT dept_name_nn;
ALTER TABLE departments DISABLE CONSTRAINT dept_id_pk CASCADE;

-- EMPLOYEES
ALTER TABLE employees DISABLE CONSTRAINT emp_manager_fk;
ALTER TABLE employees DISABLE CONSTRAINT emp_job_fk;
ALTER TABLE employees DISABLE CONSTRAINT emp_dept_fk;
ALTER TABLE employees DISABLE CONSTRAINT emp_salary_min;
ALTER TABLE employees DISABLE CONSTRAINT emp_email_uk;
ALTER TABLE employees DISABLE CONSTRAINT emp_last_name_nn;
ALTER TABLE employees DISABLE CONSTRAINT emp_email_nn;
ALTER TABLE employees DISABLE CONSTRAINT emp_hire_date_nn;
ALTER TABLE employees DISABLE CONSTRAINT emp_job_nn;
ALTER TABLE employees DISABLE CONSTRAINT emp_emp_id_pk CASCADE;

-- Estado tras desactivar (incluye JOB_HISTORY, afectada por CASCADE)
SELECT table_name, constraint_name, constraint_type, status
FROM user_constraints
WHERE table_name IN ('EMPLOYEES','DEPARTMENTS','JOB_HISTORY')
ORDER BY table_name, constraint_type, constraint_name;

SELECT table_name, index_name, uniqueness
FROM user_indexes
WHERE table_name IN ('EMPLOYEES','DEPARTMENTS')
ORDER BY table_name, index_name;

-- 2.5 Insertar filas que incumplen las restricciones
-- (todas llevan el marcador PRUEBA_INV para borrarlas despues)
-- DEPARTMENTS (department_id, department_name, manager_id, location_id)
INSERT INTO departments VALUES (777, 'PRUEBA_INV', 999, 9999);  -- FK: manager y location inexistentes
INSERT INTO departments VALUES (888, NULL, NULL, NULL);          -- NOT NULL: nombre nulo

-- EMPLOYEES (employee_id, first_name, last_name, email, phone_number, hire_date,
--            job_id, salary, commission_pct, manager_id, department_id)
INSERT INTO employees VALUES
  (9001, 'PRUEBA_INV1', NULL, 'PRUEBAINV1', NULL, NULL, 'XX_FAKE', -500, NULL, 999, 9999);
  -- last_name y hire_date nulos, job inexistente, salario negativo, manager y departamento inexistentes
INSERT INTO employees VALUES
  (9002, 'PRUEBA_INV2', 'Duplicado', 'SKING', NULL, SYSDATE, 'IT_PROG', 5000, NULL, NULL, NULL);
  -- UNIQUE: email repetido
COMMIT;

-- Prueba adicional: clave primaria duplicada
-- (puede dar ORA-00001 si el indice unico se conservo al desactivar la PK)
INSERT INTO departments VALUES (10, 'PRUEBA_INV_PK', NULL, 1700);
INSERT INTO employees VALUES
  (100, 'PRUEBA_INV4', 'Duplicado', 'PRUEBAINV4', NULL, SYSDATE, 'IT_PROG', 5000, NULL, NULL, NULL);

-- 2.6 Intentar reactivar con los datos invalidos presentes (se esperan errores)
ALTER TABLE departments ENABLE CONSTRAINT dept_name_nn;    -- ORA-02296
ALTER TABLE departments ENABLE CONSTRAINT dept_loc_fk;     -- ORA-02298
ALTER TABLE employees   ENABLE CONSTRAINT emp_salary_min;  -- ORA-02293
ALTER TABLE employees   ENABLE CONSTRAINT emp_email_uk;    -- ORA-02299
ALTER TABLE employees   ENABLE CONSTRAINT emp_last_name_nn;-- ORA-02296

-- 2.7 Corregir los datos y volver a establecer las restricciones
ROLLBACK;
DELETE FROM employees   WHERE first_name LIKE 'PRUEBA_INV%';
DELETE FROM departments WHERE department_name LIKE 'PRUEBA_INV%' OR department_id = 888;
COMMIT;

-- Claves primarias, unicidad, check y NOT NULL
ALTER TABLE departments ENABLE CONSTRAINT dept_name_nn;
ALTER TABLE departments ENABLE CONSTRAINT dept_id_pk;
ALTER TABLE employees   ENABLE CONSTRAINT emp_last_name_nn;
ALTER TABLE employees   ENABLE CONSTRAINT emp_email_nn;
ALTER TABLE employees   ENABLE CONSTRAINT emp_hire_date_nn;
ALTER TABLE employees   ENABLE CONSTRAINT emp_job_nn;
ALTER TABLE employees   ENABLE CONSTRAINT emp_salary_min;
ALTER TABLE employees   ENABLE CONSTRAINT emp_email_uk;
ALTER TABLE employees   ENABLE CONSTRAINT emp_emp_id_pk;

-- Claves foraneas (incluidas las de JOB_HISTORY desactivadas por CASCADE)
ALTER TABLE departments ENABLE CONSTRAINT dept_loc_fk;
ALTER TABLE departments ENABLE CONSTRAINT dept_mgr_fk;
ALTER TABLE employees   ENABLE CONSTRAINT emp_dept_fk;
ALTER TABLE employees   ENABLE CONSTRAINT emp_job_fk;
ALTER TABLE employees   ENABLE CONSTRAINT emp_manager_fk;
ALTER TABLE job_history ENABLE CONSTRAINT jhist_dept_fk;
ALTER TABLE job_history ENABLE CONSTRAINT jhist_emp_fk;

-- Comprobacion final
SELECT table_name, constraint_name, constraint_type, status, validated
FROM user_constraints
WHERE table_name IN ('EMPLOYEES','DEPARTMENTS','JOB_HISTORY')
ORDER BY table_name, constraint_type, constraint_name;

SELECT COUNT(*) AS empleados FROM employees;       -- 107
SELECT COUNT(*) AS departamentos FROM departments; -- 27
