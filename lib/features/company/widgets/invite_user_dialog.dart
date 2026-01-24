import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_management/blocs/auth/auth_bloc.dart';
import 'package:shop_management/core/services/company_service.dart';
import 'package:shop_management/core/services/invitation_service.dart';
import 'package:shop_management/core/utils/rbac_helper.dart';
import 'package:shop_management/data/models/company_model.dart';
import 'package:shop_management/data/models/user_role.dart';

class InviteUserDialog extends StatefulWidget {
  final String? companyId;
  final UserRole? initialRole;

  const InviteUserDialog({super.key, this.companyId, this.initialRole});

  @override
  State<InviteUserDialog> createState() => _InviteUserDialogState();
}

class _InviteUserDialogState extends State<InviteUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late UserRole _selectedRole;
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? UserRole.staff;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _handleInvite() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await InvitationService.sendInvite(
          email: _emailController.text.trim(),
          role: _selectedRole,
          companyId: widget.companyId,
        );

        if (!mounted) return;
        Navigator.pop(context); // Close invite dialog

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation successfully sent'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
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

  List<UserRole> _getAllowedRoles(UserRole currentUserRole) {
    if (currentUserRole == UserRole.systemAdmin) {
      return [
        UserRole.systemAdmin,
        UserRole.owner,
        UserRole.manager,
        UserRole.staff,
      ];
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
                    const Expanded(
                      child: Text(
                        'Invite Team Member',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                RawAutocomplete<CompanyUser>(
                  textEditingController: _emailController,
                  focusNode: FocusNode(),
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    final query = textEditingValue.text.trim();
                    if (query.isEmpty || query.length < 2) {
                      return const Iterable<CompanyUser>.empty();
                    }

                    final completer = Completer<Iterable<CompanyUser>>();
                    _debounce?.cancel();
                    _debounce = Timer(
                      const Duration(milliseconds: 300),
                      () async {
                        try {
                          final results = await CompanyService.searchUsers(
                            query,
                          );
                          if (!completer.isCompleted) {
                            completer.complete(results);
                          }
                        } catch (e) {
                          if (!completer.isCompleted) {
                            completer.complete(
                              const Iterable<CompanyUser>.empty(),
                            );
                          }
                        }
                      },
                    );

                    return completer.future;
                  },
                  displayStringForOption: (CompanyUser option) => option.email,
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                            hintText: 'Search or enter email',
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
                          onFieldSubmitted: (value) {
                            onFieldSubmitted();
                          },
                        );
                      },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 200,
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final CompanyUser option = options.elementAt(
                                index,
                              );
                              return ListTile(
                                leading: const Icon(Icons.person_outline),
                                title: Text(
                                  option.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  option.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  onSelected(option);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  onSelected: (CompanyUser selection) {
                    _emailController.text = selection.email;
                    // Optionally set role if user already has one?
                    // But usually we want to invite them with a NEW role in THIS company.
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
