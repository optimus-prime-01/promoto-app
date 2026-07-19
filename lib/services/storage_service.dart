import 'package:shared_preferences/shared_preferences.dart';

// TODO(security): Migrate token storage from SharedPreferences to
// flutter_secure_storage. SharedPreferences stores data in plain text
// which is accessible on rooted/jailbroken devices. JWT tokens are
// sensitive credentials and should use encrypted storage.
// The flutter_secure_storage package is already in pubspec.yaml.
class StorageService {
  static const _tokenKey = 'jwt_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
