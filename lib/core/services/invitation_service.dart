import 'package:shop_management/core/services/api_service.dart';
import 'package:shop_management/data/models/user_role.dart';

class InvitationService {
  /// Send an invitation
  static Future<Map<String, dynamic>> sendInvite({
    required String email,
    required UserRole role,
    String? companyId,
  }) async {
    try {
      final data = {'email': email, 'role': role.value, 'companyId': companyId};

      final response = await ApiService.post('/invitations', data);
      return response;
    } catch (e) {
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
      final data = {
        'token': token,
        'name': name,
        'password': password,
        'phone': phone,
      };

      final response = await ApiService.post('/invitations/accept', data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
