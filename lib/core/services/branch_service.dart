import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/branch_model.dart';
import '../constants/app_constants.dart';

class BranchService {
  static const String baseUrl = AppConstants.apiBaseUrl;

  Future<List<Branch>> getBranches(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/branches'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Branch.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load branches: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load branches: $e');
    }
  }

  Future<Branch> getBranch(String token, String branchId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/branches/$branchId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return Branch.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load branch: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load branch: $e');
    }
  }

  Future<Branch> createBranch(String token, Branch branch) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/branches/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(branch.toCreateJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Branch.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create branch: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create branch: $e');
    }
  }

  Future<Map<String, dynamic>> selectBranch(String token, String branchId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/branches/select'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'branch_id': branchId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to select branch: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to select branch: $e');
    }
  }

  Future<Branch> updateBranch(String token, String branchId, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/branches/$branchId/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return Branch.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update branch: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update branch: $e');
    }
  }

  Future<void> deleteBranch(String token, String branchId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/branches/$branchId/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete branch: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to delete branch: $e');
    }
  }
}
