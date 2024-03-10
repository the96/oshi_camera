import 'package:oshi_camera/db/processed_image.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHandler {
  static const String databaseName = 'oshi_camera.db';
  static DatabaseHandler? _instance;
  late Database db;

  factory DatabaseHandler() {
    _instance ??= DatabaseHandler._internal();
    return _instance!;
  }

  DatabaseHandler._internal();

  Future<void> init() async {
    final schema = [ProcessedImageProvider.create];

    db = await openDatabase(
      databaseName,
      version: 1,
      onCreate: (db, version) async {
        await Future.wait(
          schema.map((table) async {
            db.execute(table);
          }),
        );
      },
    );
  }
}
