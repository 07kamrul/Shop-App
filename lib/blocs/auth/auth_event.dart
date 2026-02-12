part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String? phone;
  final String? companyId;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    this.phone,
    this.companyId,
  });

  @override
  List<Object?> get props => [email, password, name, phone, companyId];
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}
