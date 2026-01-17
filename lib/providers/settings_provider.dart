import 'package:flutter/material.dart';
import 'package:kioske/models/settings.dart';
import 'package:kioske/repositories/settings_repository.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsRepository _repository = SettingsRepository();

  BusinessSettings _settings = BusinessSettings(businessName: 'Kioske');
  bool _isLoading = false;
  String? _error;

  BusinessSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SettingsProvider() {
    loadSettings();
  }

  /// Load all settings
  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await _repository.getBusinessSettings();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update settings
  Future<void> updateSettings(BusinessSettings newSettings) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final settingsList = newSettings.toSettingsList();
      await _repository.saveAll(settingsList);
      _settings = newSettings;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating settings: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
