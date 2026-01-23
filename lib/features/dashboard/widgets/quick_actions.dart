import 'package:flutter/material.dart';
import 'package:shop_management/features/categories/pages/categories_list_page.dart';
import 'package:shop_management/features/products/pages/add_product_page.dart';
import 'package:shop_management/features/products/pages/products_list_page.dart';
import 'package:shop_management/features/reports/page/reports_page.dart';
import 'package:shop_management/features/sales/pages/sale_list_page.dart';

import '../../analytics/pages/advanced_analytics_page.dart';
import '../../customers/pages/customers_list_page.dart';
import 'package:shop_management/features/sales/pages/create_sale_page.dart';
import '../../suppliers/pages/suppliers_list_page.dart';
import '../../../../core/widgets/rbac_widget.dart';
import '../../company/pages/company_page.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            // Company Management (Manager+)
            ManagerOrAbove(
              child: _buildActionButton(
                icon: Icons.business_center,
                label: 'Company',
                color: Colors.indigo,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompanyPage(),
                    ),
                  );
                },
              ),
            ),

            // Add Product (Manager+)
            ManagerOrAbove(
              child: _buildActionButton(
                icon: Icons.add,
                label: 'Add Product',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddProductPage(),
                    ),
                  );
                },
              ),
            ),

            // Products List (All)
            _buildActionButton(
              icon: Icons.list,
              label: 'Products',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductsListPage(),
                  ),
                );
              },
            ),

            // New Sale (All)
            _buildActionButton(
              icon: Icons.shopping_cart,
              label: 'New Sale',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateSalePage(),
                  ),
                );
              },
            ),

            // Sales History (All)
            _buildActionButton(
              icon: Icons.history,
              label: 'Sales',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SaleListPage()),
                );
              },
            ),

            // Reports (Manager+)
            ManagerOrAbove(
              child: _buildActionButton(
                icon: Icons.assessment,
                label: 'Reports',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportsPage(),
                    ),
                  );
                },
              ),
            ),

            // Categories (Manager+)
            ManagerOrAbove(
              child: _buildActionButton(
                icon: Icons.category,
                label: 'Categories',
                color: Colors.red,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoriesListPage(),
                    ),
                  );
                },
              ),
            ),

            // Customers (All)
            _buildActionButton(
              icon: Icons.people,
              label: 'Customers',
              color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomersListPage(),
                  ),
                );
              },
            ),

            // Suppliers (Manager+)
            ManagerOrAbove(
              child: _buildActionButton(
                icon: Icons.local_shipping,
                label: 'Suppliers',
                color: Colors.brown,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SuppliersListPage(),
                    ),
                  );
                },
              ),
            ),

            // Analytics (Owner Only)
            OwnerOnly(
              child: _buildActionButton(
                icon: Icons.analytics,
                label: 'Analytics',
                color: Colors.pink,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdvancedAnalyticsPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
