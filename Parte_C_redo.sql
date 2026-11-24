-- ============================================================
-- Trabajo: Indices y restricciones en Oracle - Julio y Jusef
-- Parte C: archivos de Redo y modo de funcionamiento
-- Ejecutar conectado como SYSTEM (localhost:1521/xepdb1), NO como HR:
-- HR no tiene privilegios sobre las vistas V$.
-- ============================================================
SET ECHO ON
SET LINESIZE 200
SET PAGESIZE 50

SELECT USER AS usuario, SYS_CONTEXT('USERENV','CON_NAME') AS contenedor FROM dual;

-- Modo de funcionamiento de la base de datos
SELECT name, log_mode FROM v$database;

-- Grupos de redo en linea
SELECT group#, thread#, sequence#, bytes/1024/1024 AS mb, members, status
FROM v$log;

-- Archivos fisicos de redo
SELECT group#, member FROM v$logfile;

-- Ejemplo: el INSERT genera redo
SELECT n.name, m.value
FROM v$mystat m JOIN v$statname n ON n.statistic# = m.statistic#
WHERE n.name = 'redo size';                 -- valor A

INSERT INTO hr.departments2 SELECT * FROM hr.departments;

SELECT n.name, m.value
FROM v$mystat m JOIN v$statname n ON n.statistic# = m.statistic#
WHERE n.name = 'redo size';                 -- valor B, mayor que A

ROLLBACK;
