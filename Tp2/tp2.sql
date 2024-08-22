DROP DATABASE IF EXISTS VENTAS;

CREATE DATABASE VENTAS;

CREATE TABLE Clientes(
    Codcli INT PRIMARY KEY,
    Nomcli VARCHAR(50) NOT NULL,
    Provincia VARCHAR(50) NOT NULL
);

CREATE TABLE Productos(
    Codpro INT PRIMARY KEY,
    Nompro VARCHAR(50) NOT NULL,
    Precio FLOAT NOT NULL,
    CHECK (Precio>0)
);

CREATE TABLE Ventas(
    NumeroVenta INT PRIMARY KEY,
    Codcli INT NOT NULL,
    Codpro INT NOT NULL,
    Fecha DATE NOT NULL,
    Cantidad INT NOT NOT,
    Precio FLOAT NOT NULL,
    Total FLOAT NOT NULL,
    CHECK (Cantidad>0),
    CHECK (Precio>0),
    CHECK (Total>0),
    FOREIGN KEY(Codcli) REFERENCES Clientes(Codcli),
    FOREIGN KEY(Codpro) REFERENCES Productos(Codpro)
);