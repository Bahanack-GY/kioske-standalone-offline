import 'dart:convert';
import 'dart:io' show Platform;
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

/// Singleton database helper for SQLite operations
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static const _databaseName = "kioske.db";
  static const _databaseVersion = 6;
  static const _uuid = Uuid();
  static bool _ffiInitialized = false;

  DatabaseHelper._init();

  /// Initialize FFI for desktop platforms (Linux, Windows, macOS)
  static void _initFfi() {
    if (_ffiInitialized) return;

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _ffiInitialized = true;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _initFfi();
    _database = await _initDB(_databaseName);
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL,
        name TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT,
        sort_order INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // Products table
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category_id TEXT NOT NULL,
        purchase_price REAL NOT NULL,
        sale_price REAL NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0,
        image_url TEXT,
        rating REAL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'available',
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Customers table
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        total_purchases REAL DEFAULT 0,
        order_count INTEGER DEFAULT 0,
        status TEXT DEFAULT 'new',
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Employees table
    await db.execute('''
      CREATE TABLE employees (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        salary REAL DEFAULT 0,
        status TEXT DEFAULT 'active',
        hire_date TEXT NOT NULL,
        user_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        customer_id TEXT,
        cashier_id TEXT NOT NULL,
        items TEXT NOT NULL,
        subtotal REAL NOT NULL,
        discount REAL DEFAULT 0,
        total REAL NOT NULL,
        type TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        notes TEXT,
        payment_method TEXT DEFAULT 'cash',
        created_at TEXT NOT NULL,
        completed_at TEXT,
        FOREIGN KEY (customer_id) REFERENCES customers (id),
        FOREIGN KEY (cashier_id) REFERENCES users (id)
      )
    ''');

    // Expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        receipt TEXT,
        status TEXT DEFAULT 'pending',
        created_by TEXT NOT NULL,
        approved_by TEXT,
        expense_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        is_recurring INTEGER DEFAULT 0,
        recurrence_interval TEXT,
        FOREIGN KEY (created_by) REFERENCES users (id),
        FOREIGN KEY (approved_by) REFERENCES users (id)
      )
    ''');

    // Suppliers table
    await db.execute('''
      CREATE TABLE suppliers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        contact_person TEXT,
        total_orders REAL DEFAULT 0,
        order_count INTEGER DEFAULT 0,
        status TEXT DEFAULT 'active',
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Deliveries table
    await db.execute('''
      CREATE TABLE deliveries (
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        customer_id TEXT,
        driver_name TEXT,
        driver_phone TEXT,
        address TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        delivery_fee REAL DEFAULT 0,
        notes TEXT,
        estimated_delivery TEXT,
        delivered_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (order_id) REFERENCES orders (id),
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      )
    ''');

    // Promotions table
    await db.execute('''
      CREATE TABLE promotions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        value REAL NOT NULL,
        minimum_purchase REAL,
        product_id TEXT,
        category_id TEXT,
        is_active INTEGER DEFAULT 1,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (product_id) REFERENCES products (id),
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Activities table (audit log)
    await db.execute('''
      CREATE TABLE activities (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        user_name TEXT,
        action TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT,
        description TEXT,
        metadata TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Stock movements table
    await db.execute('''
      CREATE TABLE stock_movements (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        type TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        previous_stock INTEGER NOT NULL,
        new_stock INTEGER NOT NULL,
        supplier_id TEXT,
        order_id TEXT,
        reason TEXT,
        notes TEXT,
        created_by TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products (id),
        FOREIGN KEY (supplier_id) REFERENCES suppliers (id),
        FOREIGN KEY (order_id) REFERENCES orders (id),
        FOREIGN KEY (created_by) REFERENCES users (id)
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE settings (
        id TEXT PRIMARY KEY,
        key TEXT NOT NULL UNIQUE,
        value TEXT NOT NULL,
        description TEXT,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes for better query performance
    await db.execute(
      'CREATE INDEX idx_products_category ON products (category_id)',
    );
    await db.execute(
      'CREATE INDEX idx_orders_customer ON orders (customer_id)',
    );
    await db.execute('CREATE INDEX idx_orders_cashier ON orders (cashier_id)');
    await db.execute('CREATE INDEX idx_orders_created ON orders (created_at)');
    await db.execute(
      'CREATE INDEX idx_activities_user ON activities (user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_activities_created ON activities (created_at)',
    );
    await db.execute(
      'CREATE INDEX idx_stock_movements_product ON stock_movements (product_id)',
    );

    // Supply Deliveries table (Supplier Orders)
    await db.execute('''
      CREATE TABLE supply_deliveries (
        id TEXT PRIMARY KEY,
        supplier_id TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        expected_date TEXT NOT NULL,
        delivered_date TEXT,
        total_amount REAL NOT NULL,
        item_count INTEGER NOT NULL,
        proof_image TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (supplier_id) REFERENCES suppliers (id)
      )
    ''');

    // Supply Delivery Items table
    await db.execute('''
      CREATE TABLE supply_delivery_items (
        id TEXT PRIMARY KEY,
        delivery_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT, 
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        FOREIGN KEY (delivery_id) REFERENCES supply_deliveries (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_supply_deliveries_supplier ON supply_deliveries (supplier_id)',
    );
    await db.execute(
      'CREATE INDEX idx_supply_delivery_items_delivery ON supply_delivery_items (delivery_id)',
    );

    // Seed initial data
    await _seedInitialData(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add supply deliveries tables for version 2
      await db.execute('''
        CREATE TABLE supply_deliveries (
          id TEXT PRIMARY KEY,
          supplier_id TEXT NOT NULL,
          status TEXT DEFAULT 'pending',
          expected_date TEXT NOT NULL,
          delivered_date TEXT,
          total_amount REAL NOT NULL,
          item_count INTEGER NOT NULL,
          proof_image TEXT,
          notes TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          FOREIGN KEY (supplier_id) REFERENCES suppliers (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE supply_delivery_items (
          id TEXT PRIMARY KEY,
          delivery_id TEXT NOT NULL,
          product_id TEXT NOT NULL,
          product_name TEXT, 
          quantity INTEGER NOT NULL,
          unit_price REAL NOT NULL,
          total_price REAL NOT NULL,
          FOREIGN KEY (delivery_id) REFERENCES supply_deliveries (id),
          FOREIGN KEY (product_id) REFERENCES products (id)
        )
      ''');

      await db.execute(
        'CREATE INDEX idx_supply_deliveries_supplier ON supply_deliveries (supplier_id)',
      );
      await db.execute(
        'CREATE INDEX idx_supply_delivery_items_delivery ON supply_delivery_items (delivery_id)',
      );
    }

    if (oldVersion < 3) {
      // Version 3: Ensure default categories exist
      final now = DateTime.now().toIso8601String();
      final categories = [
        {'name': 'Biere', 'icon': 'sports_bar', 'sort_order': 1},
        {'name': 'Biere details', 'icon': 'sports_bar', 'sort_order': 2},
        {'name': 'Eau', 'icon': 'water_drop', 'sort_order': 3},
        {'name': 'Eau details', 'icon': 'water_drop', 'sort_order': 4},
        {'name': 'Jus', 'icon': 'local_drink', 'sort_order': 5},
        {'name': 'Jus details', 'icon': 'local_drink', 'sort_order': 6},
      ];

      for (final cat in categories) {
        // Check if exists
        final existing = await db.query(
          'categories',
          where: 'name = ?',
          whereArgs: [cat['name']],
        );

        if (existing.isEmpty) {
          await db.insert('categories', {
            'id': _uuid.v4(),
            'name': cat['name'],
            'icon': cat['icon'],
            'sort_order': cat['sort_order'],
            'is_active': 1,
            'created_at': now,
          });
        }
      }
    }

    if (oldVersion < 4) {
      // Version 4: Add recurrence fields to expenses
      try {
        await db.execute(
          'ALTER TABLE expenses ADD COLUMN is_recurring INTEGER DEFAULT 0',
        );
        await db.execute(
          'ALTER TABLE expenses ADD COLUMN recurrence_interval TEXT',
        );
      } catch (e) {
        // Ignore if columns already exist
        print('Error adding columns: $e');
      }
    }

    if (oldVersion < 5) {
      // Version 5: Add payment_method to orders
      try {
        await db.execute(
          'ALTER TABLE orders ADD COLUMN payment_method TEXT DEFAULT "cash"',
        );
      } catch (e) {
        print('Error adding payment_method: $e');
      }
    }

    if (oldVersion < 6) {
      // Version 6: Remove default categories
      try {
        await db.execute(
          "DELETE FROM categories WHERE name IN ('Biere', 'Biere details', 'Eau', 'Eau details', 'Jus', 'Jus details')",
        );
      } catch (e) {
        print('Error removing default categories: $e');
      }
    }
  }

  Future<void> _seedInitialData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Seed default admin user
    final adminPasswordHash = _hashPassword('admin123');
    await db.insert('users', {
      'id': _uuid.v4(),
      'username': '699612708',
      'password_hash': adminPasswordHash,
      'role': 'admin',
      'name': 'Administrator',
      'is_active': 1,
      'created_at': now,
    });

    // Seed default cashier user
    final cashierPasswordHash = _hashPassword('cashier123');
    await db.insert('users', {
      'id': _uuid.v4(),
      'username': '694448665',
      'password_hash': cashierPasswordHash,
      'role': 'cashier',
      'name': 'Caissier',
      'is_active': 1,
      'created_at': now,
    });

    // Seed default categories
    final categories = [];

    for (final cat in categories) {
      await db.insert('categories', {
        'id': _uuid.v4(),
        'name': cat['name'],
        'icon': cat['icon'],
        'sort_order': cat['sort_order'],
        'is_active': 1,
        'created_at': now,
      });
    }

    // Seed default settings
    final settings = [
      {
        'key': 'business_name',
        'value': 'La cave de simbock',
        'description': 'Business name',
      },
      {'key': 'currency', 'value': 'XAF', 'description': 'Currency code'},
      {
        'key': 'currency_symbol',
        'value': 'FCFA',
        'description': 'Currency symbol',
      },
      {'key': 'tax_rate', 'value': '0', 'description': 'Tax rate percentage'},
      {
        'key': 'enable_tax',
        'value': 'false',
        'description': 'Enable tax calculation',
      },
      {
        'key': 'enable_delivery',
        'value': 'true',
        'description': 'Enable delivery orders',
      },
      {
        'key': 'default_delivery_fee',
        'value': '500',
        'description': 'Default delivery fee',
      },
    ];

    for (final setting in settings) {
      await db.insert('settings', {
        'id': setting['key'],
        'key': setting['key'],
        'value': setting['value'],
        'description': setting['description'],
        'updated_at': now,
      });
    }
  }

  /// Hash password using SHA-256
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify password against hash
  static bool verifyPassword(String password, String hash) {
    return _hashPassword(password) == hash;
  }

  /// Generate a new UUID
  static String generateId() => _uuid.v4();

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Reset the database (for testing/development)
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'kioske.db');
    await deleteDatabase(path);
    _database = null;
  }
}
