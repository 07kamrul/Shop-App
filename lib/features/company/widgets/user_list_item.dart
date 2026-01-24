import 'package:flutter/material.dart';
import 'package:shop_management/data/models/company_model.dart';
import 'package:shop_management/data/models/user_role.dart';

class UserListItem extends StatelessWidget {
  final CompanyUser user;
  final VoidCallback onTap;

  const UserListItem({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
          child: Text(
            user.name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _getRoleColor(user.role),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!user.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Inactive',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.role).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getRoleDisplayName(user.role),
                    style: TextStyle(
                      color: _getRoleColor(user.role),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (user.phone != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.phone, size: 12, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    user.phone!,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
                if (user.shopName != null && user.shopName != 'N/A') ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      user.shopName!,
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (user.lastLoginAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Last login: ${_formatDate(user.lastLoginAt!)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
        trailing: user.role != UserRole.owner
            ? const Icon(Icons.more_vert)
            : Icon(Icons.verified, color: Colors.purple[700]),
        onTap: onTap,
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.systemAdmin:
        return Colors.deepPurple;
      case UserRole.owner:
        return Colors.purple;
      case UserRole.manager:
        return Colors.blue;
      case UserRole.staff:
        return Colors.green;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.systemAdmin:
        return 'System Admin';
      case UserRole.owner:
        return 'Owner';
      case UserRole.manager:
        return 'Manager';
      case UserRole.staff:
        return 'Staff';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return 'Today ${_formatTime(date)}';
    } else if (dateDay == yesterday) {
      return 'Yesterday ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
