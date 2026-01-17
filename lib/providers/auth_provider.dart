import 'package:flutter/foundation.dart';
import 'package:kioske/data/database_helper.dart';
import 'package:kioske/models/user.dart';
import 'package:kioske/repositories/user_repository.dart';
import 'package:kioske/repositories/activity_repository.dart';
import 'package:kioske/models/activity.dart';

/// Authentication provider for managing user sessions
class AuthProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final ActivityRepository _activityRepository = ActivityRepository();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isCashier => _currentUser?.role == 'cashier';
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  /// Initialize auth provider (check for stored session)
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize database
    await DatabaseHelper.instance.database;
    _isInitialized = true;
    notifyListeners();
  }

  /// Login with username and password
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _userRepository.authenticate(username, password);

      if (user != null) {
        _currentUser = user;
        _isLoading = false;

        // Log login activity
        await _activityRepository.create(
          Activity(
            id: DatabaseHelper.generateId(),
            userId: user.id,
            userName: user.name,
            action: 'connection',
            entityType: 'auth',
            description: 'Login successful',
            createdAt: DateTime.now(),
          ),
        );

        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid username or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout current user
  void logout() {
    if (_currentUser != null) {
      // Log logout activity (fire and forget)
      _activityRepository.create(
        Activity(
          id: DatabaseHelper.generateId(),
          userId: _currentUser!.id,
          userName: _currentUser!.name,
          action: 'logout',
          entityType: 'auth',
          description: 'User logged out',
          createdAt: DateTime.now(),
        ),
      );
    }
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get all users (admin only)
  Future<List<User>> getAllUsers() async {
    if (!isAdmin) return [];
    return _userRepository.getAll();
  }

  /// Create new user (admin only)
  Future<User?> createUser({
    required String username,
    required String password,
    required String role,
    required String name,
  }) async {
    if (!isAdmin) return null;

    try {
      // Check if username exists
      if (await _userRepository.usernameExists(username)) {
        _errorMessage = 'Username already exists';
        notifyListeners();
        return null;
      }

      final user = await _userRepository.create(
        username: username,
        password: password,
        role: role,
        name: name,
      );
      return user;
    } catch (e) {
      _errorMessage = 'Failed to create user: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// Update user password
  Future<bool> updatePassword(String newPassword) async {
    if (_currentUser == null) return false;

    try {
      await _userRepository.updatePassword(_currentUser!.id, newPassword);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update password: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Deactivate user (admin only)
  Future<bool> deactivateUser(String userId) async {
    if (!isAdmin) return false;

    try {
      await _userRepository.deactivate(userId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to deactivate user: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}
