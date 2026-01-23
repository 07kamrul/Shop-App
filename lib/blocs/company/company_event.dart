part of 'company_bloc.dart';

@immutable
abstract class CompanyEvent extends Equatable {
  const CompanyEvent();

  @override
  List<Object?> get props => [];
}

/// Load company details
class LoadCompany extends CompanyEvent {
  const LoadCompany();
}

/// Update company details
class UpdateCompany extends CompanyEvent {
  final String? name;
  final String? description;
  final String? phone;
  final String? email;
  final String? address;
  final String? logoUrl;
  final String? currency;
  final String? timezone;

  const UpdateCompany({
    this.name,
    this.description,
    this.phone,
    this.email,
    this.address,
    this.logoUrl,
    this.currency,
    this.timezone,
  });

  @override
  List<Object?> get props => [
        name,
        description,
        phone,
        email,
        address,
        logoUrl,
        currency,
        timezone,
      ];
}

/// Load company users/team members
class LoadCompanyUsers extends CompanyEvent {
  const LoadCompanyUsers();
}

/// Invite a new user to the company
class InviteUser extends CompanyEvent {
  final String email;
  final String password;
  final String name;
  final UserRole role;
  final String? phone;

  const InviteUser({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    this.phone,
  });

  @override
  List<Object?> get props => [email, password, name, role, phone];
}

/// Update a user's role
class UpdateUserRole extends CompanyEvent {
  final String userId;
  final UserRole role;

  const UpdateUserRole({
    required this.userId,
    required this.role,
  });

  @override
  List<Object?> get props => [userId, role];
}

/// Remove a user from the company
class RemoveUser extends CompanyEvent {
  final String userId;

  const RemoveUser({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Activate a user
class ActivateUser extends CompanyEvent {
  final String userId;

  const ActivateUser({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Deactivate a user
class DeactivateUser extends CompanyEvent {
  final String userId;

  const DeactivateUser({required this.userId});

  @override
  List<Object?> get props => [userId];
}
