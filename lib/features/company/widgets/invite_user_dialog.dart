import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_management/blocs/auth/auth_bloc.dart';
import 'package:shop_management/core/services/invitation_service.dart';
import 'package:shop_management/core/utils/rbac_helper.dart';
import 'package:shop_management/data/models/user_role.dart';

class InviteUserDialog extends StatefulWidget {
  const InviteUserDialog({super.key});

  @override
  State<InviteUserDialog> createState() => _InviteUserDialogState();
}

class _InviteUserDialogState extends State<InviteUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  UserRole _selectedRole = UserRole.staff;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleInvite() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await InvitationService.sendInvite(
          email: _emailController.text.trim(),
          role: _selectedRole,
        );

        if (!mounted) return;
        Navigator.pop(context); // Close invite dialog

        // Show token dialog (Simulation)
        final token = response['token'] as String;
        _showTokenDialog(token);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send invite: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showTokenDialog(String token) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invitation Sent'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Invitation sent successfully!'),
            const SizedBox(height: 16),
            const Text(
              'For testing purposes, here is the invitation token:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              token,
              style: const TextStyle(
                fontFamily: 'Courier',
                backgroundColor: Colors.black12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: token));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Token copied to clipboard')),
              );
            },
            child: const Text('Copy Token'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  List<UserRole> _getAllowedRoles(UserRole currentUserRole) {
    if (currentUserRole == UserRole.systemAdmin) {
      return [UserRole.systemAdmin, UserRole.manager];
    } else if (currentUserRole == UserRole.owner ||
        currentUserRole == UserRole.manager) {
      return [UserRole.manager, UserRole.staff];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    UserRole currentUserRole = UserRole.staff;
    if (authState is AuthAuthenticated) {
      currentUserRole = authState.user.role;
    }

    final allowedRoles = _getAllowedRoles(currentUserRole);

    // If initial selected role is not in allowed roles, update it
    if (!allowedRoles.contains(_selectedRole) && allowedRoles.isNotEmpty) {
      _selectedRole = allowedRoles.first;
    }

    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_add, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Invite Team Member',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Only show role selection if there are allowed roles (and more than 1 preferably, but showing 1 is okay)
                if (allowedRoles.isNotEmpty) ...[
                  const Text(
                    'Select Role',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ...allowedRoles.map(
                    (role) => RadioListTile<UserRole>(
                      title: Text(RBACHelper.getRoleDisplayName(role)),
                      subtitle: Text(RBACHelper.getRoleDescription(role)),
                      value: role,
                      groupValue: _selectedRole,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedRole = value;
                          });
                        }
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ] else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('You do not have permission to invite anyone.'),
                  ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading || allowedRoles.isEmpty
                          ? null
                          : _handleInvite,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Send Invite'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
