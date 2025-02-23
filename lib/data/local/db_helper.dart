import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper._();
  static final DBHelper getInstance = DBHelper._();

  static const String TABLE_NOTES = 'notes';
  static const String COL_NOTE_SNO = 's_no';
  static const String COL_NOTE_TITLE = 'title';
  static const String COL_NOTE_DESC = 'description';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, 'noteDB.db');
    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $TABLE_NOTES (
            $COL_NOTE_SNO INTEGER PRIMARY KEY AUTOINCREMENT,
            $COL_NOTE_TITLE TEXT,
            $COL_NOTE_DESC TEXT
          )
        ''');
      },
    );
  }

  Future<bool> addNote({required String title, required String desc}) async {
    Database db = await database;
    int result = await db.insert(TABLE_NOTES, {
      COL_NOTE_TITLE: title,
      COL_NOTE_DESC: desc,
    });
    return result > 0;
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    Database db = await database;
    return db.query(TABLE_NOTES);
  }

  Future<bool> updateNote({required int sNo, required String title, required String desc,}) async {
    Database db = await database;
    int result = await db.update(
      TABLE_NOTES,
      {COL_NOTE_TITLE: title, COL_NOTE_DESC: desc},
      where: '$COL_NOTE_SNO = $sNo',
    );
    return result > 0;
  }


  Future<bool> deleteNote({required int sNo}) async {
    Database db = await database;
    int result = await db.delete(
      TABLE_NOTES,
      where: '$COL_NOTE_SNO = ?', whereArgs: [sNo],
    );
    return result > 0;
  }
}