import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/chat_room.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'retrospective_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        reflection_count INTEGER DEFAULT 0,
        joined_chat_room_ids TEXT,
        morning_notification_time INTEGER,
        evening_notification_time INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER
      )
    ''');

    // Reflections table
    await db.execute('''
      CREATE TABLE reflections(
        id TEXT PRIMARY KEY,
        date INTEGER NOT NULL,
        morning_goals TEXT,
        keep TEXT,
        problem TEXT,
        try_items TEXT,
        is_completed INTEGER DEFAULT 0,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    // Chat rooms table
    await db.execute('''
      CREATE TABLE chat_rooms(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        owner_id TEXT NOT NULL,
        member_ids TEXT,
        max_members INTEGER DEFAULT 10,
        min_members INTEGER DEFAULT 2,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_reflections_date ON reflections(date)');
    await db
        .execute('CREATE INDEX idx_chat_rooms_owner ON chat_rooms(owner_id)');
  }

  // User operations
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }

  // Reflection operations
  Future<int> insertReflection(Map<String, dynamic> reflection) async {
    final db = await database;
    return await db.insert('reflections', reflection);
  }

  Future<Map<String, dynamic>?> getReflectionByDate(DateTime date) async {
    final db = await database;
    final startOfDay =
        DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59)
        .millisecondsSinceEpoch;

    final result = await db.query(
      'reflections',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startOfDay, endOfDay],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getReflectionsByDateRange(
      DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.query(
      'reflections',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'date DESC',
    );

    return result;
  }

  Future<int> updateReflection(Map<String, dynamic> reflection) async {
    final db = await database;
    return await db.update(
      'reflections',
      reflection,
      where: 'id = ?',
      whereArgs: [reflection['id']],
    );
  }

  Future<int> getReflectionCountForLast90Days() async {
    final db = await database;
    final ninetyDaysAgo = DateTime.now()
        .subtract(const Duration(days: 90))
        .millisecondsSinceEpoch;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM reflections WHERE date >= ? AND is_completed = 1',
      [ninetyDaysAgo],
    );

    return result.first['count'] as int;
  }

  // Chat room operations
  Future<int> insertChatRoom(ChatRoom chatRoom) async {
    final db = await database;
    return await db.insert('chat_rooms', chatRoom.toJson());
  }

  Future<List<ChatRoom>> getAllChatRooms() async {
    final db = await database;
    final result = await db.query('chat_rooms',
        where: 'is_active = 1', orderBy: 'created_at DESC');
    return result.map((json) => ChatRoom.fromJson(json)).toList();
  }

  Future<ChatRoom?> getChatRoomById(String id) async {
    final db = await database;
    final result =
        await db.query('chat_rooms', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return ChatRoom.fromJson(result.first);
    }
    return null;
  }

  Future<int> updateChatRoom(ChatRoom chatRoom) async {
    final db = await database;
    return await db.update(
      'chat_rooms',
      chatRoom.toJson(),
      where: 'id = ?',
      whereArgs: [chatRoom.id],
    );
  }

  Future<List<ChatRoom>> getChatRoomsByUserId(String userId) async {
    final db = await database;
    final result = await db.query(
      'chat_rooms',
      where: 'member_ids LIKE ? AND is_active = 1',
      whereArgs: ['%$userId%'],
    );
    return result.map((json) => ChatRoom.fromJson(json)).toList();
  }
}
