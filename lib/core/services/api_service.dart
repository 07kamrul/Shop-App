import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const int timeoutSeconds = 15;

  // Cache the base URL to avoid repeated Platform checks
  static String? _cachedBaseUrl;

  static String get baseUrl {
    return _cachedBaseUrl ??= _determineBaseUrl();
  }

  static String _determineBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5033/api'; // Emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:5033/api';
    }
    return 'http://localhost:5033/api'; // fallback
  }

  // Cache headers to reduce SharedPreferences calls
  static Map<String, String>? _cachedHeaders;
  static DateTime? _headersCacheTime;
  static const _headersCacheDuration = Duration(minutes: 5);

  /// Get headers with optional caching
  static Future<Map<String, String>> _getHeaders({
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();

    // Return cached headers if still valid
    if (!forceRefresh &&
        _cachedHeaders != null &&
        _headersCacheTime != null &&
        now.difference(_headersCacheTime!) < _headersCacheDuration) {
      return _cachedHeaders!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      _cachedHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      _headersCacheTime = now;
      return _cachedHeaders!;
    } catch (e) {
      // Fallback headers without caching on error
      return {'Content-Type': 'application/json', 'Accept': 'application/json'};
    }
  }

  /// Clear cached headers (call this on logout or token refresh)
  static void clearHeadersCache() {
    _cachedHeaders = null;
    _headersCacheTime = null;
  }

  /// Handle API response with proper error extraction
  static dynamic _handleResponse(http.Response response) {
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return null; // Successful empty response (e.g., DELETE)
      }
      throw ApiException(
        message: 'Empty response from server',
        statusCode: response.statusCode,
      );
    }

    final dynamic responseBody;
    try {
      responseBody = json.decode(utf8.decode(response.bodyBytes));
    } catch (e) {
      throw ApiException(
        message: 'Invalid JSON response',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    }

    // Extract error message from various possible formats
    final errorMsg = _extractErrorMessage(responseBody, response.statusCode);

    throw ApiException(
      message: errorMsg,
      statusCode: response.statusCode,
      responseData: responseBody,
    );
  }

  /// Extract error message from response body
  static String _extractErrorMessage(dynamic responseBody, int statusCode) {
    if (responseBody is Map<String, dynamic>) {
      return responseBody['message']?.toString() ??
          responseBody['error']?.toString() ??
          responseBody['errors']?.toString() ??
          'HTTP $statusCode';
    }
    return 'HTTP $statusCode';
  }

  /// Execute HTTP request with unified error handling
  static Future<dynamic> _executeRequest(
    Future<http.Response> Function() requestFn,
    String method,
    String endpoint,
  ) async {
    try {
      final response = await requestFn().timeout(
        const Duration(seconds: timeoutSeconds),
      );
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException(
        message: 'Request timeout. Please try again.',
        statusCode: 408,
      );
    } on SocketException {
      throw ApiException(
        message: 'No internet connection. Please check your network.',
        statusCode: 0,
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        message: 'Server connection failed: ${e.message}',
        statusCode: 0,
      );
    } on ApiException {
      rethrow; // Re-throw API exceptions as-is
    } catch (e) {
      throw ApiException(message: 'Network error: $e', statusCode: 0);
    }
  }

  /// Generic GET request
  static Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool forceRefreshHeaders = false,
  }) async {
    final headers = await _getHeaders(forceRefresh: forceRefreshHeaders);
    var uri = Uri.parse('$baseUrl$endpoint');

    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(
        queryParameters: queryParams.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }

    if (_isDebugMode) print('API GET: $uri');

    return _executeRequest(
      () => http.get(uri, headers: headers),
      'GET',
      endpoint,
    );
  }

  /// Generic POST request
  static Future<dynamic> post(
    String endpoint,
    dynamic data, {
    bool forceRefreshHeaders = false,
  }) async {
    final headers = await _getHeaders(forceRefresh: forceRefreshHeaders);
    final uri = Uri.parse('$baseUrl$endpoint');

    if (_isDebugMode) {
      print('API POST: $uri');
      print('API Data: $data');
    }

    return _executeRequest(
      () => http.post(uri, headers: headers, body: json.encode(data)),
      'POST',
      endpoint,
    );
  }

  /// Generic PUT request
  static Future<dynamic> put(
    String endpoint,
    dynamic data, {
    bool forceRefreshHeaders = false,
  }) async {
    final headers = await _getHeaders(forceRefresh: forceRefreshHeaders);
    final uri = Uri.parse('$baseUrl$endpoint');

    if (_isDebugMode) print('API PUT: $uri');

    return _executeRequest(
      () => http.put(uri, headers: headers, body: json.encode(data)),
      'PUT',
      endpoint,
    );
  }

  /// Generic DELETE request
  static Future<dynamic> delete(
    String endpoint, {
    bool forceRefreshHeaders = false,
  }) async {
    final headers = await _getHeaders(forceRefresh: forceRefreshHeaders);
    final uri = Uri.parse('$baseUrl$endpoint');

    if (_isDebugMode) print('API DELETE: $uri');

    return _executeRequest(
      () => http.delete(uri, headers: headers),
      'DELETE',
      endpoint,
    );
  }

  /// Generic PATCH request (bonus - commonly needed)
  static Future<dynamic> patch(
    String endpoint,
    dynamic data, {
    bool forceRefreshHeaders = false,
  }) async {
    final headers = await _getHeaders(forceRefresh: forceRefreshHeaders);
    final uri = Uri.parse('$baseUrl$endpoint');

    if (_isDebugMode) print('API PATCH: $uri');

    return _executeRequest(
      () => http.patch(uri, headers: headers, body: json.encode(data)),
      'PATCH',
      endpoint,
    );
  }

  // Debug mode helper
  static bool get _isDebugMode {
    var debugMode = false;
    assert(debugMode = true);
    return debugMode;
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic responseData;

  const ApiException({
    required this.message,
    required this.statusCode,
    this.responseData,
  });

  bool get isNetworkError => statusCode == 0;
  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isServerError => statusCode >= 500;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isTimeout => statusCode == 408;

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiException &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          statusCode == other.statusCode;

  @override
  int get hashCode => message.hashCode ^ statusCode.hashCode;
}
