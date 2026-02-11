part of 'company_bloc.dart';

@immutable
abstract class CompanyState extends Equatable {
  const CompanyState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CompanyInitial extends CompanyState {}

/// Loading company details
class CompanyLoading extends CompanyState {}

/// Company details loaded successfully
class CompanyLoaded extends CompanyState {
  final Company company;

  const CompanyLoaded({required this.company});

  @override
  List<Object?> get props => [company];
}

/// Company updated successfully
class CompanyUpdated extends CompanyState {
  final Company company;

  const CompanyUpdated({required this.company});

  @override
  List<Object?> get props => [company];
}

/// Loading company users
class CompanyUsersLoading extends CompanyState {}

/// Company users loaded successfully
class CompanyUsersLoaded extends CompanyState {
  final List<CompanyUser> users;

  const CompanyUsersLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}

/// User invited successfully
class UserInvited extends CompanyState {}

/// User role updated successfully
class UserRoleUpdated extends CompanyState {}

/// User removed successfully
class UserRemoved extends CompanyState {}

/// Error state
class CompanyError extends CompanyState {
  final String error;

  const CompanyError({required this.error});

  @override
  List<Object?> get props => [error];
}

/// Company created successfully
class CompanyCreated extends CompanyState {
  final Company company;

  const CompanyCreated({required this.company});

  @override
  List<Object?> get props => [company];
}
