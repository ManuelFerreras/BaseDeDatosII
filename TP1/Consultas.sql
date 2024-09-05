SELECT c.nombre_carrera, COUNT(ic.id_alumno) AS cantidad_alumnos
FROM carrera c
JOIN inscripcion_carrera ic ON c.id_carrera = ic.id_carrera
GROUP BY c.nombre_carrera;

SELECT pm.anio_cursada, pm.cuatrimestre, c.nombre_carrera, COUNT(ic.id_alumno) AS cantidad_alumnos
FROM plan_de_materia pm
JOIN carrera c ON pm.id_carrera = c.id_carrera
JOIN inscripcion_carrera ic ON c.id_carrera = ic.id_carrera
GROUP BY pm.anio_cursada, pm.cuatrimestre, c.nombre_carrera;

SELECT pm.anio_cursada, pm.cuatrimestre, c.nombre_carrera, COUNT(ic.id_alumno) AS cantidad_activos
FROM plan_de_materia pm
JOIN carrera c ON pm.id_carrera = c.id_carrera
JOIN inscripcion_carrera ic ON c.id_carrera = ic.id_carrera
JOIN inscripcion_materia im ON ic.id_alumno = im.id_alumno
WHERE im.estado = 'Cursando'
GROUP BY pm.anio_cursada, pm.cuatrimestre, c.nombre_carrera;

SELECT m.nombre_materia, a.nombre, a.apellido
FROM inscripcion_materia im
JOIN materiaXplanXcomision mxc ON im.id_materiaXplanXcomision = mxc.id_materiaXplanXcomision
JOIN materia m ON mxc.id_materiaXplanXcomision = m.id_materia
JOIN alumno a ON im.id_alumno = a.id_alumno
WHERE im.estado = 'Cursando';

SELECT m.nombre_materia,
  SUM(CASE WHEN im.estado = 'Regular' THEN 1 ELSE 0 END) AS cantidad_regulares,
  SUM(CASE WHEN im.estado = 'Libre' THEN 1 ELSE 0 END) AS cantidad_libres
FROM inscripcion_materia im
JOIN materiaXplanXcomision mxc ON im.id_materiaXplanXcomision = mxc.id_materiaXplanXcomision
JOIN materia m ON mxc.id_materiaXplanXcomision = m.id_materia
GROUP BY m.nombre_materia;

SELECT m.nombre_materia,
  COUNT(ie.id_inscripcion_examen) AS cantidad_examenes_rendidos,
  SUM(CASE WHEN ie.nota > 4 THEN 1 ELSE 0 END) AS cantidad_aprobados
FROM inscripcion_examen ie
JOIN parcial p ON ie.id_parcial = p.id_parcial
JOIN materia m ON p.id_materia = m.id_materia
GROUP BY m.nombre_materia;
