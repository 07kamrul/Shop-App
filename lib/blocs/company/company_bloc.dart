import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:shop_management/core/services/company_service.dart';
import 'package:shop_management/data/models/company_model.dart';
import 'package:shop_management/data/models/user_role.dart';

part 'company_event.dart';
part 'company_state.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  CompanyBloc() : super(CompanyInitial()) {
    on<LoadCompany>(_onLoadCompany);
    on<UpdateCompany>(_onUpdateCompany);
    on<LoadCompanyUsers>(_onLoadCompanyUsers);
    on<InviteUser>(_onInviteUser);
    on<UpdateUserRole>(_onUpdateUserRole);
    on<RemoveUser>(_onRemoveUser);
    on<ActivateUser>(_onActivateUser);
    on<DeactivateUser>(_onDeactivateUser);
  }

  Future<void> _onLoadCompany(
    LoadCompany event,
    Emitter<CompanyState> emit,
  ) async {
    emit(CompanyLoading());
    try {
      final company = await CompanyService.getCompany();
      emit(CompanyLoaded(company: company));
    } catch (e) {
      emit(CompanyError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateCompany(
    UpdateCompany event,
    Emitter<CompanyState> emit,
  ) async {
    emit(CompanyLoading());
    try {
      final company = await CompanyService.updateCompany(
        name: event.name,
        description: event.description,
        phone: event.phone,
        email: event.email,
        address: event.address,
        logoUrl: event.logoUrl,
        currency: event.currency,
        timezone: event.timezone,
      );
      emit(CompanyLoaded(company: company));
      emit(CompanyUpdated(company: company));
    } catch (e) {
      emit(CompanyError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoadCompanyUsers(
    LoadCompanyUsers event,
    Emitter<CompanyState> emit,
  ) async {
    emit(CompanyUsersLoading());
    try {
      final users = await CompanyService.getUsers();
      emit(CompanyUsersLoaded(users: users));
    } catch (e) {
      emit(CompanyError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onInviteUser(
    InviteUser event,
    Emitter<CompanyState> emit,
  ) async {
    emit(CompanyUsersLoading());
    try {
      await CompanyService.inviteUser(
        email: event.email,
        password: event.password,
        name: event.name,
        role: event.role,
        phone: event.phone,
      );
      // Reload users after invite
      final users = await CompanyService.getUsers();
      emit(CompanyUsersLoaded(users: users));
      emit(UserInvited());
    } catch (e) {
      emit(CompanyError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateUserRole(
    UpdateUserRole event,
    Emitter<CompanyState> emit,
  ) async {
    emit(CompanyUsersLoading());
    try {
      await CompanyService.updateUserRole(
        userId: event.userId,
        role: event.role,
      );
      // Reload users after update
      final users = await CompanyService.getUsers();
      emit(CompanyUsersLoaded(users: users));
      emit(UserRoleUpdated());
    } catch (e) {
      emit(CompanyError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onRemoveUser(
    RemoveUser event,
    Emitter<CompanyState> emit,
  ) async {
    emit(CompanyUsersLoading());
    try {
      await CompanyService.removeUser(event.userId);
      // Reload users after removal
      final users = await CompanyService.getUsers();
      emit(CompanyUsersLoaded(users: users));
      emit(UserRemoved());
    } catch (e) {
      emit(CompanyError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onActivateUser(
    ActivateUser event,
    Emitter<CompanyState> emit,
  ) async {
    emit(CompanyUsersLoading());
    try {
      await CompanyService.activateUser(event.userId);
      // Reload users after activation
      final users = await CompanyService.getUsers();
      emit(CompanyUsersLoaded(users: users));
    } catch (e) {
      emit(CompanyError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeactivateUser(
    DeactivateUser event,
    Emitter<CompanyState> emit,
  ) async {
    emit(CompanyUsersLoading());
    try {
      await CompanyService.deactivateUser(event.userId);
      // Reload users after deactivation
      final users = await CompanyService.getUsers();
      emit(CompanyUsersLoaded(users: users));
    } catch (e) {
      emit(CompanyError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
