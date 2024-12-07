-- Crear la base de datos
CREATE DATABASE CanchaLibre;

-- Seleccionar la base de datos recién creada
USE CanchaLibre;

-- Crear la tabla 'clubs' para almacenar la información de los clubes
CREATE TABLE clubs (
    id INT AUTO_INCREMENT PRIMARY KEY,            -- ID único para cada club
    usuario VARCHAR(255) NOT NULL,                -- Nombre de usuario del club
    nombre VARCHAR(255) NOT NULL,                 -- Nombre del club
    direccion VARCHAR(255) NOT NULL,              -- Dirección del club
    telefono VARCHAR(255) NOT NULL,               -- Teléfono del club
    cantidad_canchas INT NOT NULL,                -- Número de canchas del club
    estacionamiento BOOLEAN,                      -- Estacionamiento disponible (TRUE o FALSE)
    vestuarios BOOLEAN                           -- Vestuarios disponibles (TRUE o FALSE)
);

ALTER TABLE clubs MODIFY COLUMN estacionamiento INT;
ALTER TABLE clubs MODIFY COLUMN vestuarios INT;
-- Verificar que los datos se hayan guardado correctamente
SELECT * FROM clubs;
use CanchaLibre;
describe clubs;