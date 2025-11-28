// category_inventory_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_management/blocs/inventory/inventory_bloc.dart';

class CategoryInventoryPage extends StatelessWidget {
  const CategoryInventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory by Category')),
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          if (state is CategoryInventoryLoaded) {
            return ListView.builder(
              itemCount: state.categories.length,
              itemBuilder: (_, i) {
                final cat = state.categories[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple[100],
                    child: Text((i + 1).toString()),
                  ),
                  title: Text(cat.categoryName),
                  subtitle: Text(
                    '${cat.productCount} products • ₹${cat.stockValue.toStringAsFixed(0)}',
                  ),
                  trailing: Chip(label: Text('${cat.lowStockCount} low')),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
