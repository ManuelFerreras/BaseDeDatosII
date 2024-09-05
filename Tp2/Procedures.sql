DELIMITER //

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

DELIMITER ;