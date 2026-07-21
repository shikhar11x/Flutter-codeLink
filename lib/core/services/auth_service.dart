import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';

class AuthService {
  AuthService._();

  static String? _token;
  static Map<String, dynamic>? _user;

  static bool get isLoggedIn => _token != null;
  static String? get token => _token;
  static Map<String, dynamic>? get user => _user;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('auth_token');
    if (savedToken != null) {
      _token = savedToken;
      ApiClient.setToken(savedToken);
    }
  }

  static Future<String?> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        '/api/auth/signup',
        data: {'name': name, 'email': email, 'password': password},
      );
      await _saveSession(response.data);
      return null;
    } catch (e) {
      return _extractError(e);
    }
  }

  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      await _saveSession(response.data);
      return null;
    } catch (e) {
      return _extractError(e);
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
    _user = null;
    ApiClient.clearToken();
  }

  static Future<void> _saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    _token = data['token'];
    _user = data['user'];
    await prefs.setString('auth_token', _token!);
    ApiClient.setToken(_token!);
  }

  static String _extractError(dynamic e) {
    try {
      return e.response?.data?['error'] ?? 'Something went wrong';
    } catch (_) {
      return 'Connection failed';
    }
  }
}