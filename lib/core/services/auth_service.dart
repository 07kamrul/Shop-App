import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  // Cache SharedPreferences instance
  static SharedPreferences? _prefs;

  // Auth data keys
  static const _keyToken = 'token';
  static const _keyRefreshToken = 'refreshToken';
  static const _keyUserId = 'userId';
  static const _keyUserEmail = 'userEmail';
  static const _keyUserName = 'userName';
  static const _keyUserPhone = 'userPhone';
  // Multi-tenant keys
  static const _keyCompanyId = 'companyId';
  static const _keyCompanyName = 'companyName';
  static const _keyBranchId = 'branchId';
  static const _keyBranchName = 'branchName';
  static const _keyUserRole = 'userRole';
  static const _keyHasCompany = 'hasCompany';
  static const _keyHasBranch = 'hasBranch';
  static const _keyIsApproved = 'isApproved';

  static const _authKeys = [
    _keyToken,
    _keyRefreshToken,
    _keyUserId,
    _keyUserEmail,
    _keyUserName,
    _keyUserPhone,
    _keyCompanyId,
    _keyCompanyName,
    _keyBranchId,
    _keyBranchName,
    _keyUserRole,
    _keyHasCompany,
    _keyHasBranch,
    _keyIsApproved,
  ];

  /// Get or initialize SharedPreferences instance
  static Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  /// Register new user (creates company)
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String companyName,
    String? phone,
  }) async {
    try {
      final data = {
        'email': email,
        'password': password,
        'name': name,
        'companyName': companyName,
        if (phone != null) 'phone': phone,
      };

      final response = await ApiService.post('/auth/register', data);

      final token = response['token'];
      if (token != null && token is String && token.isNotEmpty) {
        await _saveAuthData(response);
        // Clear API headers cache to include new token
        ApiService.clearHeadersCache();
      }

      return response;
    } on ApiException catch (e) {
      throw Exception(_normalizeErrorMessage(e));
    } catch (e) {
      throw Exception(_cleanExceptionMessage(e.toString()));
    }
  }

  /// Simple register new user (with optional company)
  static Future<Map<String, dynamic>> simpleRegister({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? companyId,
  }) async {
    try {
      final data = {
        'email': email,
        'password': password,
        'name': name,
        if (phone != null) 'phone': phone,
        if (companyId != null && companyId.isNotEmpty) 'company_id': companyId,
      };

      final response = await ApiService.post('/auth/simple-register', data);
      return response;
    } on ApiException catch (e) {
      throw Exception(_normalizeErrorMessage(e));
    } catch (e) {
      throw Exception(_cleanExceptionMessage(e.toString()));
    }
  }

  /// Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = {'email': email, 'password': password};
      final response = await ApiService.post('/auth/login', data);

      final token = response['token'];
      if (token != null && token is String && token.isNotEmpty) {
        await _saveAuthData(response);
        ApiService.clearHeadersCache();
      }

      return response;
    } on ApiException catch (e) {
      throw Exception(_normalizeErrorMessage(e));
    } catch (e) {
      throw Exception('Login failed: ${_cleanExceptionMessage(e.toString())}');
    }
  }

  /// Refresh authentication token
  static Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await ApiService.post('/auth/refresh-token', {
        'refreshToken': refreshToken,
      });

      final newToken = response['token'];
      final newRefreshToken = response['refreshToken'];

      if (newToken != null && newRefreshToken != null) {
        final prefs = await _getPrefs();
        await Future.wait([
          prefs.setString(_keyToken, newToken),
          prefs.setString(_keyRefreshToken, newRefreshToken),
        ]);
        ApiService.clearHeadersCache();
      }

      return response;
    } on ApiException catch (e) {
      throw Exception(_normalizeErrorMessage(e));
    } catch (e) {
      throw Exception(
        'Token refresh failed: ${_cleanExceptionMessage(e.toString())}',
      );
    }
  }

  /// Logout user and clear all auth data
  static Future<void> logout() async {
    try {
      final prefs = await _getPrefs();
      final token = prefs.getString(_keyToken);

      // Attempt API logout (don't fail if it errors)
      if (token != null && token.isNotEmpty) {
        try {
          await ApiService.post('/auth/logout', {});
        } catch (e) {
          // Log but continue with local logout
          print('Logout API call failed: $e');
        }
      }

      // Clear all auth data in parallel
      await Future.wait(_authKeys.map((key) => prefs.remove(key)));

      // Clear API headers cache
      ApiService.clearHeadersCache();
    } catch (e) {
      // Even if logout fails, try to clear local data
      try {
        final prefs = await _getPrefs();
        await Future.wait(_authKeys.map((key) => prefs.remove(key)));
        ApiService.clearHeadersCache();
      } catch (_) {
        throw Exception(
          'Logout failed: ${_cleanExceptionMessage(e.toString())}',
        );
      }
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await _getPrefs();
      final token = prefs.getString(_keyToken);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get current user data from local storage
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await _getPrefs();
      final token = prefs.getString(_keyToken);

      if (token == null || token.isEmpty) return null;

      final userId = prefs.getString(_keyUserId);
      final userEmail = prefs.getString(_keyUserEmail);
      final userName = prefs.getString(_keyUserName);

      // Require basic user info
      if (userId == null || userEmail == null || userName == null) {
        return null;
      }

      return {
        'id': userId,
        'email': userEmail,
        'name': userName,
        'phone': prefs.getString(_keyUserPhone),
        'companyId': prefs.getString(_keyCompanyId),
        'companyName': prefs.getString(_keyCompanyName),
        'branchId': prefs.getString(_keyBranchId),
        'branchName': prefs.getString(_keyBranchName),
        'role': prefs.getString(_keyUserRole),
        'hasCompany': prefs.getBool(_keyHasCompany) ?? false,
        'hasBranch': prefs.getBool(_keyHasBranch) ?? false,
        'isApproved': prefs.getBool(_keyIsApproved) ?? false,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isEmailVerified': false,
      };
    } catch (e) {
      return null;
    }
  }

  /// Get stored authentication token
  static Future<String?> getToken() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(_keyToken);
    } catch (e) {
      return null;
    }
  }

  /// Get stored company ID
  static Future<String?> getCompanyId() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(_keyCompanyId);
    } catch (e) {
      return null;
    }
  }

  /// Get stored user role
  static Future<String?> getUserRole() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(_keyUserRole);
    } catch (e) {
      return null;
    }
  }

  /// Save token
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_keyToken, token);
      ApiService.clearHeadersCache();
    } catch (e) {
      throw Exception('Failed to save token');
    }
  }

  /// Save refresh token
  static Future<void> saveRefreshToken(String refreshToken) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_keyRefreshToken, refreshToken);
    } catch (e) {
      throw Exception('Failed to save refresh token');
    }
  }

  /// Update user profile data locally
  static Future<void> updateLocalUserData({
    String? name,
    String? companyName,
    String? phone,
  }) async {
    try {
      final prefs = await _getPrefs();
      final futures = <Future>[];

      if (name != null) {
        futures.add(prefs.setString(_keyUserName, name));
      }
      if (companyName != null) {
        futures.add(prefs.setString(_keyCompanyName, companyName));
      }
      if (phone != null) {
        futures.add(prefs.setString(_keyUserPhone, phone));
      }

      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }
    } catch (e) {
      throw Exception(
        'Failed to update user data: ${_cleanExceptionMessage(e.toString())}',
      );
    }
  }

  /// Clear all cached data (useful for testing)
  static Future<void> clearAllData() async {
    try {
      final prefs = await _getPrefs();
      await prefs.clear();
      _prefs = null;
      ApiService.clearHeadersCache();
    } catch (e) {
      throw Exception(
        'Failed to clear data: ${_cleanExceptionMessage(e.toString())}',
      );
    }
  }

  // ──────────────────────────────────────────────────────────────
  //  Private helper methods
  // ──────────────────────────────────────────────────────────────

  /// Save authentication data to SharedPreferences in parallel
  static Future<void> _saveAuthData(Map<String, dynamic> response) async {
    try {
      final prefs = await _getPrefs();

      final futures = <Future>[
        prefs.setString(_keyToken, response['token']?.toString() ?? ''),
        prefs.setString(
          _keyRefreshToken,
          response['refreshToken']?.toString() ??
              response['refresh_token']?.toString() ??
              '',
        ),
        prefs.setString(_keyUserId, response['id']?.toString() ?? ''),
        prefs.setString(_keyUserEmail, response['email']?.toString() ?? ''),
        prefs.setString(_keyUserName, response['name']?.toString() ?? ''),
        // Multi-tenant data
        prefs.setString(
          _keyCompanyId,
          response['companyId']?.toString() ??
              response['company_id']?.toString() ??
              '',
        ),
        prefs.setString(
          _keyCompanyName,
          response['companyName']?.toString() ??
              response['company_name']?.toString() ??
              response['shopName']?.toString() ??
              '',
        ),
        prefs.setString(
          _keyBranchId,
          response['branchId']?.toString() ??
              response['branch_id']?.toString() ??
              '',
        ),
        prefs.setString(
          _keyBranchName,
          response['branchName']?.toString() ??
              response['branch_name']?.toString() ??
              '',
        ),
        prefs.setString(_keyUserRole, response['role']?.toString() ?? 'Staff'),
        prefs.setBool(
          _keyHasCompany,
          response['hasCompany'] ?? response['has_company'] ?? false,
        ),
        prefs.setBool(
          _keyHasBranch,
          response['hasBranch'] ?? response['has_branch'] ?? false,
        ),
        prefs.setBool(
          _keyIsApproved,
          response['isApproved'] ?? response['is_approved'] ?? false,
        ),
      ];

      if (response['phone'] != null) {
        futures.add(
          prefs.setString(_keyUserPhone, response['phone'].toString()),
        );
      }

      await Future.wait(futures);
    } catch (e) {
      throw Exception(
        'Failed to save auth data: ${_cleanExceptionMessage(e.toString())}',
      );
    }
  }

  /// Normalize error messages from ApiException
  static String _normalizeErrorMessage(ApiException e) {
    final msg = e.message.toLowerCase();

    if (e.statusCode == 0) {
      return 'No internet connection.';
    } else if (e.statusCode >= 500) {
      return 'Server error. Please try again later.';
    } else if (e.statusCode == 401) {
      return 'Invalid credentials.';
    } else if (e.statusCode == 409 || msg.contains('already exists')) {
      return 'User with this email already exists.';
    } else if (msg.contains('not found')) {
      return 'User not found.';
    } else if (msg.contains('invalid') && msg.contains('password')) {
      return 'Invalid password.';
    } else if (msg.contains('validation')) {
      return 'Invalid input. Please check your data.';
    }

    return e.message;
  }

  /// Clean exception messages by removing prefixes
  static String _cleanExceptionMessage(String message) {
    return message
        .replaceFirst('Exception: ', '')
        .replaceFirst('ApiException: ', '')
        .trim();
  }
}
