import 'package:flutter/material.dart';
import 'package:kioske/models/employee.dart';
import 'package:kioske/repositories/employee_repository.dart';

import 'package:kioske/repositories/user_repository.dart';
import 'package:kioske/repositories/activity_repository.dart';
import 'package:kioske/repositories/expense_repository.dart';
import 'package:kioske/models/activity.dart';
import 'package:kioske/data/database_helper.dart';

class EmployeeProvider with ChangeNotifier {
  final EmployeeRepository _repository = EmployeeRepository();

  final UserRepository _userRepository = UserRepository();
  final ActivityRepository _activityRepository = ActivityRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  List<Employee> _employees = [];
  bool _isLoading = false;
  String? _error;

  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all employees
  Future<void> loadEmployees() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _employees = await _repository.getAll();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading employees: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new employee
  Future<void> addEmployee({
    required String name,
    required String role,
    String? phone,
    String? email,
    double salary = 0.0,
    required DateTime hireDate,

    String? userId,
    String? username,

    String? password,
    required String currentUserId,
    String? currentUserName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? newUserId = userId;

      // Create User if username and password are provided
      if (username != null &&
          password != null &&
          username.isNotEmpty &&
          password.isNotEmpty) {
        // Map role: Cashier -> cashier, Others -> admin
        String userRole = role == 'Cashier' ? 'cashier' : 'admin';

        // Check if username already exists
        if (await _userRepository.usernameExists(username)) {
          throw Exception('Username already exists');
        }

        final newUser = await _userRepository.create(
          username: username,
          password: password,
          role: userRole,
          name: name,
        );
        newUserId = newUser.id;
      }

      final newEmployee = await _repository.create(
        name: name,
        role: role,
        phone: phone,
        email: email,
        salary: salary,
        hireDate: hireDate,
        userId: newUserId,
      );
      _employees.add(newEmployee);
      // Re-sort locally or reload? Reload is safer for order.
      _employees.sort((a, b) => a.name.compareTo(b.name));

      // Create salary expense if salary > 0
      if (salary > 0) {
        await _expenseRepository.create(
          title: 'Salary - $name',
          description: 'Monthly salary for $name',
          amount: salary,
          category: 'salaries',
          createdBy: currentUserId,
          expenseDate: DateTime.now(),
          isRecurring: true,
          recurrenceInterval: 'monthly',
        );
      }

      // Log activity
      await _activityRepository.create(
        Activity(
          id: DatabaseHelper.generateId(),
          userId: currentUserId,
          userName: currentUserName,
          action: 'create',
          entityType: 'employee',
          entityId: newEmployee.id,
          description: 'Employee created: ${newEmployee.name}',
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding employee: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing employee
  Future<void> updateEmployee(
    Employee employee, {
    String? newPassword,
    required String currentUserId,
    String? currentUserName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.update(employee);

      // Also update linked user username if it exists
      if (employee.userId != null) {
        // Update username if phone is provided (assuming phone is used as username)
        if (employee.phone != null) {
          await _userRepository.updateUsername(
            employee.userId!,
            employee.phone!,
          );
        }
        // Update password if newPassword is provided
        if (newPassword != null && newPassword.isNotEmpty) {
          await _userRepository.updatePassword(employee.userId!, newPassword);
        }
      }

      final index = _employees.indexWhere((e) => e.id == employee.id);
      if (index != -1) {
        _employees[index] = employee;
      }

      // Log activity
      await _activityRepository.create(
        Activity(
          id: DatabaseHelper.generateId(),
          userId: currentUserId,
          userName: currentUserName,
          action: 'update',
          entityType: 'employee',
          entityId: employee.id,
          description: 'Employee updated: ${employee.name}',
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating employee: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete an employee
  Future<void> deleteEmployee(
    String id, {
    required String currentUserId,
    String? currentUserName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.delete(id);

      _employees.removeWhere((e) => e.id == id);

      // Log activity
      await _activityRepository.create(
        Activity(
          id: DatabaseHelper.generateId(),
          userId: currentUserId,
          userName: currentUserName,
          action: 'delete',
          entityType: 'employee',
          entityId: id,
          description: 'Employee deleted',
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting employee: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
