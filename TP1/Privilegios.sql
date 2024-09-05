CREATE USER 'administrativo_acad'@'localhost' IDENTIFIED BY 'password_profesor';
GRANT ALL PRIVILEGES ON acad.* TO 'profesor_acad'@'localhost';

CREATE USER 'alumno_acad'@'localhost' IDENTIFIED BY 'password_alumno';
GRANT SELECT ON acad.* TO 'alumno_acad'@'localhost';

CREATE USER 'profesor_acad'@'localhost' IDENTIFIED BY 'password_administrativo';
GRANT INSERT, UPDATE, DELETE ON acad.* TO 'administrativo_acad'@'localhost';

FLUSH PRIVILEGES;
