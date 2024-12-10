// import 'dart:async';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
//
// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;
//
//   static Database? _database;
//
//   DatabaseHelper._internal();
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }
//
//   Future<Database> _initDatabase() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, 'club_database.db');
//
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         // Crear la tabla para los clubes
//         await db.execute('''
//           CREATE TABLE club (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             usuario TEXT NOT NULL,
//             nombre TEXT,
//             direccion TEXT,
//             telefono TEXT,
//             cantidad_canchas INTEGER,
//             estacionamiento INTEGER,
//             vestuarios INTEGER
//           )
//         ''');
//       },
//     );
//   }
//
//   Future<int> insertClub(Map<String, dynamic> club) async {
//     final db = await database;
//     return await db.insert('club', club);
//   }
//
//   Future<Map<String, dynamic>?> getClubByUsuario(String usuario) async {
//     final db = await database;
//     final result = await db.query(
//       'club',
//       where: 'usuario = ?',
//       whereArgs: [usuario],
//     );
//     return result.isNotEmpty ? result.first : null;
//   }
//
//   Future<int> updateClub(int id, Map<String, dynamic> club) async {
//     final db = await database;
//     return await db.update(
//       'club',
//       club,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
// }
