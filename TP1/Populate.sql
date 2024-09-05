
USE acad;

INSERT INTO carrera (id_carrera, nombre_carrera, titulo)
VALUES 
(1, 'Ingeniería en Informática', 'Ingeniero en Informática'),
(2, 'Ingeniería en Computación', 'Ingeniero en Computación'),
(3, 'Licenciatura en Bioinformática', 'Licenciado en Bioinformática');

INSERT INTO plan_de_materia (id_plan, cuatrimestre, anio_cursada, id_carrera)
VALUES 
(1, 1, 2016, 1),
(2, 2, 2024, 1),
(3, 1, 2020, 2),
(4, 2, 2024, 2);

INSERT INTO materia (id_materia, nombre_materia)
VALUES 
(1, 'Materia 1'),
(2, 'Materia 2'),
(3, 'Materia 3');

INSERT INTO materiaXplan (id_materiaXplan, id_plan, id_materia)
VALUES
(1, 1, 1),
(2, 1, 2),
(3, 1, 3),
(4, 2, 1),
(5, 2, 2),
(6, 2, 3),
(7, 3, 1),
(8, 3, 2),
(9, 3, 3),
(10, 4, 1),
(11, 4, 2),
(12, 4, 3);

INSERT INTO alumno (id_alumno, nombre, apellido, fecha_nacimiento)
VALUES 
(1, 'Manuel', 'Ferreras', '1995-08-15'),
(2, 'Matias', 'Carbel', '1996-10-22'),
(3, 'Juan', 'Martínez', '1997-05-30'),
(4, 'Ana', 'Rodríguez', '1995-09-01');

INSERT INTO inscripcion_carrera (id_insc_carrera, fecha_matriculacion, id_alumno, id_carrera)
VALUES 
(1, '2023-01-15', 1, 1),
(2, '2023-01-15', 2, 1),
(3, '2023-01-15', 3, 2),
(4, '2023-01-15', 4, 2);

INSERT INTO inscripcion_carrera (id_insc_carrera, fecha_matriculacion, id_alumno, id_carrera)
VALUES (5, '2024-02-10', 1, 2);

DELETE FROM inscripcion_carrera WHERE id_alumno = 1 AND id_carrera = 1;

INSERT INTO inscripcion_materia (id_insc_materia, fecha_inscripcion, estado, fecha_estado, id_alumno, id_materiaXplanXcomision)
VALUES
(1, '2023-02-01', 'Cursando', '2023-02-01', 1, 1),
(2, '2023-02-01', 'Cursando', '2023-02-01', 1, 2),
(3, '2023-02-01', 'Cursando', '2023-02-01', 2, 3);

INSERT INTO parcial (id_parcial, parcial, fecha, nota)
VALUES
(1, 'Parcial 1', '2023-03-01', 2),
(2, 'Parcial 2', '2023-04-01', 4),
(3, 'Parcial 1', '2023-03-01', 8),
(4, 'Parcial 2', '2023-04-01', 6),
(5, 'Parcial 1', '2023-03-01', 9),
(6, 'Parcial 2', '2023-04-01', 5);

INSERT INTO inscripcion_materia (id_insc_materia, fecha_inscripcion, estado, fecha_estado, id_alumno, id_materiaXplanXcomision)
VALUES (4, '2024-02-01', 'Cursando', '2024-02-01', 1, 1);

INSERT INTO parcial (id_parcial, parcial, fecha, nota)
VALUES 
(7, 'Parcial 1', '2024-03-01', 7),
(8, 'Parcial 2', '2024-04-01', 9);

INSERT INTO turno_examen (id_turno_examen, fecha_turno)
VALUES
(1, '2024-06-01'),
(2, '2024-08-01');

INSERT INTO inscripcion_examen (id_inscripcion_examen, fecha_inscripcion, fecha_examen, id_parcial)
VALUES 
(1, '2024-05-01', '2024-06-01', 1),
(2, '2024-07-01', '2024-08-01', 3);

INSERT INTO inscripcion_examen (id_inscripcion_examen, fecha_inscripcion, fecha_examen, id_parcial)
VALUES
(3, '2024-05-01', '2024-06-01', 1),
(4, '2024-07-01', '2024-08-01', 2);

UPDATE inscripcion_examen SET nota = 8 WHERE id_inscripcion_examen = 3;
UPDATE inscripcion_examen SET nota = 0 WHERE id_inscripcion_examen = 4;
