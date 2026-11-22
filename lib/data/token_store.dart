
import 'package:shared_preferences/shared_preferences.dart';

class TokenStore {
  static const String _key = 'auth_token';

  // Получение сохранённого JWT
  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  // Сохранение JWT после входа
  Future<void> save(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  // Удаление JWT при выходе или ошибке 401
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
