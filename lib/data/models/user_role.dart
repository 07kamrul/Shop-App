/// User roles for multi-tenant authorization
enum UserRole {
  owner(1, 'Owner'),
  manager(2, 'Manager'),
  staff(3, 'Staff');

  final int value;
  final String displayName;

  const UserRole(this.value, this.displayName);

  /// Parse from string (case-insensitive)
  static UserRole fromString(String? value) {
    if (value == null || value.isEmpty) return UserRole.staff;

    final lower = value.toLowerCase();
    return UserRole.values.firstWhere(
      (role) => role.name.toLowerCase() == lower,
      orElse: () => UserRole.staff,
    );
  }

  /// Parse from integer value
  static UserRole fromValue(int? value) {
    if (value == null) return UserRole.staff;

    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.staff,
    );
  }

  /// Check if user is owner
  bool get isOwner => this == UserRole.owner;

  /// Check if user is manager or above (owner or manager)
  bool get isManagerOrAbove => this == UserRole.owner || this == UserRole.manager;

  /// Check if user can manage company settings
  bool get canManageCompany => isOwner;

  /// Check if user can manage team members
  bool get canManageUsers => isOwner;

  /// Check if user can view team members
  bool get canViewTeam => isManagerOrAbove;

  /// Check if user can manage inventory (all roles can)
  bool get canManageInventory => true;

  /// Check if user can create sales (all roles can)
  bool get canCreateSales => true;

  /// Check if user can view reports
  bool get canViewReports => isManagerOrAbove;
}
