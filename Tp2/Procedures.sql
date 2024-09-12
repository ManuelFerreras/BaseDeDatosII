-- Clear all procedures before start.
DELETE FROM mysql.proc WHERE db = 'acad';

DELIMITER //

-- Verificar la existencia de una carrera
CREATE PROCEDURE verificar_existencia_carrera(IN p_id_carrera INT)
BEGIN
    DECLARE carrera_existe INT;
    SELECT COUNT(*) INTO carrera_existe
    FROM carrera
    WHERE id_carrera = p_id_carrera;

    IF carrera_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La carrera no existe';
    END IF;
END //

-- Verificar la existencia de un plan
CREATE PROCEDURE verificar_existencia_plan(IN p_id_plan INT)
BEGIN
    DECLARE plan_existe INT;
    SELECT COUNT(*) INTO plan_existe
    FROM plan_de_materia
    WHERE id_plan = p_id_plan;

    IF plan_existe > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El plan ya ha sido cargado previamente';
    END IF;
END //

-- Verificar la existencia de un plan antes de cargar materias
CREATE PROCEDURE verificar_existencia_plan_para_materia(IN p_id_plan INT)
BEGIN
    DECLARE plan_existe INT;
    SELECT COUNT(*) INTO plan_existe
    FROM plan_de_materia
    WHERE id_plan = p_id_plan;

    IF plan_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El plan no existe';
    END IF;
END //

-- Verificar la existencia de una materia
CREATE PROCEDURE verificar_existencia_materia(IN p_id_materia INT)
BEGIN
    DECLARE materia_existe INT;
    SELECT COUNT(*) INTO materia_existe
    FROM materia
    WHERE id_materia = p_id_materia;

    IF materia_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La materia no existe';
    END IF;
END //

-- Matricular alumno en un plan
CREATE PROCEDURE matricular_alumno(IN p_id_alumno INT, IN p_id_plan INT)
BEGIN
    DECLARE matriculado INT;
    
    CALL verificar_existencia_alumno(p_id_alumno);
    CALL verificar_existencia_plan_para_materia(p_id_plan);

    SELECT COUNT(*) INTO matriculado
    FROM inscripcion_carrera
    WHERE id_alumno = p_id_alumno AND id_plan = p_id_plan;

    IF matriculado > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El alumno ya está matriculado en este plan';
    ELSE
        INSERT INTO inscripcion_carrera (id_alumno, id_plan, fecha_matriculacion)
        VALUES (p_id_alumno, p_id_plan, CURDATE());
    END IF;
END //

-- Inscripción en una materia
CREATE PROCEDURE inscribir_materia(IN p_id_alumno INT, IN p_id_materia INT)
BEGIN
    DECLARE inscripcion_existe INT;
    
    CALL verificar_existencia_alumno(p_id_alumno);
    CALL verificar_existencia_materia(p_id_materia);

    SELECT COUNT(*) INTO inscripcion_existe
    FROM inscripcion_materia
    WHERE id_alumno = p_id_alumno AND id_materia = p_id_materia
      AND (estado = 'Regular' OR estado = 'Cursando');

    IF inscripcion_existe > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El alumno ya está inscrito en esta materia';
    ELSE
        INSERT INTO inscripcion_materia (id_alumno, id_materia, fecha_inscripcion, estado)
        VALUES (p_id_alumno, p_id_materia, CURDATE(), 'Cursando');
    END IF;
END //

-- Registrar parcial
CREATE PROCEDURE registrar_parcial(IN p_id_alumno INT, IN p_id_materia INT, IN p_nota DECIMAL(5,2))
BEGIN
    DECLARE estado_materia VARCHAR(50);
    DECLARE parciales_aprobados INT;
    DECLARE parciales_reprobados INT;
    
    SELECT estado INTO estado_materia
    FROM inscripcion_materia
    WHERE id_alumno = p_id_alumno AND id_materia = p_id_materia;

    IF estado_materia != 'Cursando' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede registrar el parcial, el alumno no está cursando';
    ELSE
        INSERT INTO parcial (id_materia, id_alumno, fecha, nota)
        VALUES (p_id_materia, p_id_alumno, CURDATE(), p_nota);

        SELECT COUNT(*) INTO parciales_aprobados
        FROM parcial
        WHERE id_alumno = p_id_alumno AND id_materia = p_id_materia AND nota >= 6;

        IF parciales_aprobados >= 2 THEN
            UPDATE inscripcion_materia SET estado = 'Regular'
            WHERE id_alumno = p_id_alumno AND id_materia = p_id_materia;
        ELSE
            SELECT COUNT(*) INTO parciales_reprobados
            FROM parcial
            WHERE id_alumno = p_id_alumno AND id_materia = p_id_materia AND nota < 6;

            IF parciales_reprobados >= 2 THEN
                UPDATE inscripcion_materia SET estado = 'Libre'
                WHERE id_alumno = p_id_alumno AND id_materia = p_id_materia;
            END IF;
        END IF;
    END IF;
END //

-- Inscripción en examen
CREATE PROCEDURE inscribir_examen(IN p_id_alumno INT, IN p_id_materia INT)
BEGIN
    DECLARE estado_materia VARCHAR(50);

    SELECT estado INTO estado_materia
    FROM inscripcion_materia
    WHERE id_alumno = p_id_alumno AND id_materia = p_id_materia;

    IF estado_materia != 'Regular' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El alumno no está regular en la materia, no puede inscribirse al examen';
    ELSE
        INSERT INTO inscripcion_examen (id_alumno, id_materia, fecha_inscripcion)
        VALUES (p_id_alumno, p_id_materia, CURDATE());
    END IF;
END //

-- Registrar nota de examen final
CREATE PROCEDURE registrar_nota_examen(IN p_id_alumno INT, IN p_id_materia INT, IN p_nota DECIMAL(5,2))
BEGIN
    DECLARE inscripcion_existe INT;
    
    SELECT COUNT(*) INTO inscripcion_existe
    FROM inscripcion_examen
    WHERE id_alumno = p_id_alumno AND id_materia = p_id_materia;

    IF inscripcion_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe inscripción al examen para este alumno';
    ELSE
        UPDATE inscripcion_examen
        SET nota = p_nota
        WHERE id_alumno = p_id_alumno AND id_materia = p_id_materia;

        IF p_nota < 0 OR p_nota > 10 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La nota debe estar entre 0 y 10';
        END IF;
    END IF;
END //

DELIMITER ;
