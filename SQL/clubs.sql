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

-- Crear tabla para las canchas
CREATE TABLE canchas (
    id INT AUTO_INCREMENT PRIMARY KEY,          -- ID único de la cancha
    club_id INT NOT NULL,                       -- ID del club al que pertenece
    numero INT NOT NULL,                        -- Número de la cancha
    tamano INT NOT NULL,                        -- Tamaño de la cancha
    superficie ENUM('Sintético', 'Natural', 'Cemento', 'Parquet', 'Otro') NOT NULL, -- Tipo de superficie
    luz BOOLEAN,                                -- Si tiene luz
    techada BOOLEAN,                            -- Si está techada
    precio INT NOT NULL,                        -- Precio por hora de la cancha
    FOREIGN KEY (club_id) REFERENCES clubs(id)  -- Relación con la tabla de clubes
);
ALTER TABLE canchas MODIFY COLUMN techada INT;
ALTER TABLE canchas MODIFY COLUMN luz INT;
-- Verificar que la tabla se creó correctamente
DESCRIBE canchas;
