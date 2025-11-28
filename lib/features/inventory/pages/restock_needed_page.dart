// restock_needed_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_management/blocs/inventory/inventory_bloc.dart';

class RestockNeededPage extends StatelessWidget {
  const RestockNeededPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restock Needed')),
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          if (state is RestockNeededLoaded) {
            return ListView.builder(
              itemCount: state.products.length,
              itemBuilder: (_, i) {
                final p = state.products[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: p.currentStock == 0
                        ? Colors.red
                        : Colors.orange,
                    child: Text(p.currentStock.toString()),
                  ),
                  title: Text(p.name),
                  subtitle: Text('Min: ${p.minStockLevel}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
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
