-- Crear usuario profesor con privilegios completos (administrador)
CREATE USER 'administrativo_acad'@'localhost' IDENTIFIED BY 'password_profesor';
GRANT ALL PRIVILEGES ON acad.* TO 'profesor_acad'@'localhost';

-- Crear usuario alumno con privilegios de lectura (SELECT)
CREATE USER 'alumno_acad'@'localhost' IDENTIFIED BY 'password_alumno';
GRANT SELECT ON acad.* TO 'alumno_acad'@'localhost';

-- Crear usuario administrativo con privilegios de escritura (INSERT, UPDATE, DELETE)
CREATE USER 'profesor_acad'@'localhost' IDENTIFIED BY 'password_administrativo';
GRANT INSERT, UPDATE, DELETE ON acad.* TO 'administrativo_acad'@'localhost';

-- Aplicar los cambios de privilegios
FLUSH PRIVILEGES;
