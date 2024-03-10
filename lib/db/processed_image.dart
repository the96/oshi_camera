import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';

class ProcessedImage {
  int id;
  String name;
  Uint8List bytes;
  DateTime createdAt;

  ProcessedImage({
    required this.id,
    required this.name,
    required this.bytes,
    required this.createdAt,
  });

  ProcessedImage.create(
    String _name,
    Uint8List _bytes,
  )   : id = 0,
        name = _name,
        bytes = _bytes,
        createdAt = DateTime.now();

  ProcessedImage.fromMap(
    Map<String, Object?> map,
  )   : id = map['id'] as int,
        name = map['name'] as String,
        bytes = map['bytes'] as Uint8List,
        createdAt = DateTime.parse(map['createdAt'] as String).toLocal();

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'bytes': bytes,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}

class ProcessedImageProvider {
  static const TABLE_NAME = 'processed_images';
  static const String create = """
CREATE TABLE $TABLE_NAME (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    bytes BLOB NOT NULL,
    createdAt TEXT NOT NULL
);
""";

  static Future<ProcessedImage> insert(
    Database db,
    ProcessedImage processedImage,
  ) async {
    final values = processedImage.toMap();
    values.remove('id');
    final id = await db.insert(
      TABLE_NAME,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    processedImage.id = id;
    return processedImage;
  }

  static Future<ProcessedImage> find(
    Database db,
    int id,
  ) async {
    final maps = await db.query(
      TABLE_NAME,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      throw Exception('Record not found');
    }

    return ProcessedImage.fromMap(maps.first);
  }

  static Future<List<ProcessedImage>> all(
    Database db,
  ) async {
    final rows = await db.query(TABLE_NAME, orderBy: 'id DESC');
    return rows.map((row) => ProcessedImage.fromMap(row)).toList();
  }

  static Future<bool> delete(
    Database db,
    int id,
  ) async {
    final result = await db.delete(
      TABLE_NAME,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }

  static Future<bool> update(
    Database db,
    ProcessedImage processedImage,
  ) async {
    final result = await db.update(
      TABLE_NAME,
      processedImage.toMap(),
      where: 'id = ?',
      whereArgs: [processedImage.id],
    );
    return result > 0;
  }
}
