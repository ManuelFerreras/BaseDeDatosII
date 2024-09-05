CREATE DATABASE acad;

USE acad;

-- Tabla alumno
CREATE TABLE alumno (
    id_alumno INT PRIMARY KEY,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    fecha_nacimiento DATE
);

-- Tabla carrera
CREATE TABLE carrera (
    id_carrera INT PRIMARY KEY,
    nombre_carrera VARCHAR(100),
    titulo VARCHAR(100)
);

-- Tabla inscripcion_carrera
CREATE TABLE inscripcion_carrera (
    id_insc_carrera INT PRIMARY KEY,
    fecha_matriculacion DATE,
    id_alumno INT,
    id_carrera INT,
    FOREIGN KEY (id_alumno) REFERENCES alumno(id_alumno),
    FOREIGN KEY (id_carrera) REFERENCES carrera(id_carrera)
);

-- Tabla materia
CREATE TABLE materia (
    id_materia INT PRIMARY KEY,
    nombre_materia VARCHAR(100)
);

-- Tabla plan_de_materia
CREATE TABLE plan_de_materia (
    id_plan INT PRIMARY KEY,
    cuatrimestre INT,
    anio_cursada INT,
    id_carrera INT,
    FOREIGN KEY (id_carrera) REFERENCES carrera(id_carrera)
);

-- Tabla materiaXplan
CREATE TABLE materiaXplan (
    id_materiaXplan INT PRIMARY KEY,
    id_plan INT,
    id_materia INT,
    FOREIGN KEY (id_plan) REFERENCES plan_de_materia(id_plan),
    FOREIGN KEY (id_materia) REFERENCES materia(id_materia)
);

-- Tabla comision
CREATE TABLE comision (
    id_comision INT PRIMARY KEY,
    nombre_comision VARCHAR(100)
);

-- Tabla materiaXplanXcomision
CREATE TABLE materiaXplanXcomision (
    id_materiaXplanXcomision INT PRIMARY KEY,
    id_materiaXplan INT,
    id_comision INT,
    FOREIGN KEY (id_materiaXplan) REFERENCES materiaXplan(id_materiaXplan),
    FOREIGN KEY (id_comision) REFERENCES comision(id_comision)
);

-- Tabla profesor
CREATE TABLE profesor (
    id_profesor INT PRIMARY KEY,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    fecha_nacimiento DATE
);

-- Tabla inscripcion_materia
CREATE TABLE inscripcion_materia (
    id_insc_materia INT PRIMARY KEY,
    fecha_inscripcion DATE,
    estado VARCHAR(50),
    fecha_estado DATE,
    id_alumno INT,
    id_materiaXplanXcomision INT,
    FOREIGN KEY (id_alumno) REFERENCES alumno(id_alumno),
    FOREIGN KEY (id_materiaXplanXcomision) REFERENCES materiaXplanXcomision(id_materiaXplanXcomision)
);

-- Tabla parcial
CREATE TABLE parcial (
    id_parcial INT PRIMARY KEY,
    parcial VARCHAR(50),
    fecha DATE,
    nota DECIMAL(5, 2)
);

-- Tabla inscripcion_examen
CREATE TABLE inscripcion_examen (
    id_inscripcion_examen INT PRIMARY KEY,
    fecha_inscripcion DATE,
    fecha_examen DATE,
    nota DECIMAL(5, 2),
    id_parcial INT,
    FOREIGN KEY (id_parcial) REFERENCES parcial(id_parcial)
);

-- Tabla turno_examen
CREATE TABLE turno_examen (
    id_turno_examen INT PRIMARY KEY,
    fecha_turno DATE
);
