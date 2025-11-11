import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      'http://localhost:5033/api'; // Change to your API URL
  static const int timeoutSeconds = 30;

  // Get headers with authentication
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final headers = {'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Handle API response
  static dynamic _handleResponse(http.Response response) {
    final responseBody = json.decode(utf8.decode(response.bodyBytes));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      throw ApiException(
        message: responseBody['message'] ?? 'An error occurred',
        statusCode: response.statusCode,
      );
    }
  }

  // Generic GET request - FIXED: Added queryParams as named parameter
  static Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: timeoutSeconds));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection', statusCode: 0);
    } on http.ClientException {
      throw ApiException(message: 'Server connection failed', statusCode: 0);
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 0);
    }
  }

  // Generic POST request
  static Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await http
          .post(uri, headers: headers, body: json.encode(data))
          .timeout(const Duration(seconds: timeoutSeconds));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection', statusCode: 0);
    } on http.ClientException {
      throw ApiException(message: 'Server connection failed', statusCode: 0);
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 0);
    }
  }

  // Generic PUT request
  static Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await http
          .put(uri, headers: headers, body: json.encode(data))
          .timeout(const Duration(seconds: timeoutSeconds));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection', statusCode: 0);
    } on http.ClientException {
      throw ApiException(message: 'Server connection failed', statusCode: 0);
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 0);
    }
  }

  // Generic DELETE request
  static Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await http
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: timeoutSeconds));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection', statusCode: 0);
    } on http.ClientException {
      throw ApiException(message: 'Server connection failed', statusCode: 0);
    } catch (e) {
      throw ApiException(message: e.toString(), statusCode: 0);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
