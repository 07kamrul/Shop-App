import 'package:shop_management/data/models/company_model.dart';
import 'package:shop_management/data/models/user_role.dart';
import 'api_service.dart';

class CompanyService {
  /// Get current company details
  static Future<Company> getCompany() async {
    try {
      final response = await ApiService.get('/company');
      return Company.fromJson(response);
    } on ApiException catch (e) {
      throw Exception('Failed to load company: ${e.message}');
    }
  }

  /// Get all companies (System Admin only)
  static Future<List<Company>> getAllCompanies() async {
    try {
      final response = await ApiService.get('/company/all');
      final List<dynamic> data = response is List
          ? response
          : response['data'] ?? [];
      return data.map((json) => Company.fromJson(json)).toList();
    } on ApiException catch (e) {
      throw Exception('Failed to load all companies: ${e.message}');
    }
  }

  /// Create a new company (System Admin only)
  static Future<Company> createCompany({
    required String name,
    String? description,
    String? phone,
    String? email,
    String? address,
    String? currency,
    String? timezone,
  }) async {
    try {
      final data = {
        'name': name,
        'description': description,
        'phone': phone,
        'email': email,
        'address': address,
        'currency': currency,
        'timezone': timezone,
      };

      final response = await ApiService.post('/company', data);
      return Company.fromJson(response);
    } on ApiException catch (e) {
      throw Exception('Failed to create company: ${e.message}');
    }
  }

  /// Update company details (Owner only)
  static Future<Company> updateCompany({
    String? name,
    String? description,
    String? phone,
    String? email,
    String? address,
    String? logoUrl,
    String? currency,
    String? timezone,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      if (address != null) data['address'] = address;
      if (logoUrl != null) data['logoUrl'] = logoUrl;
      if (currency != null) data['currency'] = currency;
      if (timezone != null) data['timezone'] = timezone;

      final response = await ApiService.put('/company', data);
      return Company.fromJson(response);
    } on ApiException catch (e) {
      throw Exception('Failed to update company: ${e.message}');
    }
  }

  /// Get all users in the company (Manager or above)
  static Future<List<CompanyUser>> getUsers() async {
    try {
      final response = await ApiService.get('/company/users');
      final List<dynamic> data = response is List
          ? response
          : response['data'] ?? [];
      return data.map((json) => CompanyUser.fromJson(json)).toList();
    } on ApiException catch (e) {
      throw Exception('Failed to load team members: ${e.message}');
    }
  }

  /// Invite a new user to the company (Owner only)
  static Future<CompanyUser> inviteUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
  }) async {
    try {
      final data = {
        'email': email,
        'password': password,
        'name': name,
        'role': role.name,
        if (phone != null) 'phone': phone,
      };

      final response = await ApiService.post('/company/users/invite', data);
      return CompanyUser.fromJson(response);
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        throw Exception('A user with this email already exists.');
      }
      throw Exception('Failed to invite user: ${e.message}');
    }
  }

  /// Update a user's role (Owner only)
  static Future<void> updateUserRole({
    required String userId,
    required UserRole role,
  }) async {
    try {
      await ApiService.put('/company/users/$userId/role', {'role': role.name});
    } on ApiException catch (e) {
      throw Exception('Failed to update user role: ${e.message}');
    }
  }

  /// Remove a user from the company (Owner only)
  static Future<void> removeUser(String userId) async {
    try {
      await ApiService.delete('/company/users/$userId');
    } on ApiException catch (e) {
      throw Exception('Failed to remove user: ${e.message}');
    }
  }

  /// Activate a user (Owner only)
  static Future<void> activateUser(String userId) async {
    try {
      await ApiService.put('/company/users/$userId/activate', {});
    } on ApiException catch (e) {
      throw Exception('Failed to activate user: ${e.message}');
    }
  }

  /// Deactivate a user (Owner only)
  static Future<void> deactivateUser(String userId) async {
    try {
      await ApiService.put('/company/users/$userId/deactivate', {});
    } on ApiException catch (e) {
      throw Exception('Failed to deactivate user: ${e.message}');
    }
  }
}
