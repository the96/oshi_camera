import 'package:oshi_camera/schema.dart';
import 'package:sqflite/sqflite.dart';

const String databaseName = 'oshi_camera.db';
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
