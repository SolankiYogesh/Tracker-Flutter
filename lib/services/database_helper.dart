import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tracker/models/location_point.dart';
import 'package:tracker/models/user_response.dart';

const settingTable = 'app_settings';
const locationTable = 'locations';
const userTable = 'app_user';

const entityTable = 'entities';
const userStatsTable = 'user_stats';
const travelActivityTable = 'travel_activities';

class DatabaseHelper {
  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'location_tracker.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $locationTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        recorded_at INTEGER NOT NULL,
        accuracy REAL,
        altitude REAL,
        speed REAL,
        bearing REAL,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_locations_user_time ON $locationTable(user_id, recorded_at)
    ''');

    await db.execute('''
      CREATE INDEX idx_locations_synced ON $locationTable(is_synced)
    ''');

    await db.execute('''
      CREATE TABLE $settingTable(
        id INTEGER PRIMARY KEY,
        isDark INTEGER
      )
    ''');

    await db.execute('''
    CREATE TABLE $userTable (
      id TEXT PRIMARY KEY,
      email TEXT NOT NULL,
      name TEXT,
      picture TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER
    )
  ''');

    await _createEntityTable(db);
    await _createUserStatsTable(db);
    await _createTravelActivityTable(db);

    await db.insert(settingTable, {'id': 1, 'isDark': 1});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createEntityTable(db);
    }
    if (oldVersion < 3) {
      await _createUserStatsTable(db);
    }
    if (oldVersion < 4) {
      await _createTravelActivityTable(db);
    }
  }

  Future<void> _createUserStatsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $userStatsTable (
        id INTEGER PRIMARY KEY DEFAULT 1,
        total_steps INTEGER DEFAULT 0,
        last_boot_step_count INTEGER DEFAULT 0,
        last_updated_at INTEGER
      )
    ''');
    // Initialize with default row
    await db.insert(userStatsTable, {
      'id': 1,
      'total_steps': 0,
      'last_boot_step_count': 0,
      'last_updated_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _createEntityTable(Database db) async {
    await db.execute('''
      CREATE TABLE $entityTable (
        id TEXT PRIMARY KEY,
        entity_type_id TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        spawn_radius REAL NOT NULL,
        xp_value INTEGER NOT NULL,
        is_collected INTEGER DEFAULT 0,
        type_name TEXT,
        type_icon_url TEXT,
        type_rarity TEXT
      )
    ''');
  }

  Future<void> _createTravelActivityTable(Database db) async {
    await db.execute('''
      CREATE TABLE $travelActivityTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        distance REAL NOT NULL,
        user_id TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_travel_user_time ON $travelActivityTable(user_id, start_time)
    ''');
  }

  Future<void> saveUser(UserResponse user) async {
    final db = await database;

    await db.insert(userTable, {
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
    final res = await db.query(userTable, limit: 1);

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
      settingTable,
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
      settingTable,
      {'isDark': isDark ? 1 : 0},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<int> insertLocation(LocationPoint location) async {
    final db = await database;
    return await db.insert(locationTable, location.toMap());
  }

  Future<List<LocationPoint>> getUnsyncedLocations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      locationTable,
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'recorded_at ASC',
    );
    return List.generate(maps.length, (i) => LocationPoint.fromMap(maps[i]));
  }

  Future<void> markLocationsAsSynced(List<int> ids) async {
    final db = await database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final id in ids) {
        batch.update(
          locationTable,
          {'is_synced': 1},
          where:
              'recorded_at = ?', // Using recorded_at as unique identifier since we don't have ID in model
          whereArgs: [id],
        );
      }
      await batch.commit(noResult: true);
    });
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
      locationTable,
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
    await db.delete(userTable);
  }

  // --- Entity Methods ---

  Future<void> saveEntities(List<dynamic> entities) async {
    final db = await database;
    await db.transaction((txn) async {
      for (final dynamic entity in entities) {
        // We use dynamic here but expect Entity objects or compatible Maps
        // Assuming Entity objects, using .toMap()
        await txn.insert(
          entityTable,
          (entity as dynamic).toMap() as Map<String, Object?>,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Map<String, dynamic>>> getUncollectedEntities() async {
    final db = await database;
    return await db.query(
      entityTable,
      where: 'is_collected = ?',
      whereArgs: [0],
    );
  }

  Future<List<Map<String, dynamic>>> getUncollectedEntitiesInBounds({
    required double minLat,
    required double maxLat,
    required double minLon,
    required double maxLon,
  }) async {
    final db = await database;
    return await db.query(
      entityTable,
      where:
          'is_collected = ? AND latitude BETWEEN ? AND ? AND longitude BETWEEN ? AND ?',
      whereArgs: [0, minLat, maxLat, minLon, maxLon],
    );
  }

  Future<void> markEntityAsCollected(String id) async {
    final db = await database;
    await db.update(
      entityTable,
      {'is_collected': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearEntities() async {
    final db = await database;
    await db.delete(entityTable);
  }

  // --- Stats Methods ---

  Future<Map<String, dynamic>> getUserStats() async {
    final db = await database;
    final res = await db.query(userStatsTable, where: 'id = ?', whereArgs: [1]);
    if (res.isNotEmpty) {
      return res.first;
    }
    return {'total_steps': 0};
  }

  Future<void> updateUserSteps(int currentSensorSteps) async {
    final db = await database;
    final stats = await getUserStats();

    int totalSteps = stats['total_steps'] as int? ?? 0;
    int lastBootSteps = stats['last_boot_step_count'] as int? ?? 0;

    // If the sensor steps are LESS than the last boot steps,
    // it implies a device reboot happened (sensor reset to 0).
    if (currentSensorSteps < lastBootSteps) {
      lastBootSteps = 0;
    }

    // Calculate the difference since the last check
    int diff = currentSensorSteps - lastBootSteps;

    // We expect diff to be positive as steps increase.
    // If it's negative (and not caught by the reboot check above, though unlikely given logic), ignore or handle.
    if (diff < 0) diff = 0;

    totalSteps += diff;

    await db.update(
      userStatsTable,
      {
        'total_steps': totalSteps,
        'last_boot_step_count': currentSensorSteps,
        'last_updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // --- Travel Activity Methods ---

  Future<int> insertTravelActivity(Map<String, dynamic> activity) async {
    final db = await database;
    return await db.insert(travelActivityTable, activity);
  }

  Future<List<Map<String, dynamic>>> getTravelActivities({
    required String userId,
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await database;
    String? whereClause = 'user_id = ?';
    List<dynamic> whereArgs = [userId];

    if (from != null) {
      whereClause += ' AND start_time >= ?';
      whereArgs.add(from.millisecondsSinceEpoch);
    }

    if (to != null) {
      whereClause += ' AND end_time <= ?';
      whereArgs.add(to.millisecondsSinceEpoch);
    }

    return await db.query(
      travelActivityTable,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'start_time DESC',
    );
  }
}
