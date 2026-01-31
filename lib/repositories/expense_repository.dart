import 'package:kioske/data/database_helper.dart';
import 'package:kioske/models/expense.dart';

/// Repository for Expense data operations
class ExpenseRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Get all expenses
  Future<List<Expense>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('expenses', orderBy: 'expense_date DESC');
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  /// Get expenses by category
  Future<List<Expense>> getByCategory(String category) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'expenses',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'expense_date DESC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  /// Get expenses by status
  Future<List<Expense>> getByStatus(String status) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'expenses',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'expense_date DESC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  /// Get expenses by date range
  Future<List<Expense>> getByDateRange(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'expenses',
      where: 'expense_date >= ? AND expense_date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'expense_date DESC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  /// Get expense by ID
  Future<Expense?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Expense.fromMap(maps.first);
  }

  /// Create a new expense
  Future<Expense> create({
    required String title,
    String? description,
    required double amount,
    required String category,
    String? receipt,
    required String createdBy,
    required DateTime expenseDate,
    bool isRecurring = false,
    String? recurrenceInterval,
  }) async {
    final db = await _dbHelper.database;
    final expense = Expense(
      id: DatabaseHelper.generateId(),
      title: title,
      description: description,
      amount: amount,
      category: category,
      receipt: receipt,
      createdBy: createdBy,
      expenseDate: expenseDate,
      createdAt: DateTime.now(),
      isRecurring: isRecurring,
      recurrenceInterval: recurrenceInterval,
    );
    await db.insert('expenses', expense.toMap());
    return expense;
  }

  /// Update an existing expense
  Future<void> update(Expense expense) async {
    final db = await _dbHelper.database;
    final updatedExpense = expense.copyWith(updatedAt: DateTime.now());
    await db.update(
      'expenses',
      updatedExpense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  /// Approve expense
  Future<void> approve(String expenseId, String approvedBy) async {
    final db = await _dbHelper.database;
    await db.update(
      'expenses',
      {
        'status': 'approved',
        'approved_by': approvedBy,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [expenseId],
    );
  }

  /// Reject expense
  Future<void> reject(String expenseId) async {
    final db = await _dbHelper.database;
    await db.update(
      'expenses',
      {'status': 'rejected', 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [expenseId],
    );
  }

  /// Delete expense permanently
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  /// Get total expenses for a date range
  Future<double> getTotalExpenses(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) as total 
      FROM expenses 
      WHERE status = 'approved' 
        AND expense_date >= ? 
        AND expense_date <= ?
    ''',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get expenses grouped by category
  Future<Map<String, double>> getExpensesByCategory(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT category, SUM(amount) as total 
      FROM expenses 
      WHERE status = 'approved' 
        AND expense_date >= ? 
        AND expense_date <= ?
      GROUP BY category
    ''',
      [start.toIso8601String(), end.toIso8601String()],
    );

    final categoryTotals = <String, double>{};
    for (final row in result) {
      categoryTotals[row['category'] as String] = (row['total'] as num)
          .toDouble();
    }
    return categoryTotals;
  }
}
