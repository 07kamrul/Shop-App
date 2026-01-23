import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_management/blocs/company/company_bloc.dart';
import '../../../core/widgets/rbac_widget.dart';
import 'company_settings_page.dart';
import 'team_management_page.dart';

class CompanyPage extends StatefulWidget {
  const CompanyPage({super.key});

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CompanyBloc(),
      child: ManagerOrAbove(
        fallback: Scaffold(
          appBar: AppBar(title: const Text('Company')),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Access Denied',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('You do not have permission to view this page.'),
              ],
            ),
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Company'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.settings), text: 'Settings'),
                Tab(icon: Icon(Icons.people), text: 'Team'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: const [CompanySettingsPage(), TeamManagementPage()],
          ),
        ),
      ),
    );
  }
}
