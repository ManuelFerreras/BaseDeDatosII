
USE acad;

INSERT INTO alumno (id_alumno, nombre, apellido, fecha_nacimiento)
VALUES 
(1, 'Juan', 'Pérez', '1995-08-15'),
(2, 'María', 'Gómez', '1996-10-22'),
(3, 'Luis', 'Martínez', '1997-05-30'),
(4, 'Ana', 'Rodríguez', '1998-09-10');

INSERT INTO carrera (id_carrera, nombre_carrera, titulo)
VALUES 
(1, 'Ingeniería en Informática', 'Ingeniero en Informática'),
(2, 'Ingeniería en Computación', 'Ingeniero en Computación'),
(3, 'Licenciatura en Bioinformática', 'Licenciado en Bioinformática');

INSERT INTO plan_de_carrera (id_plan, cuatrimestre, anio_cursada, id_carrera)
VALUES 
(1, 1, 2016, 1), 
(2, 2, 2020, 2), 
(3, 1, 2021, 3); 

INSERT INTO materia (id_materia, nombre_materia)
VALUES 
(1, 'Matemáticas I'),
(2, 'Programación I'),
(3, 'Bases de Datos');

INSERT INTO materiaXplan (id_materiaXplan, id_plan, id_materia)
VALUES 
(1, 1, 1), 
(2, 1, 2), 
(3, 2, 3), 
(4, 3, 1), 
(5, 3, 2); 

INSERT INTO comision (id_comision, nombre_comision)
VALUES 
(1, 'Comisión A'),
(2, 'Comisión B'),
(3, 'Comisión C');

INSERT INTO materiaXplanXcomision (id_materiaXplanXcomision, id_materiaXplan, id_comision)
VALUES 
(1, 1, 1), 
(2, 2, 2), 
(3, 3, 1), 
(4, 4, 3), 
(5, 5, 2); 

INSERT INTO inscripcion_carrera (id_insc_carrera, fecha_matriculacion, id_alumno, id_carrera)
VALUES 
(1, '2022-01-15', 1, 1), 
(2, '2022-01-15', 2, 1), 
(3, '2022-01-15', 3, 2), 
(4, '2022-01-15', 4, 3); 

INSERT INTO inscripcion_materia (id_insc_materia, fecha_inscripcion, estado, fecha_estado, id_alumno, id_materiaXplanXcomision)
VALUES 
(1, '2022-02-01', 'Cursando', '2022-02-01', 1, 1), 
(2, '2022-02-01', 'Cursando', '2022-02-01', 2, 2), 
(3, '2022-02-01', 'Regular', '2022-05-01', 3, 3), 
(4, '2022-02-01', 'Cursando', '2022-02-01', 4, 4); 

INSERT INTO parcial (id_parcial, parcial, fecha, nota, id_inscripcion)
VALUES 
(1, 'Parcial 1', '2022-03-01', 8, 1), 
(2, 'Parcial 2', '2022-04-01', 9, 1), 
(3, 'Parcial 1', '2022-03-01', 7, 2), 
(4, 'Parcial 2', '2022-04-01', 6, 2), 
(5, 'Parcial 1', '2022-03-01', 5, 3), 
(6, 'Parcial 2', '2022-04-01', 6, 3), 
(7, 'Parcial 1', '2022-03-01', 9, 4), 
(8, 'Parcial 2', '2022-04-01', 8, 4); 

INSERT INTO inscripcion_examen (id_inscripcion_examen, fecha_inscripcion, fecha_examen, nota)
VALUES 
(1, '2022-05-01', '2022-06-01', 8), 
(2, '2022-05-01', '2022-06-01', 6), 
(3, '2022-05-01', '2022-06-01', 5), 
(4, '2022-05-01', '2022-06-01', 9); 

INSERT INTO turno_examen (id_turno_examen, fecha_turno)
VALUES 
(1, '2022-06-01'), 
(2, '2022-12-01'); 
