import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocationPoint {
  final int? id;
  final double lat;
  final double lon;
  final int timestamp;
  final int sessionId;

  LocationPoint({
    this.id,
    required this.lat,
    required this.lon,
    required this.timestamp,
    required this.sessionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lat': lat,
      'lon': lon,
      'timestamp': timestamp,
      'sessionId': sessionId,
    };
  }

  factory LocationPoint.fromMap(Map<String, dynamic> map) {
    return LocationPoint(
      id: map['id'],
      lat: map['lat'],
      lon: map['lon'],
      timestamp: map['timestamp'],
      sessionId: map['sessionId'],
    );
  }
}

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
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE locations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lat REAL,
        lon REAL,
        timestamp INTEGER,
        sessionId INTEGER
      )
    ''');
  }

  Future<int> insertLocation(LocationPoint location) async {
    Database db = await database;
    return await db.insert('locations', location.toMap());
  }

  Future<List<LocationPoint>> getLocations() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('locations', orderBy: 'timestamp ASC');
    return List.generate(maps.length, (i) {
      return LocationPoint.fromMap(maps[i]);
    });
  }

  Future<List<LocationPoint>> getLocationsBySession(int sessionId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'locations',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );
    return List.generate(maps.length, (i) {
      return LocationPoint.fromMap(maps[i]);
    });
  }

  Future<int> clearLocations() async {
    Database db = await database;
    return await db.delete('locations');
  }
}
