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
        return res.status(400).json({ message: 'Usuario no proporcionado' });
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

// Ruta POST para agregar un nuevo club
app.post('/clubs', (req, res) => {
    const { usuario, nombre, direccion, telefono, cantidad_canchas, estacionamiento, vestuarios } = req.body;

    // Verificar que todos los datos estén presentes
    if (!usuario || !nombre || !direccion || !telefono || cantidad_canchas === undefined) {
        return res.status(400).json({ message: 'Faltan datos en la solicitud' });
    }

    const query = `
    INSERT INTO clubs (usuario, nombre, direccion, telefono, cantidad_canchas, estacionamiento, vestuarios)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `;
    const params = [usuario, nombre, direccion, telefono, cantidad_canchas, estacionamiento, vestuarios];

    pool.execute(query, params, (err, result) => {
        if (err) {
            return res.status(500).json({ message: 'Error al agregar el club', error: err });
        }
        res.status(201).json({ message: 'Club agregado correctamente', id: result.insertId });
    });
});


// Ruta PUT para actualizar un club por usuario
app.put('/clubs/:usuario', (req, res) => {
    const { usuario } = req.params;
    const { nombre, direccion, telefono, cantidad_canchas, estacionamiento, vestuarios } = req.body;

    // Verificar que los datos estén presentes
    if (!nombre || !direccion || !telefono || cantidad_canchas === null || cantidad_canchas === undefined) {
        return res.status(400).json({ message: 'Faltan datos en la solicitud' });
    }

    console.log('Datos recibidos:', req.body); // Para depuración

    // Actualizar los datos del club en la base de datos
    const query = `
    UPDATE clubs SET
      nombre = ?, direccion = ?, telefono = ?, cantidad_canchas = ?, estacionamiento = ?, vestuarios = ?
    WHERE usuario = ?
  `;
    const params = [nombre, direccion, telefono, cantidad_canchas, estacionamiento, vestuarios, usuario];

    pool.execute(query, params, (err, result) => {
        if (err) {
            return res.status(500).json({ message: 'Error al actualizar el club', error: err });
        }

        // Verificar si se actualizó algún registro
        if (result.affectedRows > 0) {
            res.status(200).json({ message: 'Club actualizado correctamente' });
        } else {
            res.status(404).json({ message: 'Usuario no encontrado' });
        }
    });
});

// Ruta POST para agregar una cancha
app.post('/canchas', (req, res) => {
    const { club_id, numero, tamano, superficie, luz, techada, precio } = req.body;

    if (!club_id || !numero || !tamano || !superficie || precio === undefined) {
        return res.status(400).json({ message: 'Faltan datos en la solicitud' });
    }

    const query = `
        INSERT INTO canchas (club_id, numero, tamano, superficie, luz, techada, precio)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    `;
    const params = [club_id, numero, tamano, superficie, luz, techada, precio];

    pool.execute(query, params, (err, result) => {
        if (err) {
            return res.status(500).json({ message: 'Error al agregar la cancha', error: err });
        }
        res.status(201).json({ message: 'Cancha agregada correctamente', id: result.insertId });
    });
});
// Ruta GET para obtener las canchas de un club
app.get('/canchas/:club_id', (req, res) => {
    const { club_id } = req.params;

    const query = 'SELECT * FROM canchas WHERE club_id = ?';

    pool.execute(query, [club_id], (err, rows) => {
        if (err) {
            return res.status(500).json({ message: 'Error al obtener las canchas', error: err });
        }
        res.json(rows); // Devuelve todas las canchas del club
    });
});
// Ruta PUT para actualizar una cancha
app.put('/canchas/:id', (req, res) => {
    const { id } = req.params;
    const { numero, tamano, superficie, luz, techada, precio } = req.body;

    const query = `
        UPDATE canchas SET
            numero = ?, tamano = ?, superficie = ?, luz = ?, techada = ?, precio = ?
        WHERE id = ?
    `;
    const params = [numero, tamano, superficie, luz, techada, precio, id];

    pool.execute(query, params, (err, result) => {
        if (err) {
            return res.status(500).json({ message: 'Error al actualizar la cancha', error: err });
        }

        if (result.affectedRows > 0) {
            res.status(200).json({ message: 'Cancha actualizada correctamente' });
        } else {
            res.status(404).json({ message: 'Cancha no encontrada' });
        }
    });
});


// Iniciar el servidor
app.listen(port, '0.0.0.0', () => {
    console.log(`Servidor escuchando en http://0.0.0.0:${port}`);
});
