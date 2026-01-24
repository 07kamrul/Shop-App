import 'package:flutter/material.dart';
import '../../../core/services/company_service.dart';
import '../../dashboard/widgets/stats_card.dart';

class AdminStatsGrid extends StatelessWidget {
  const AdminStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        CompanyService.getAllCompanies(),
        CompanyService.getUsers(), // Updated to get all users for admin
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final companies = snapshot.data?[0] as List? ?? [];
        final users = snapshot.data?[1] as List? ?? [];

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            StatsCard(
              title: 'Total Companies',
              value: companies.length.toString(),
              icon: Icons.business,
              color: Colors.blue,
              subtitle: 'Active Tenants',
            ),
            StatsCard(
              title: 'Global Users',
              value: users.length.toString(),
              icon: Icons.people,
              color: Colors.green,
              subtitle: 'Across all companies',
            ),
          ],
        );
      },
    );
  }
}
