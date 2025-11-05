import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  // Singleton pattern for database instance.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database with the required schema.
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'restaurantpack.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate, // Calls schema creation on first open.
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create table: users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        phone TEXT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');

    // Create table: orders
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        total_amount REAL,
        status TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    '''); // Custom implementation but indirectly aligns with booking logic.

    // Create table: order_items
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER,
        item_name TEXT,
        quantity INTEGER,
        price REAL,
        FOREIGN KEY (order_id) REFERENCES orders (id)
      )
    '''); // Handles menu booking details
  }

  // User CRUD operations.
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user,
        conflictAlgorithm: ConflictAlgorithm.replace); // Handles new user registration and updates.
  }

  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    final db = await database;
    return await db.query('users'); // Required for administrator view.
  }

  Future<Map<String, dynamic>?> fetchUserByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? result.first : null; // Used for login validation.
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [user['id']],
    ); // Allows users to edit their profile.
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    ); // Facilitates admin user removal.
  }

  // Order CRUD operations.
  Future<int> insertOrder(Map<String, dynamic> order) async {
    final db = await database;
    return await db.insert('orders', order); // Booking insertion.
  }

  Future<int> insertOrderItem(Map<String, dynamic> orderItem) async {
    final db = await database;
    return await db.insert('order_items', orderItem); // Adding menu details to an order.
  }

  Future<List<Map<String, dynamic>>> fetchAllOrders() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        orders.id,
        orders.total_amount,
        orders.status,
        orders.created_at,
        users.name AS user_name
      FROM orders
      LEFT JOIN users ON orders.user_id = users.id
      ORDER BY orders.created_at DESC
    '''); // Matches the admin view requirement for user orders.
  }

  Future<List<Map<String, dynamic>>> fetchOrderItems(int orderId) async {
    final db = await database;
    return await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    ); // Displays items in a specific booking.
  }

  Future<int> updateOrderStatus(int orderId, String status) async {
    final db = await database;
    return await db.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [orderId],
    ); // Admin update capability for bookings.
  }

  // Statistics Operations
  Future<int> getTotalUsers() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return Sqflite.firstIntValue(result) ?? 0; // Count of registered users.
  }

  Future<int> getActiveOrders() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM orders WHERE status != ?',
        ['completed']
    );
    return Sqflite.firstIntValue(result) ?? 0; // Tracks incomplete bookings.
  }

  Future<double> getTodayRevenue() async {
    final db = await database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final result = await db.rawQuery(
        'SELECT SUM(total_amount) as total FROM orders WHERE date(created_at) = date(?)',
        [startOfDay.toIso8601String()]
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0; // Daily revenue report.
  }

  Future<int> getTodayOrders() async {
    final db = await database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM orders WHERE date(created_at) = date(?)',
        [startOfDay.toIso8601String()]
    );
    return Sqflite.firstIntValue(result) ?? 0; // Count of today's bookings.
  }

  // Reset Database (for testing)
  Future<int> deleteAllUsers() async {
    final db = await database;
    return await db.delete('users'); // Testing and reset functionality.
  }
}
