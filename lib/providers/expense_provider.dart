import 'package:flutter/foundation.dart';
import 'package:kioske/models/expense.dart';
import 'package:kioske/repositories/expense_repository.dart';
import 'package:kioske/repositories/activity_repository.dart';
import 'package:kioske/models/activity.dart';
import 'package:kioske/data/database_helper.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseRepository _repository = ExpenseRepository();
  final ActivityRepository _activityRepository = ActivityRepository();

  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter states
  String _searchQuery = "";
  String _selectedStatus = "Toutes";
  String _selectedCategory = "Toutes";

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Computed property for filtered expenses
  List<Expense> get filteredExpenses {
    return _expenses.where((expense) {
      // Search filter
      final matchesSearch =
          expense.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (expense.description?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false);

      if (!matchesSearch) return false;

      // Status filter
      if (_selectedStatus == "Payées" && expense.status != 'approved')
        return false; // Assuming 'approved' mapping
      if (_selectedStatus == "En attente" && expense.status != 'pending')
        return false;
      if (_selectedStatus == "En retard" && expense.status != 'overdue')
        return false; // Assuming 'overdue' status exists or mapping

      // Category filter
      if (_selectedCategory != "Toutes" &&
          expense.category != _selectedCategory)
        return false;

      return true;
    }).toList();
  }

  // Actions
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadExpenses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _expenses = await _repository.getAll();
    } catch (e) {
      _errorMessage = e.toString();
      _expenses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense({
    required String title,
    String? description,
    required double amount,
    required String category,
    String? receipt,
    required String createdBy,
    String? createdByName,
    required DateTime expenseDate,
  }) async {
    try {
      final newExpense = await _repository.create(
        title: title,
        description: description,
        amount: amount,
        category: category,
        receipt: receipt,
        createdBy: createdBy,
        expenseDate: expenseDate,
      );
      _expenses.insert(0, newExpense);

      // Log activity
      await _activityRepository.create(
        Activity(
          id: DatabaseHelper.generateId(),
          userId: createdBy,
          userName: createdByName,
          action: 'create',
          entityType: 'expense',
          entityId: newExpense.id,
          description:
              'Expense added: ${newExpense.title} (${newExpense.amount} FCFA)',
          createdAt: DateTime.now(),
        ),
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateExpense(
    Expense expense, {
    required String currentUserId,
    String? currentUserName,
  }) async {
    try {
      await _repository.update(expense);
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = expense.copyWith(updatedAt: DateTime.now());

        // Log activity
        await _activityRepository.create(
          Activity(
            id: DatabaseHelper.generateId(),
            userId: currentUserId,
            userName: currentUserName,
            action: 'update',
            entityType: 'expense',
            entityId: expense.id,
            description: 'Expense updated: ${expense.title}',
            createdAt: DateTime.now(),
          ),
        );

        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteExpense(
    String id, {
    required String currentUserId,
    String? currentUserName,
  }) async {
    try {
      await _repository.delete(id);
      _expenses.removeWhere((e) => e.id == id);

      // Log activity
      await _activityRepository.create(
        Activity(
          id: DatabaseHelper.generateId(),
          userId: currentUserId,
          userName: currentUserName,
          action: 'delete',
          entityType: 'expense',
          entityId: id,
          description: 'Expense deleted',
          createdAt: DateTime.now(),
        ),
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
