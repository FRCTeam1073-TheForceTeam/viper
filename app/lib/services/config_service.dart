import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const String _backendUrlKey = 'backend_url';
  static const String _selectedEventKey = 'selected_event';
  static const String _scouterNameKey = 'scouter_name';
  static const String _lastEventChangeDateKey = 'last_event_change_date';

  final SharedPreferences _prefs;

  ConfigService(this._prefs);

  /// Get the backend URL (default: http://localhost)
  String getBackendUrl() {
    return _prefs.getString(_backendUrlKey) ?? 'http://localhost';
  }

  /// Save backend URL
  Future<void> setBackendUrl(String url) async {
    await _prefs.setString(_backendUrlKey, url);
  }

  /// Get selected event ID
  String? getSelectedEvent() {
    return _prefs.getString(_selectedEventKey);
  }

  /// Save selected event ID
  Future<void> setSelectedEvent(String eventId) async {
    await _prefs.setString(_selectedEventKey, eventId);
    await _prefs.setString(
      _lastEventChangeDateKey,
      DateTime.now().toIso8601String(),
    );
  }

  /// Get scouter name
  String? getScouterName() {
    return _prefs.getString(_scouterNameKey);
  }

  /// Save scouter name
  Future<void> setScouterName(String name) async {
    await _prefs.setString(_scouterNameKey, name);
  }

  /// Check if event selection date has changed
  /// Returns true if date has changed or no previous date set
  bool hasEventSelectionDateChanged() {
    final lastDateStr = _prefs.getString(_lastEventChangeDateKey);
    if (lastDateStr == null) return true;

    try {
      final lastDate = DateTime.parse(lastDateStr);
      final today = DateTime.now();

      return lastDate.year != today.year ||
          lastDate.month != today.month ||
          lastDate.day != today.day;
    } catch (e) {
      return true;
    }
  }

  /// Clear all app data (useful for testing or reset)
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
