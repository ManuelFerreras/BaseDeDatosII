-- The aim of this TP is to create all the necessary tables to complete the TP1 DER.

-- CREATE TABLE (
--   column1 datatype constraint,
--   column2 datatype constraint,
--   PRIMARY KEY (columnName)
-- )



-- Constraints

-- NOT NULL -> A Column can not have an empty value.
-- UNIQUE -> Ensures that every value in a column is unique.
-- PRIMARY KEY (column) -> Combination of the two above. Only one per table.
-- FOREIGN KEY (column) REFERENCES table(table_column) -> Links between tables.
-- CHECK -> Ensures that values in a column satisfies a specific condition.
-- DEFAULT -> Sets a default value for a column if no value is specified.
-- CREATE INDEX -> Imrpvoes performance.



-- Tables

-- DROP TABLE -> deletes a table
-- TRUNCATE TABLE -> deletes data inside a table
-- CREATE TABLE -> creates a new table
-- CREATE VIEW -> creates a virtual table with the result of a query so that we prevent unauthorized access to data.
-- DROP VIEW



-- Data Types

-- CHAR(size) -> Fixed size string.
-- VARCHAR(size) -> Variable size string with max size of `size`.
-- BINARY(size) -> Fixed length binary byte strings.
-- VARBINARY(size) -> Variable binary byte strings.
-- TINYTEXT
-- TEXT(size)
-- BLOB(size)
-- ENUM(val1, val2, ...)
-- SET(val1, val2, ...)

-- BOOL
-- INT(size)
-- DECIMAL(size, decimals)

-- DATE -> YYYY-MM-DD
-- DATETIME(fsp) -> YYYY-MM-DD hh:mm:ss -> fsp: "fractional seconds precision"
-- TIMESTAMP(fsp)
-- TIME(fsp)
-- YEAR



-- Alumno
CREATE TABLE Alumno (
  nombre VARCHAR(255) NOT NULL,
  apellido VARCHAR(255) NOT NULL,
  fecha_nacimiento DATE NOT NULL,
  dni INT NOT NULL UNIQUE,
  clave INT NOT NULL UNIQUE,
  id_alumno INT,
  PRIMARY KEY (id_alumno)
);

-- Materia
CREATE TABLE Materia (
  nombre VARCHAR(255) NOT NULL,
  id_materia INT,
  PRIMARY KEY (id_materia)
);

-- Carrera
CREATE TABLE Carrera (
  nombre VARCHAR(255) NOT NULL,
  titulo VARCHAR(255) NOT NULL,
  id_carrera INT,
  id_plan INT,
  PRIMARY KEY (id_carrera),
  FOREIGN KEY (id_plan) REFERENCES Plan(id_plan)
);

-- Matriculación
CREATE TABLE Matriculacion (
  fecha_matriculacion DATE NOT NULL,
  id_matriculacion INT,
  id_carrera INT,
  id_alumno INT,
  PRIMARY KEY (id_matriculacion),
  FOREIGN KEY (id_carrera) REFERENCES Carrera(id_carrera),
  FOREIGN KEY (id_alumno) REFERENCES Alumno(id_alumno)
);

-- Plan
CREATE TABLE Plan (
  ano_cursado INT NOT NULL,
  cuatrimestre INT NOT NULL,
  id_plan INT,
  PRIMARY KEY (id_plan),
);

-- PlanXMateria
CREATE TABLE PlanXMateria (
  id_plan INT,
  id_materia INT,
  -- PRIMARY KEY (id_plan, id_materia),
  FOREIGN KEY (id_plan) REFERENCES Plan(id_plan),
  FOREIGN KEY (id_materia) REFERENCES Materia(id_materia)
);

-- Parcial
CREATE TABLE Parcial (
  fecha_parcial DATE NOT NULL,
  nota INT NOT NULL,
  id_parcial INT,
  id_materia INT,
  id_alumno INT,
  PRIMARY KEY (id_parcial),
  FOREIGN KEY (id_materia) REFERENCES Materia(id_materia),
  FOREIGN KEY (id_alumno) REFERENCES Alumno(id_alumno)
);

-- TurnoExamen
CREATE TABLE TurnoExamen (
  fecha_examen DATE NOT NULL,
  id_turno INT,
  id_materia INT,
  PRIMARY KEY (id_turno),
  FOREIGN KEY (id_materia) REFERENCES Materia(id_materia)
);

-- InscripcionExamen
CREATE TABLE InscripcionExamen (
  fecha_inscripcion DATE NOT NULL,
  nota INT NOT NULL,
  id_inscripcion INT,
  id_alumno INT,
  id_turno INT,
  PRIMARY KEY (id_inscripcion),
  FOREIGN KEY (id_alumno) REFERENCES Alumno(id_alumno),
  FOREIGN KEY (id_turno) REFERENCES TurnoExamen(id_turno)
);