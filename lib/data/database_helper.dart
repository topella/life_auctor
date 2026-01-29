import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static final _lock = Lock();

  static const String _databaseName = 'life_auctor.db';
  static const int _databaseVersion = 7;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  // safe database getter with lock to prevent race conditions
  Future<Database> get database async {
    if (_database != null) return _database!;

    return await _lock.synchronized(() async {
      //double-check inside lock
      if (_database != null) return _database!;
      _database = await _initDatabase();
      return _database!;
    });
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = '$databasesPath/$_databaseName';

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        expiryDate INTEGER,
        quantity TEXT,
        location TEXT,
        notes TEXT,
        price REAL,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        isConsumed INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE shopping_lists(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT,
        priority TEXT,
        itemIds TEXT NOT NULL,
        enableNotifications INTEGER NOT NULL DEFAULT 0,
        autoAddToCalendar INTEGER NOT NULL DEFAULT 0,
        tags TEXT,
        createdAt INTEGER NOT NULL,
        inStockCount INTEGER NOT NULL DEFAULT 0,
        runOutCount INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE history_events(
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        subtitle TEXT,
        timestamp INTEGER NOT NULL,
        itemId TEXT,
        listId TEXT
      )
    ''');

    await db.execute('CREATE INDEX idx_items_category ON items(category)');
    await db.execute('CREATE INDEX idx_items_expiry ON items(expiryDate)');
    await db.execute('CREATE INDEX idx_items_favorite ON items(isFavorite)');
    await db.execute('CREATE INDEX idx_items_consumed ON items(isConsumed)');
    await db.execute(
      'CREATE INDEX idx_notifications_user ON notifications(userId)',
    );
    await db.execute(
      'CREATE INDEX idx_notifications_timestamp ON notifications(timestamp)',
    );
    await db.execute(
      'CREATE INDEX idx_notifications_read ON notifications(isRead)',
    );
    await db.execute(
      'CREATE INDEX idx_history_timestamp ON history_events(timestamp)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE items ADD COLUMN notes TEXT');
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS shopping_lists(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          category TEXT,
          priority TEXT,
          itemIds TEXT NOT NULL,
          enableNotifications INTEGER NOT NULL DEFAULT 0,
          autoAddToCalendar INTEGER NOT NULL DEFAULT 0,
          tags TEXT,
          createdAt INTEGER NOT NULL,
          inStockCount INTEGER NOT NULL DEFAULT 0,
          runOutCount INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('ALTER TABLE items ADD COLUMN price REAL');
    }

    if (oldVersion < 5) {
      await db.execute(
        'ALTER TABLE items ADD COLUMN isConsumed INTEGER DEFAULT 0',
      );
      await db.execute(
        'UPDATE items SET isConsumed = 0 WHERE isConsumed IS NULL',
      );

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_items_category ON items(category)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_items_expiry ON items(expiryDate)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_items_favorite ON items(isFavorite)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_items_consumed ON items(isConsumed)',
      );
    }

    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notifications(
          id TEXT PRIMARY KEY,
          userId TEXT NOT NULL,
          title TEXT NOT NULL,
          message TEXT NOT NULL,
          type TEXT NOT NULL,
          timestamp INTEGER NOT NULL,
          isRead INTEGER NOT NULL DEFAULT 0
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(userId)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_notifications_timestamp ON notifications(timestamp)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(isRead)',
      );
    }

    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS history_events(
          id TEXT PRIMARY KEY,
          type TEXT NOT NULL,
          title TEXT NOT NULL,
          subtitle TEXT,
          timestamp INTEGER NOT NULL,
          itemId TEXT,
          listId TEXT
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_history_timestamp ON history_events(timestamp)',
      );
    }
  }

  // close the database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
