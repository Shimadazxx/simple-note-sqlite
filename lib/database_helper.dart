
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class DatabaseHelper {

  // 1. Fungsi membuat tabel database
  static Future<void> createTables(
      sql.Database database) async {
    await database.execute("""
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        description TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    """);
  }

  // 2. Fungsi inisialisasi / membuka database
  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'simplenote.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // 3. Create - Tambah catatan baru
  static Future<int> createItem(
      String? title, String? description) async {

    final db = await DatabaseHelper.db();

    final data = {
      'title': title,
      'description': description,
    };

    final id = await db.insert(
      'items',
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );

    return id;
  }

  // 4. Read - Ambil semua data catatan
  static Future<List<Map<String, Object?>>> getItems() async {

    final db = await DatabaseHelper.db();

    return db.query(
      'items',
      orderBy: "id",
    );
  }

  // 5. Update - Perbarui data catatan
  static Future<int> updateItem(
      int id, String title, String? description) async {

    final db = await DatabaseHelper.db();

    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toString(),
    };

    final result = await db.update(
      'items',
      data,
      where: "id = ?",
      whereArgs: [id],
    );

    return result;
  }

  // 6. Delete - Hapus data catatan
  static Future<void> deleteItem(int id) async {

    final db = await DatabaseHelper.db();

    try {
      await db.delete(
        "items",
        where: "id = ?",
        whereArgs: [id],
      );
    } catch (err) {
      debugPrint(
        "Something went wrong when deleting an item: $err",
      );
    }
  }
}
