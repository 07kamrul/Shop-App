import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_management/blocs/auth/auth_bloc.dart';
import 'package:shop_management/core/utils/rbac_helper.dart';
import 'package:shop_management/data/models/user_role.dart';

/// Widget that shows/hides content based on user role permissions
class RBACWidget extends StatelessWidget {
  final UserRole? requiredRole;
  final List<UserRole>? allowedRoles;
  final Widget child;
  final Widget? fallback;
  final bool Function(UserRole)? customCheck;

  const RBACWidget({
    super.key,
    this.requiredRole,
    this.allowedRoles,
    required this.child,
    this.fallback,
    this.customCheck,
  }) : assert(
         requiredRole != null || allowedRoles != null || customCheck != null,
         'Must provide either requiredRole, allowedRoles, or customCheck',
       );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return fallback ?? const SizedBox.shrink();
        }

        final userRole = state.user.role;
        bool hasPermission = false;

        if (customCheck != null) {
          hasPermission = customCheck!(userRole);
        } else if (requiredRole != null) {
          hasPermission = userRole == requiredRole;
        } else if (allowedRoles != null) {
          hasPermission = allowedRoles!.contains(userRole);
        }

        return hasPermission ? child : (fallback ?? const SizedBox.shrink());
      },
    );
  }
}

/// Widget for Owner-only content
class OwnerOnly extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const OwnerOnly({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context) {
    return RBACWidget(
      requiredRole: UserRole.owner,
      child: child,
      fallback: fallback,
    );
  }
}

/// Widget for Manager or above content
class ManagerOrAbove extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const ManagerOrAbove({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context) {
    return RBACWidget(
      allowedRoles: const [UserRole.owner, UserRole.manager],
      child: child,
      fallback: fallback,
    );
  }
}

/// Widget that shows content based on custom permission check
class PermissionCheck extends StatelessWidget {
  final bool Function(UserRole) check;
  final Widget child;
  final Widget? fallback;

  const PermissionCheck({
    super.key,
    required this.check,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return RBACWidget(customCheck: check, child: child, fallback: fallback);
  }
}

/// Route guard mixin for pages that require specific permissions
mixin RouteGuard {
  /// Check if current user can access this route
  bool canAccess(BuildContext context) {
    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      return false;
    }

    return checkPermission(authState.user.role);
  }

  /// Override this to define permission check
  bool checkPermission(UserRole role);

  /// Navigate to route only if user has permission
  void navigateIfAllowed(
    BuildContext context,
    String route, {
    Object? arguments,
  }) {
    if (canAccess(context)) {
      Navigator.pushNamed(context, route, arguments: arguments);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to access this feature'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Example usage of RouteGuard
class CompanySettingsGuard with RouteGuard {
  @override
  bool checkPermission(UserRole role) {
    return RBACHelper.canAccessCompanySettings(role);
  }
}

class TeamManagementGuard with RouteGuard {
  @override
  bool checkPermission(UserRole role) {
    return RBACHelper.canViewTeam(role);
  }
}

class ReportsGuard with RouteGuard {
  @override
  bool checkPermission(UserRole role) {
    return RBACHelper.canViewReports(role);
  }
}
