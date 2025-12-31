import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _usernameKey = 'auth_username';
  static const String _passwordKey = 'auth_password';
  static const String _isLoggedInKey = 'is_logged_in';

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Save credentials
  static Future<void> saveCredentials(String username, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usernameKey, username);
      await prefs.setString(_passwordKey, password);
      await prefs.setBool(_isLoggedInKey, true);
    } catch (e) {
      throw Exception('Failed to save credentials: $e');
    }
  }

  /// Get saved credentials
  static Future<Map<String, String>?> getCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString(_usernameKey);
      final password = prefs.getString(_passwordKey);

      if (username != null && password != null) {
        return {'username': username, 'password': password};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Clear credentials (logout)
  static Future<void> clearCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_usernameKey);
      await prefs.remove(_passwordKey);
      await prefs.setBool(_isLoggedInKey, false);
    } catch (e) {
      throw Exception('Failed to clear credentials: $e');
    }
  }

  /// Get username only
  static Future<String?> getUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_usernameKey);
    } catch (e) {
      return null;
    }
  }
}
