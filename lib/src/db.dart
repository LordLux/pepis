import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  static List<FengShuiModel> people = [];

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
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            name TEXT NOT NULL,
            gender INTEGER NOT NULL,
            birthDate TEXT NOT NULL,
            total INTEGER NOT NULL,
            kiA INTEGER NOT NULL,
            kiB INTEGER NOT NULL,
            kua INTEGER NOT NULL,
            energy INTEGER NOT NULL,
            ki TEXT NOT NULL,
            direction INTEGER NOT NULL,
            material INTEGER NOT NULL,
            starDistribution TEXT NOT NULL
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
    people = List.generate(maps.length, (i) {
      return FengShuiModel.fromMap(maps[i]);
    });
    return people;
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

  Future<void> clearDatabase() async {
    final db = await database;
    final tables = ['people'];
    for (final table in tables) await db.delete(table);
    print('Database cleared!');
  }
}

Future<void> deleteDatabaseFile() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'people.db');
  await deleteDatabase(path);
}
