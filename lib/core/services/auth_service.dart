import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  // Register new user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String shopName,
    String? phone,
  }) async {
    final data = {
      'email': email,
      'password': password,
      'name': name,
      'shopName': shopName,
      'phone': phone,
    };

    final response = await ApiService.post('/auth/register', data);

    // Save token and user data
    if (response['token'] != null) {
      await _saveAuthData(response);
    }

    return response;
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = {'email': email, 'password': password};

    final response = await ApiService.post('/auth/login', data);

    // Save token and user data
    if (response['token'] != null) {
      await _saveAuthData(response);
    }

    return response;
  }

  // Refresh token
  static Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await ApiService.post('/auth/refresh-token', refreshToken);

    // Update token
    if (response['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response['token']);
      await prefs.setString('refreshToken', response['refreshToken']);
    }

    return response;
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      try {
        await ApiService.post('/auth/revoke-token', userId);
      } catch (e) {
        // Continue with logout even if API call fails
      }
    }

    // Clear local storage
    await prefs.remove('token');
    await prefs.remove('refreshToken');
    await prefs.remove('userId');
    await prefs.remove('userEmail');
    await prefs.remove('userName');
    await prefs.remove('shopName');
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null;
  }

  // Get current user data
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return null;

    return {
      'id': prefs.getString('userId'),
      'email': prefs.getString('userEmail'),
      'name': prefs.getString('userName'),
      'shopName': prefs.getString('shopName'),
      'phone': prefs.getString('userPhone'),
    };
  }

  // Save authentication data to shared preferences
  static Future<void> _saveAuthData(Map<String, dynamic> response) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', response['token']);
    await prefs.setString('refreshToken', response['refreshToken']);
    await prefs.setString('userId', response['id']);
    await prefs.setString('userEmail', response['email']);
    await prefs.setString('userName', response['name']);
    await prefs.setString('shopName', response['shopName']);
    if (response['phone'] != null) {
      await prefs.setString('userPhone', response['phone']);
    }
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
