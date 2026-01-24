import 'package:flutter/material.dart';
import '../../../data/models/user_role.dart';
import '../../company/pages/team_management_page.dart';
import '../../company/widgets/invite_user_dialog.dart';
import '../pages/admin_company_page.dart';

class AdminQuickActions extends StatelessWidget {
  const AdminQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Admin Control Panel',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              context,
              'Manage Companies',
              Icons.business_center,
              Colors.indigo,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminCompanyPage()),
              ),
            ),
            _buildActionCard(
              context,
              'Global Users',
              Icons.people_alt,
              Colors.teal,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TeamManagementPage()),
              ),
            ),
            _buildActionCard(
              context,
              'Add System Admin',
              Icons.admin_panel_settings,
              Colors.redAccent,
              () => _showInviteAdminDialog(context),
            ),
            _buildActionCard(
              context,
              'System Config',
              Icons.settings_suggest,
              Colors.blueGrey,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configuration coming soon')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInviteAdminDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          const InviteUserDialog(initialRole: UserRole.systemAdmin),
    );
  }
}
