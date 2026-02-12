import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/pending_company_model.dart';
import '../constants/app_constants.dart';

class AdminService {
  static const String baseUrl = AppConstants.apiBaseUrl;

  Future<List<PendingCompany>> getPendingCompanies(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/pending-companies'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PendingCompany.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load pending companies: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load pending companies: $e');
    }
  }

  Future<void> approveCompany(String token, String companyId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/approve-company'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'company_id': companyId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to approve company: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to approve company: $e');
    }
  }

  Future<void> rejectCompany(String token, String companyId, {String? reason}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/reject-company'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'company_id': companyId,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to reject company: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to reject company: $e');
    }
  }

  Future<void> suspendCompany(String token, String companyId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/suspend-company'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'company_id': companyId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to suspend company: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to suspend company: $e');
    }
  }
}
