import 'package:flutter/foundation.dart';
import 'package:kioske/data/database_helper.dart';
import 'package:kioske/models/activity.dart';
import 'package:kioske/repositories/activity_repository.dart';

class ActivityProvider with ChangeNotifier {
  final ActivityRepository _repository = ActivityRepository();

  List<Activity> _activities = [];
  bool _isLoading = false;
  int _totalCount = 0;
  int _currentPage = 1;
  final int _pageSize = 15;

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  int get totalCount => _totalCount;
  int get currentPage => _currentPage;
  int get totalPages => (_totalCount / _pageSize).ceil();

  /// Load activities with pagination
  Future<void> loadActivities({int page = 1}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final offset = (page - 1) * _pageSize;
      final newActivities = await _repository.getAll(
        limit: _pageSize,
        offset: offset,
      );
      _totalCount = await _repository.getCount();

      _activities = newActivities;
      _currentPage = page;
    } catch (e) {
      debugPrint('Error loading activities: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Log a new activity
  Future<void> logActivity({
    required String userId,
    String? userName,
    required String action, // e.g., 'create', 'update', 'delete', 'login'
    required String entityType, // e.g., 'product', 'customer'
    String? entityId,
    String? description,
    String? metadata,
  }) async {
    try {
      final activity = Activity(
        id: DatabaseHelper.generateId(),
        userId: userId,
        userName: userName,
        action: action,
        entityType: entityType,
        entityId: entityId,
        description: description,
        metadata: metadata,
        createdAt: DateTime.now(),
      );

      await _repository.create(activity);

      // Refresh list if currently viewing page 1
      if (_currentPage == 1) {
        await loadActivities(page: 1);
      } else {
        // Just update count
        _totalCount++;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error logging activity: $e');
    }
  }
}
