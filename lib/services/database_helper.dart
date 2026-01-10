import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tracker/models/location_point.dart';
import 'package:tracker/models/user_response.dart';

final SETTING_TABLE = "app_settings";
final LOCATION_TABLE = "locations";
final USER_TABLE = "app_user";

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'location_tracker.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $LOCATION_TABLE (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        recorded_at INTEGER NOT NULL,
        accuracy REAL,
        altitude REAL,
        speed REAL,
        bearing REAL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_locations_user_time ON $LOCATION_TABLE(user_id, recorded_at)
    ''');

    await db.execute('''
      CREATE TABLE $SETTING_TABLE(
        id INTEGER PRIMARY KEY,
        isDark INTEGER
      )
    ''');

    await db.execute('''
    CREATE TABLE $USER_TABLE (
      id TEXT PRIMARY KEY,
      email TEXT NOT NULL,
      name TEXT,
      picture TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER
    )
  ''');
    await db.insert(SETTING_TABLE, {'id': 1, 'isDark': 1});
  }

  Future<void> saveUser(UserResponse user) async {
    final db = await database;

    await db.insert(USER_TABLE, {
      'id': user.id,
      'email': user.email,
      'name': user.name,
      'picture': user.picture,
      'created_at': user.createdAt.millisecondsSinceEpoch,
      'updated_at': user.updatedAt?.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserResponse?> getCurrentUser() async {
    final db = await database;
    final res = await db.query(USER_TABLE, limit: 1);

    if (res.isEmpty) return null;

    final row = res.first;
    return UserResponse(
      id: row['id'] as String,
      email: row['email'] as String,
      name: row['name'] as String?,
      picture: row['picture'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      updatedAt: row['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int)
          : null,
    );
  }

  Future<bool> getIsDarkTheme() async {
    final db = await database;
    final result = await db.query(
      SETTING_TABLE,
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['isDark'] == 1;
    }
    return false;
  }

  Future<void> setIsDarkTheme(bool isDark) async {
    final db = await database;
    await db.update(
      SETTING_TABLE,
      {'isDark': isDark ? 1 : 0},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<int> insertLocation(LocationPoint location) async {
    final db = await database;
    return await db.insert(LOCATION_TABLE, location.toMap());
  }

  Future<List<LocationPoint>> getLocations({String? userId}) async {
    final db = await database;

    String? whereClause;
    List<dynamic>? whereArgs;

    if (userId != null) {
      whereClause = 'user_id = ?';
      whereArgs = [userId];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      LOCATION_TABLE,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'recorded_at ASC',
    );

    return List.generate(maps.length, (i) => LocationPoint.fromMap(maps[i]));
  }

  Future<int> clearLocations({String? userId}) async {
    final db = await database;

    if (userId != null) {
      return await db.delete(
        'locations',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }

    return await db.delete('locations');
  }

  Future<void> clearUser() async {
    final db = await database;
    await db.delete(USER_TABLE);
  }
}
