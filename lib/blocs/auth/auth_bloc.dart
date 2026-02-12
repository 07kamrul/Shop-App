import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_management/core/services/api_service.dart';
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
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  void _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await AuthService.simpleRegister(
        email: event.email,
        password: event.password,
        name: event.name,
        phone: event.phone,
        companyId: event.companyId,
      );

      final message = response['message'] as String;
      emit(AuthRegistrationSuccess(message: message));
    } catch (e) {
      emit(AuthError(error: e.toString()));
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

      final User user = User.fromJson(response);

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

  void _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');

      // Clear API headers cache
      ApiService.clearHeadersCache();

      // Emit unauthenticated state
      emit(AuthUnauthenticated());
    } catch (e) {
      // Even if error occurs, emit unauthenticated
      emit(AuthUnauthenticated());
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
          final User user = User.fromJson(userData);
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
