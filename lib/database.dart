import 'package:oshi_camera/model/processed_image.dart';
import 'package:oshi_camera/schema.dart';
import 'package:sqflite/sqflite.dart';

const String databaseName = 'oshi_camera.db';
const List<String> schema = [
  ProcessedImage.createTable,
];
late Database db;

Future<Database> initDatabase() async {
  print('initDatabase');

  await deleteDatabase(databaseName);

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

  return db;
}
