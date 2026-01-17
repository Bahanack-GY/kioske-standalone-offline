import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:kioske/data/database_helper.dart';
import 'package:kioske/models/user.dart';

/// Repository for User data operations
class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Get all users
  Future<List<User>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('users', orderBy: 'created_at DESC');
    return maps.map((map) => User.fromMap(map)).toList();
  }

  /// Get users by role
  Future<List<User>> getByRole(String role) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: [role],
      orderBy: 'name ASC',
    );
    return maps.map((map) => User.fromMap(map)).toList();
  }

  /// Get user by ID
  Future<User?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  /// Get user by username
  Future<User?> getByUsername(String username) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  /// Authenticate user by username and password
  Future<User?> authenticate(String username, String password) async {
    final user = await getByUsername(username);
    if (user == null) return null;
    if (!user.isActive) return null;
    if (!DatabaseHelper.verifyPassword(password, user.passwordHash)) {
      return null;
    }
    return user;
  }

  /// Create a new user
  Future<User> create({
    required String username,
    required String password,
    required String role,
    required String name,
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final user = User(
      id: DatabaseHelper.generateId(),
      username: username,
      passwordHash: _hashPassword(password),
      role: role,
      name: name,
      isActive: true,
      createdAt: now,
    );
    await db.insert('users', user.toMap());
    return user;
  }

  /// Update an existing user
  Future<void> update(User user) async {
    final db = await _dbHelper.database;
    final updatedUser = user.copyWith(updatedAt: DateTime.now());
    await db.update(
      'users',
      updatedUser.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  /// Update user password
  Future<void> updatePassword(String userId, String newPassword) async {
    final db = await _dbHelper.database;
    await db.update(
      'users',
      {
        'password_hash': _hashPassword(newPassword),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Deactivate user (soft delete)
  Future<void> deactivate(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'users',
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete user permanently
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  /// Check if username exists
  Future<bool> usernameExists(String username) async {
    final user = await getByUsername(username);
    return user != null;
  }

  /// Update user username
  Future<void> updateUsername(String userId, String newUsername) async {
    final db = await _dbHelper.database;
    await db.update(
      'users',
      {'username': newUsername, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
