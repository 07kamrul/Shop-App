import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_management/blocs/category/category_bloc.dart';
import 'package:shop_management/blocs/company/company_bloc.dart';
import 'package:shop_management/blocs/product/product_bloc.dart';
import 'package:shop_management/blocs/sale/sale_bloc.dart';
import 'package:shop_management/core/services/api_service.dart';
import 'blocs/auth/auth_bloc.dart';
import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/register_page.dart';
import 'features/auth/widgets/auth_router.dart';
import 'features/company/pages/company_selection_page.dart';
import 'features/branch/pages/branch_selection_page.dart';
import 'features/dashboard/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(AuthCheckRequested()),
        ),
        BlocProvider<CompanyBloc>(
          create: (context) => CompanyBloc(),
        ),
        BlocProvider<CategoryBloc>(
          create: (context) => CategoryBloc()..add(const LoadCategories()),
        ),
        BlocProvider<ProductBloc>(
          create: (context) => ProductBloc()..add(LoadProducts()),
        ),
        BlocProvider<SaleBloc>(create: (context) => SaleBloc()),
      ],
      child: MaterialApp(
        title: 'Shop Management',
        debugShowCheckedModeBanner: false,

        // Add the global navigator key from ApiService
        navigatorKey: ApiService.navigatorKey,

        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),

        // Define all your named routes here
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/company-selection': (context) => const CompanySelectionPage(),
          '/branch-selection': (context) => const BranchSelectionPage(),
          '/home': (context) => const DashboardPage(),
        },

        // Use AuthRouter as home
        home: const AuthRouter(),

        // Optional: Fallback if route not found
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) =>
                const Scaffold(body: Center(child: Text('Page Not Found'))),
          );
        },
      ),
    );
  }
}
