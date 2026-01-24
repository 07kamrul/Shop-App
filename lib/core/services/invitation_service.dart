import 'package:shop_management/core/services/api_service.dart';
import 'package:shop_management/data/models/user_role.dart';

class InvitationService {
  /// Convert Flutter enum name to C# enum name format
  /// Flutter: systemAdmin -> C#: SystemAdmin
  static String _toCSharpEnumName(UserRole role) {
    switch (role) {
      case UserRole.systemAdmin:
        return 'SystemAdmin';
      case UserRole.owner:
        return 'Owner';
      case UserRole.manager:
        return 'Manager';
      case UserRole.staff:
        return 'Staff';
      case UserRole.unAssignedUser:
        return 'UnAssignedUser';
    }
  }

  /// Send an invitation
  static Future<Map<String, dynamic>> sendInvite({
    required String email,
    required UserRole role,
    String? companyId,
  }) async {
    try {
      // Build request data with camelCase property names (ASP.NET Core default)
      // Backend DTO has PascalCase properties but JSON serializer handles conversion
      final data = <String, dynamic>{
        'email': email.trim(),
        'role': _toCSharpEnumName(role),
      };

      // Only include companyId if it's provided and not empty
      // Backend expects Guid? (nullable Guid), so send null if not provided
      // If companyId is null or empty, don't include it in the request
      if (companyId != null && companyId.trim().isNotEmpty) {
        data['companyId'] = companyId.trim();
      }

      print('InvitationService: Sending invite with data: $data');
      final response = await ApiService.post('/invitations', data);
      return response;
    } catch (e) {
      print('InvitationService: Error sending invite: $e');
      rethrow;
    }
  }

  /// Accept an invitation
  static Future<Map<String, dynamic>> acceptInvite({
    required String token,
    required String name,
    required String password,
    String? phone,
  }) async {
    try {
      final data = <String, dynamic>{
        'token': token.trim(),
        'name': name.trim(),
        'password': password,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      };

      final response = await ApiService.post('/invitations/accept', data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Claim an invitation for the logged-in user
  static Future<Map<String, dynamic>> claimInvitation(String token) async {
    try {
      final response = await ApiService.post('/invitations/claim', token);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Get pending invitations for the current user
  static Future<List<dynamic>> getMyInvitations() async {
    try {
      final response = await ApiService.get('/invitations/my');
      return response as List<dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Accept an invitation by ID
  static Future<Map<String, dynamic>> acceptInvitationById(String id) async {
    try {
      final response = await ApiService.post('/invitations/$id/accept', {});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Reject an invitation by ID
  static Future<Map<String, dynamic>> rejectInvitation(String id) async {
    try {
      final response = await ApiService.post('/invitations/$id/reject', {});
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
