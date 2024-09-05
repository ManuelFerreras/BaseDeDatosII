SELECT c.nombre_carrera, COUNT(ic.id_alumno) AS cantidad_alumnos
FROM carrera c
JOIN inscripcion_carrera ic ON c.id_carrera = ic.id_carrera
GROUP BY c.nombre_carrera;

SELECT p.anio_cursada, p.cuatrimestre, c.nombre_carrera, COUNT(ic.id_alumno) AS cantidad_alumnos
FROM plan_de_materia p
JOIN carrera c ON p.id_carrera = c.id_carrera
JOIN inscripcion_carrera ic ON c.id_carrera = ic.id_carrera
GROUP BY p.anio_cursada, p.cuatrimestre, c.nombre_carrera;

SELECT p.anio_cursada, p.cuatrimestre, c.nombre_carrera, COUNT(DISTINCT im.id_alumno) AS cantidad_activos
FROM plan_de_materia p
JOIN carrera c ON p.id_carrera = c.id_carrera
JOIN inscripcion_carrera ic ON c.id_carrera = ic.id_carrera
JOIN inscripcion_materia im ON ic.id_alumno = im.id_alumno
WHERE im.estado = 'Cursando'
GROUP BY p.anio_cursada, p.cuatrimestre, c.nombre_carrera;

SELECT m.nombre_materia, a.nombre, a.apellido
FROM inscripcion_materia im
JOIN materiaXplanXcomision mpc ON im.id_materiaXplanXcomision = mpc.id_materiaXplanXcomision
JOIN materiaXplan mp ON mpc.id_materiaXplan = mp.id_materiaXplan
JOIN materia m ON mp.id_materia = m.id_materia
JOIN alumno a ON im.id_alumno = a.id_alumno
WHERE im.estado = 'Cursando';

SELECT m.nombre_materia,
  SUM(CASE WHEN im.estado = 'Regular' THEN 1 ELSE 0 END) AS cantidad_regulares,
  SUM(CASE WHEN im.estado = 'Libre' THEN 1 ELSE 0 END) AS cantidad_libres
FROM inscripcion_materia im
JOIN materiaXplanXcomision mpc ON im.id_materiaXplanXcomision = mpc.id_materiaXplanXcomision
JOIN materiaXplan mp ON mpc.id_materiaXplan = mp.id_materiaXplan
JOIN materia m ON mp.id_materia = m.id_materia
GROUP BY m.nombre_materia;


SELECT m.nombre_materia,
  COUNT(ie.id_inscripcion_examen) AS cantidad_examenes_rendidos,
  SUM(CASE WHEN ie.nota > 4 THEN 1 ELSE 0 END) AS cantidad_aprobados
FROM inscripcion_examen ie
JOIN inscripcion_materia im ON ie.id_inscripcion_examen = im.id_insc_materia
JOIN materiaXplanXcomision mpc ON im.id_materiaXplanXcomision = mpc.id_materiaXplanXcomision
JOIN materiaXplan mp ON mpc.id_materiaXplan = mp.id_materiaXplan
JOIN materia m ON mp.id_materia = m.id_materia
GROUP BY m.nombre_materia;
