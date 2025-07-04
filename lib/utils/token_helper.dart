import 'package:shared_preferences/shared_preferences.dart';

const String _tokenKey = 'token';
const String _expiryKey = 'token_expiry';

Future<void> saveToken(String token, Duration duration) async {
  final prefs = await SharedPreferences.getInstance();
  final expiryTime = DateTime.now().add(duration).millisecondsSinceEpoch;

  await prefs.setString(_tokenKey, token);
  await prefs.setInt(_expiryKey, expiryTime);
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  final expiry = prefs.getInt(_expiryKey);
  final now = DateTime.now().millisecondsSinceEpoch;

  if (expiry != null && now > expiry) {
    // Token expired
    await removeToken();
    return null;
  }

  return prefs.getString(_tokenKey);
}

Future<void> removeToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_tokenKey);
  await prefs.remove(_expiryKey);
}
