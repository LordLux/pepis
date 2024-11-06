import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'people.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE people(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            gender TEXT,
            birthDate TEXT,
            year INTEGER,
            total REAL,
            kiA INTEGER,
            kiB INTEGER
          )
          ''',
        );
      },
    );
  }

  // CRUD Operations
  Future<int> insertPerson(FengShuiModel person) async {
    try {
      final db = await database;
      await db.insert('people', person.toMap());
      
      print('Person ${person.name} inserted');
      return 0;
    } catch (e) {
      print('DB Error: $e');
      return 1;
    }
  }

  Future<List<FengShuiModel>> getPeople() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('people');
    return List.generate(maps.length, (i) {
      return FengShuiModel.fromMap(maps[i]);
    });
  }

  Future<int> updatePerson(FengShuiModel person) async {
    final db = await database;
    return await db.update(
      'people',
      person.toMap(),
      where: 'id = ?',
      whereArgs: [person.id],
    );
  }

  Future<int> deletePerson(int id) async {
    final db = await database;
    return await db.delete(
      'people',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
