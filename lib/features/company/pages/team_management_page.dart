import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_management/blocs/company/company_bloc.dart';
import 'package:shop_management/data/models/company_model.dart';
import 'package:shop_management/data/models/user_role.dart';
import '../widgets/invite_user_dialog.dart';
import '../widgets/user_list_item.dart';

class TeamManagementPage extends StatefulWidget {
  const TeamManagementPage({super.key});

  @override
  State<TeamManagementPage> createState() => _TeamManagementPageState();
}

class _TeamManagementPageState extends State<TeamManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<CompanyBloc>().add(const LoadCompanyUsers());
  }

  void _showInviteUserDialog() {
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<CompanyBloc>(context),
        child: const InviteUserDialog(),
      ),
    );
  }

  void _showUserActionsMenu(CompanyUser user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<CompanyBloc>(context),
        child: _UserActionsSheet(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CompanyBloc>().add(const LoadCompanyUsers());
            },
          ),
        ],
      ),
      body: BlocConsumer<CompanyBloc, CompanyState>(
        listener: (context, state) {
          if (state is CompanyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is UserInvited) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User invited successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is UserRoleUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User role updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is UserRemoved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User removed successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CompanyUsersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CompanyError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load team members',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CompanyBloc>().add(const LoadCompanyUsers());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CompanyUsersLoaded) {
            final users = state.users;

            if (users.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No team members yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        'Invite team members to collaborate on your shop',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Separate users by role
            final owner = users.where((u) => u.role == UserRole.owner).toList();
            final managers = users
                .where((u) => u.role == UserRole.manager)
                .toList();
            final staff = users.where((u) => u.role == UserRole.staff).toList();

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Team Overview Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Team Overview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn('Total', users.length.toString()),
                            _buildStatColumn(
                              'Managers',
                              managers.length.toString(),
                            ),
                            _buildStatColumn('Staff', staff.length.toString()),
                            _buildStatColumn(
                              'Active',
                              users.where((u) => u.isActive).length.toString(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Owner Section
                if (owner.isNotEmpty) ...[
                  const Text(
                    'Owner',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...owner.map(
                    (user) => UserListItem(
                      user: user,
                      onTap: () => _showUserActionsMenu(user),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Managers Section
                if (managers.isNotEmpty) ...[
                  const Text(
                    'Managers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...managers.map(
                    (user) => UserListItem(
                      user: user,
                      onTap: () => _showUserActionsMenu(user),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Staff Section
                if (staff.isNotEmpty) ...[
                  const Text(
                    'Staff',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...staff.map(
                    (user) => UserListItem(
                      user: user,
                      onTap: () => _showUserActionsMenu(user),
                    ),
                  ),
                ],
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showInviteUserDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Invite User'),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

class _UserActionsSheet extends StatelessWidget {
  final CompanyUser user;

  const _UserActionsSheet({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Header
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
                child: Text(
                  user.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getRoleColor(user.role),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),

          // Actions
          if (user.role != UserRole.owner) ...[
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Change Role'),
              onTap: () {
                Navigator.pop(context);
                _showChangeRoleDialog(context, user);
              },
            ),
            if (user.isActive)
              ListTile(
                leading: const Icon(Icons.block, color: Colors.orange),
                title: const Text('Deactivate User'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeactivate(context, user);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Activate User'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<CompanyBloc>().add(
                    ActivateUser(userId: user.id),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove User'),
              onTap: () {
                Navigator.pop(context);
                _confirmRemove(context, user);
              },
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Owner account cannot be modified',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showChangeRoleDialog(BuildContext context, CompanyUser user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change User Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select new role for ${user.name}:'),
            const SizedBox(height: 16),
            ...UserRole.values
                .where((role) => role != UserRole.owner)
                .map(
                  (role) => RadioListTile<UserRole>(
                    title: Text(_getRoleDisplayName(role)),
                    subtitle: Text(_getRoleDescription(role)),
                    value: role,
                    groupValue: user.role,
                    onChanged: (value) {
                      if (value != null) {
                        Navigator.pop(dialogContext);
                        context.read<CompanyBloc>().add(
                          UpdateUserRole(userId: user.id, role: value),
                        );
                      }
                    },
                  ),
                ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _confirmDeactivate(BuildContext context, CompanyUser user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Deactivate User'),
        content: Text(
          'Are you sure you want to deactivate ${user.name}? They will not be able to access the system.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CompanyBloc>().add(DeactivateUser(userId: user.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _confirmRemove(BuildContext context, CompanyUser user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove User'),
        content: Text(
          'Are you sure you want to remove ${user.name} from the company? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CompanyBloc>().add(RemoveUser(userId: user.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
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
      case UserRole.unAssignedUser:
        return Colors.grey;
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
      case UserRole.unAssignedUser:
        return 'Unassigned';
    }
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.systemAdmin:
        return 'Full system administration access';
      case UserRole.owner:
        return 'Full access to all features';
      case UserRole.manager:
        return 'Can manage team and view reports';
      case UserRole.staff:
        return 'Can manage products and sales';
      case UserRole.unAssignedUser:
        return 'Restricted access';
    }
  }
}
