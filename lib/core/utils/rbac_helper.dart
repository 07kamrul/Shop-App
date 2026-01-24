import 'package:shop_management/data/models/user_role.dart';

/// RBAC utility class for checking permissions and access control
class RBACHelper {
  /// Check if user can access company settings
  static bool canAccessCompanySettings(UserRole role) {
    return role == UserRole.owner;
  }

  /// Check if user can manage team (view, invite, modify users)
  static bool canManageTeam(UserRole role) {
    return role == UserRole.owner;
  }

  /// Check if user can view team members
  static bool canViewTeam(UserRole role) {
    return role == UserRole.owner || role == UserRole.manager;
  }

  /// Check if user can view reports and analytics
  static bool canViewReports(UserRole role) {
    return role == UserRole.owner || role == UserRole.manager;
  }

  /// Check if user can manage products (create, update, delete)
  static bool canManageProducts(UserRole role) {
    if (role == UserRole.unAssignedUser) return false;
    return true; // All assigned users can manage products
  }

  /// Check if user can manage sales
  static bool canManageSales(UserRole role) {
    if (role == UserRole.unAssignedUser) return false;
    return true; // All assigned users can manage sales
  }

  /// Check if user can manage customers
  static bool canManageCustomers(UserRole role) {
    if (role == UserRole.unAssignedUser) return false;
    return true; // All assigned users can manage customers
  }

  /// Check if user can manage suppliers
  static bool canManageSuppliers(UserRole role) {
    if (role == UserRole.unAssignedUser) return false;
    return true; // All assigned users can manage suppliers
  }

  /// Check if user can manage categories
  static bool canManageCategories(UserRole role) {
    if (role == UserRole.unAssignedUser) return false;
    return true; // All assigned users can manage categories
  }

  /// Check if user can invite other users
  static bool canInviteUsers(UserRole role) {
    return role == UserRole.owner;
  }

  /// Check if user can change other users' roles
  static bool canChangeUserRoles(UserRole role) {
    return role == UserRole.owner;
  }

  /// Check if user can activate/deactivate users
  static bool canActivateDeactivateUsers(UserRole role) {
    return role == UserRole.owner;
  }

  /// Check if user can remove users from company
  static bool canRemoveUsers(UserRole role) {
    return role == UserRole.owner;
  }

  /// Get role display name
  static String getRoleDisplayName(UserRole role) {
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

  /// Get role description
  static String getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.systemAdmin:
        return 'Full system administration access';
      case UserRole.owner:
        return 'Full access to all features including company settings and user management';
      case UserRole.manager:
        return 'Can view reports and manage team members';
      case UserRole.staff:
        return 'Can manage products, sales, customers, and suppliers';
      case UserRole.unAssignedUser:
        return 'Pending company assignment. Restricted access.';
    }
  }

  /// Get available routes for a user role
  static List<String> getAvailableRoutes(UserRole role) {
    if (role == UserRole.unAssignedUser) {
      return ['/dashboard'];
    }

    final routes = <String>[
      '/dashboard',
      '/products',
      '/sales',
      '/customers',
      '/suppliers',
      '/categories',
      '/inventory',
    ];

    if (canViewReports(role)) {
      routes.add('/reports');
      routes.add('/analytics');
    }

    if (canAccessCompanySettings(role)) {
      routes.add('/company/settings');
    }

    if (canViewTeam(role)) {
      routes.add('/company/team');
    }

    return routes;
  }

  /// Check if route is accessible for user role
  static bool canAccessRoute(UserRole role, String route) {
    return getAvailableRoutes(role).contains(route);
  }

  /// Get menu items based on user role
  static List<MenuItem> getMenuItems(UserRole role) {
    final items = <MenuItem>[
      MenuItem(title: 'Dashboard', icon: 'dashboard', route: '/dashboard'),
      MenuItem(title: 'Products', icon: 'inventory', route: '/products'),
      MenuItem(title: 'Sales', icon: 'shopping_cart', route: '/sales'),
      MenuItem(title: 'Customers', icon: 'people', route: '/customers'),
      MenuItem(title: 'Suppliers', icon: 'local_shipping', route: '/suppliers'),
      MenuItem(title: 'Categories', icon: 'category', route: '/categories'),
      MenuItem(title: 'Inventory', icon: 'warehouse', route: '/inventory'),
    ];

    if (canViewReports(role)) {
      items.add(
        MenuItem(title: 'Reports', icon: 'assessment', route: '/reports'),
      );
    }

    if (canAccessCompanySettings(role) || canViewTeam(role)) {
      items.add(
        MenuItem(title: 'Company', icon: 'business', route: '/company'),
      );
    }

    return items;
  }
}

/// Menu item model
class MenuItem {
  final String title;
  final String icon;
  final String route;

  MenuItem({required this.title, required this.icon, required this.route});
}
