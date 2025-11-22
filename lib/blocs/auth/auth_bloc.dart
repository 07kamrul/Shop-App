import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:shop_management/data/models/user_model.dart';
import '../../../core/services/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }

  void _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await AuthService.register(
        email: event.email,
        password: event.password,
        name: event.name,
        shopName: event.shopName,
        phone: event.phone,
      );

      final User user = response is User
          ? response as User
          : User.fromJson(response as Map<String, dynamic>);

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(error: e.toString())); // Already clean from above
    }
  }

  void _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await AuthService.login(
        email: event.email,
        password: event.password,
      );

      // Handle both Map and User object responses
      final User user = response is User
          ? response as User
          : User.fromJson(response as Map<String, dynamic>);

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(error: e.toString()));
    }
  }

  void _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await AuthService.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(error: e.toString()));
    }
  }

  void _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        final userData = await AuthService.getCurrentUser();
        if (userData != null) {
          // Handle both Map and User object responses
          final User user = userData is User
              ? userData as User
              : User.fromJson(userData as Map<String, dynamic>);
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(error: e.toString()));
    }
  }
}
