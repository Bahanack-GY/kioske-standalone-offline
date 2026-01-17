import 'package:sqflite/sqflite.dart';
import 'package:kioske/data/database_helper.dart';
import 'package:kioske/models/employee.dart';

/// Repository for Employee data operations
class EmployeeRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Get all employees
  Future<List<Employee>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('employees', orderBy: 'name ASC');
    return maps.map((map) => Employee.fromMap(map)).toList();
  }

  /// Get employees by role
  Future<List<Employee>> getByRole(String role) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'employees',
      where: 'role = ?',
      whereArgs: [role],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Employee.fromMap(map)).toList();
  }

  /// Get employees by status
  Future<List<Employee>> getByStatus(String status) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'employees',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Employee.fromMap(map)).toList();
  }

  /// Get employee by ID
  Future<Employee?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Employee.fromMap(maps.first);
  }

  /// Get employee by user ID
  Future<Employee?> getByUserId(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'employees',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Employee.fromMap(maps.first);
  }

  /// Create a new employee
  Future<Employee> create({
    required String name,
    required String role,
    String? phone,
    String? email,
    double salary = 0.0,
    required DateTime hireDate,
    String? userId,
  }) async {
    final db = await _dbHelper.database;
    final employee = Employee(
      id: DatabaseHelper.generateId(),
      name: name,
      role: role,
      phone: phone,
      email: email,
      salary: salary,
      hireDate: hireDate,
      userId: userId,
      createdAt: DateTime.now(),
    );
    await db.insert('employees', employee.toMap());
    return employee;
  }

  /// Update an existing employee
  Future<void> update(Employee employee) async {
    final db = await _dbHelper.database;
    final updatedEmployee = employee.copyWith(updatedAt: DateTime.now());
    await db.update(
      'employees',
      updatedEmployee.toMap(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  /// Update employee status
  Future<void> updateStatus(String employeeId, String status) async {
    final db = await _dbHelper.database;
    await db.update(
      'employees',
      {'status': status, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [employeeId],
    );
  }

  /// Delete employee permanently
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('employees', where: 'id = ?', whereArgs: [id]);
  }

  /// Get employee count
  Future<int> getCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM employees WHERE status = ?',
      ['active'],
    );
    return result.first['count'] as int;
  }

  /// Get total salary expense
  Future<double> getTotalSalaryExpense() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT SUM(salary) as total FROM employees WHERE status = 'active'",
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
