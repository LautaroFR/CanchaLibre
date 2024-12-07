const express = require('express');
const mysql = require('mysql2');
const app = express();
const port = 3001;

app.use(express.json()); // Para parsear los datos en formato JSON

// Crear una conexión con la base de datos MySQL
const pool = mysql.createPool({
    host: 'localhost',
    user: 'root', // Usuario MySQL
    password: 'lauchafr', // Contraseña MySQL
    database: 'CanchaLibre' // Nombre de la base de datos
});

// Ruta GET para obtener todos los clubes
app.get('/clubs', (req, res) => {
    const usuario = req.query.usuario; // Extrae el parámetro `usuario` de la URL

    if (usuario && usuario.trim() === '') {
        // Si `usuario` está presente pero vacío
        return res.status(400).json({ message: 'Usuario no ' });
    }

    const query = usuario
        ? 'SELECT * FROM clubs WHERE usuario = ?'
        : 'SELECT * FROM clubs';

    const params = usuario ? [usuario] : [];

    pool.execute(query, params, (err, rows) => {
        if (err) {
            return res.status(500).json({ message: 'Error al obtener los clubes', error: err });
        }
        res.json(rows); // Devuelve todos los clubes o los que coinciden con el usuario
    });
});


// Ruta POST para crear un nuevo club
app.post('/clubs', async (req, res) => {
    const { usuario, nombre, direccion, telefono, cantidadCanchas, estacionamiento, vestuarios } = req.body;

    // Verificar que todos los campos estén presentes
    if (!usuario || !nombre || !direccion || !telefono || !cantidadCanchas) {
        return res.status(400).json({ message: 'Faltan datos en la solicitud' });
    }

    try {
        pool.execute(
            'INSERT INTO clubs (usuario, nombre, direccion, telefono, cantidad_canchas, estacionamiento, vestuarios) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [usuario, nombre, direccion, telefono, cantidadCanchas, estacionamiento, vestuarios],
            (err, result) => {
                if (err) {
                    return res.status(500).json({ message: 'Error al crear el club', error: err });
                }
                res.status(201).json({ message: 'Club creado correctamente', clubId: result.insertId });
            }
        );
    } catch (error) {
        res.status(500).json({ message: 'Error al crear el club', error });
    }
});

// Iniciar el servidor
app.listen(port, () => {
    console.log(`Servidor escuchando en http://localhost:${port}`);
});
