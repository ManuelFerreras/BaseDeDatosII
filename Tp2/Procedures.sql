-- Eliminar procedimientos existentes
DROP PROCEDURE IF EXISTS verificar_existencia_carrera;
DROP PROCEDURE IF EXISTS verificar_existencia_plan;
DROP PROCEDURE IF EXISTS verificar_existencia_plan_para_materia;
DROP PROCEDURE IF EXISTS verificar_existencia_materia;
DROP PROCEDURE IF EXISTS matricular_alumno;
DROP PROCEDURE IF EXISTS inscribir_materia;
DROP PROCEDURE IF EXISTS registrar_parcial;
DROP PROCEDURE IF EXISTS inscribir_examen;
DROP PROCEDURE IF EXISTS registrar_nota_examen;

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

    IF plan_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El plan no existe';
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

-- Matricular alumno en una carrera
CREATE PROCEDURE matricular_alumno(IN p_id_alumno INT, IN p_id_carrera INT)
BEGIN
    DECLARE matriculado INT;

    -- Verificar la existencia del alumno y de la carrera
    CALL verificar_existencia_alumno(p_id_alumno);
    CALL verificar_existencia_carrera(p_id_carrera);

    -- Verificar si el alumno ya está matriculado en la carrera
    SELECT COUNT(*) INTO matriculado
    FROM inscripcion_carrera
    WHERE id_alumno = p_id_alumno AND id_carrera = p_id_carrera;

    IF matriculado > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El alumno ya está matriculado en esta carrera';
    ELSE
        INSERT INTO inscripcion_carrera (id_alumno, id_carrera, fecha_matriculacion)
        VALUES (p_id_alumno, p_id_carrera, CURDATE());
    END IF;
END //

-- Inscribir alumno en una materia
CREATE PROCEDURE inscribir_materia(IN p_id_alumno INT, IN p_id_materiaXplanXcomision INT)
BEGIN
    DECLARE inscripcion_existe INT;

    -- Verificar la existencia del alumno y de la materia en el plan y comisión
    CALL verificar_existencia_alumno(p_id_alumno);
    CALL verificar_existencia_materiaXplanXcomision(p_id_materiaXplanXcomision);

    -- Verificar si el alumno ya está inscrito en la materia
    SELECT COUNT(*) INTO inscripcion_existe
    FROM inscripcion_materia
    WHERE id_alumno = p_id_alumno AND id_materiaXplanXcomision = p_id_materiaXplanXcomision;

    IF inscripcion_existe > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El alumno ya está inscrito en esta materia';
    ELSE
        INSERT INTO inscripcion_materia (id_alumno, id_materiaXplanXcomision, fecha_inscripcion, estado, fecha_estado)
        VALUES (p_id_alumno, p_id_materiaXplanXcomision, CURDATE(), 'Cursando', CURDATE());
    END IF;
END //

-- Registrar parcial
CREATE PROCEDURE registrar_parcial(IN p_id_alumno INT, IN p_id_materiaXplanXcomision INT, IN p_parcial VARCHAR(50), IN p_nota DECIMAL(5,2))
BEGIN
    DECLARE estado_materia VARCHAR(50);

    -- Verificar si el alumno está cursando la materia
    SELECT estado INTO estado_materia
    FROM inscripcion_materia
    WHERE id_alumno = p_id_alumno AND id_materiaXplanXcomision = p_id_materiaXplanXcomision;

    IF estado_materia != 'Cursando' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El alumno no está cursando esta materia';
    ELSE
        -- Insertar el parcial
        INSERT INTO parcial (parcial, fecha, nota, id_inscripcion)
        VALUES (p_parcial, CURDATE(), p_nota, 
                (SELECT id_insc_materia FROM inscripcion_materia 
                 WHERE id_alumno = p_id_alumno AND id_materiaXplanXcomision = p_id_materiaXplanXcomision));
    END IF;
END //

-- Inscripción en examen
CREATE PROCEDURE inscribir_examen(IN p_id_alumno INT, IN p_id_materiaXplanXcomision INT)
BEGIN
    DECLARE estado_materia VARCHAR(50);

    -- Verificar si el alumno está regular en la materia
    SELECT estado INTO estado_materia
    FROM inscripcion_materia
    WHERE id_alumno = p_id_alumno AND id_materiaXplanXcomision = p_id_materiaXplanXcomision;

    IF estado_materia != 'Regular' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El alumno no está regular en la materia, no puede inscribirse al examen';
    ELSE
        INSERT INTO inscripcion_examen (id_inscripcion_examen, fecha_inscripcion, fecha_examen, nota)
        VALUES (NULL, CURDATE(), CURDATE(), NULL);
    END IF;
END //

-- Registrar nota de examen final
CREATE PROCEDURE registrar_nota_examen(IN p_id_alumno INT, IN p_id_materiaXplanXcomision INT, IN p_nota DECIMAL(5,2))
BEGIN
    DECLARE inscripcion_existe INT;

    -- Verificar si el alumno está inscrito en el examen
    SELECT COUNT(*) INTO inscripcion_existe
    FROM inscripcion_examen ie
    JOIN inscripcion_materia im ON im.id_insc_materia = ie.id_inscripcion_examen
    WHERE im.id_alumno = p_id_alumno AND im.id_materiaXplanXcomision = p_id_materiaXplanXcomision;

    IF inscripcion_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe inscripción al examen para este alumno';
    ELSE
        UPDATE inscripcion_examen
        SET nota = p_nota
        WHERE id_inscripcion_examen = (SELECT id_inscripcion_examen FROM inscripcion_examen ie
                                       JOIN inscripcion_materia im ON ie.id_inscripcion_examen = im.id_insc_materia
                                       WHERE im.id_alumno = p_id_alumno AND im.id_materiaXplanXcomision = p_id_materiaXplanXcomision);

        -- Verificar si la nota es válida
        IF p_nota < 0 OR p_nota > 10 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La nota debe estar entre 0 y 10';
        END IF;
    END IF;
END //

DELIMITER ;
