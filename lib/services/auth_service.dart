import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _usernameKey = 'account_username';
  static const _passwordKey = 'account_password';
  static const _sessionKey = 'is_logged_in';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sessionKey) ?? false;
  }

  static Future<void> register({
    required String username,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username.trim());
    await prefs.setString(_passwordKey, password);
    await prefs.setBool(_sessionKey, true);
  }

  static Future<bool> login({
    required String username,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString(_usernameKey);
    final savedPassword = prefs.getString(_passwordKey);
    final isValid =
        savedUsername == username.trim() && savedPassword == password;

    if (isValid) {
      await prefs.setBool(_sessionKey, true);
    }

    return isValid;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
