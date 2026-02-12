import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../company/pages/company_selection_page.dart';
import '../../branch/pages/branch_selection_page.dart';
import '../../dashboard/pages/dashboard_page.dart';
import '../pages/login_page.dart';
import 'pending_approval_screen.dart';

class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthAuthenticated) {
          final user = state.user;

          // Check authentication flow
          if (!user.hasCompany) {
            return const CompanySelectionPage();
          } else if (!user.isApproved) {
            return const PendingApprovalScreen();
          } else if (!user.hasBranch) {
            return const BranchSelectionPage();
          } else {
            return const DashboardPage();
          }
        }

        return const LoginPage();
      },
    );
  }
}
