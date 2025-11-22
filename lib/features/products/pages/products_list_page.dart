// lib/features/products/pages/products_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/product/product_bloc.dart';
import '../widgets/product_card.dart';
import 'add_product_page.dart';

class ProductsListPage extends StatelessWidget {
  const ProductsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductBloc()..add(LoadProducts()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Products'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _openAddProductPage(context),
              tooltip: 'Add Product',
            ),
          ],
        ),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductsLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProductsLoadFailure) {
              return Center(
                child: Text('Failed to load products: ${state.error}'),
              );
            }
            if (state is ProductsLoadSuccess) {
              if (state.products.isEmpty) {
                return _buildEmptyState(context);
              }
              return _buildProductList(state.products);
            }
            return const Center(child: Text('Press + to add products'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openAddProductPage(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _openAddProductPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          // This shares the EXACT SAME ProductBloc instance
          value: context.read<ProductBloc>(),
          child: const AddProductPage(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 90, color: Colors.grey[400]),
          const SizedBox(height: 20),
          const Text(
            'No products yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Start adding your first product',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _openAddProductPage(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<dynamic> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProductCard(product: product),
        );
      },
    );
  }
}
