import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/cart_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'meal4u_cart.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cart_items(
            id TEXT PRIMARY KEY,
            name TEXT,
            size TEXT,
            price REAL,
            imageUrl TEXT,
            quantity INTEGER
          )
        ''');
      },
    );
  }

  Future<void> insertItem(CartItem item) async {
    final db = await database;
    await db.insert(
      'cart_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CartItem>> getItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cart_items');
    return List.generate(maps.length, (i) {
      return CartItem.fromMap(maps[i]);
    });
  }

  Future<void> updateItem(CartItem item) async {
    final db = await database;
    await db.update(
      'cart_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteItem(String id) async {
    final db = await database;
    await db.delete('cart_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }
}
