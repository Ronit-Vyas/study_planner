import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(jsonDecode(source) as Map<String, dynamic>);

//SQFLITE DATABASE INTEGRATED

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    return await initDatabase();
  }


  static Future<Database> initDatabase() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    _database = await openDatabase(
      'study_planner.db',
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS courses');
          await db.execute('DROP TABLE IF EXISTS topics');
          await db.execute('DROP TABLE IF EXISTS tasks');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS users (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              email TEXT NOT NULL UNIQUE,
              password TEXT NOT NULL,
              created_at INTEGER NOT NULL
            )
          ''');
        }
      },
    );

    return _database!;
  }

  static Future<int> insertUser(Map<String, dynamic> userRow) async {
    final db = await database;
    return await db.insert(
      'users',
      userRow,
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  static Future<Map<String, dynamic>?> findByEmail(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return results.first;
  }

  static Future<Map<String, dynamic>?> findById(String id) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return results.first;
  }

  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}