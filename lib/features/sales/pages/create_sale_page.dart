import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/auth/auth_bloc.dart';
import '../../../../blocs/product/product_bloc.dart';
import '../../../../blocs/sale/sale_bloc.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/models/sale_model.dart';

class CreateSalePage extends StatefulWidget {
  const CreateSalePage({super.key});

  @override
  State<CreateSalePage> createState() => _CreateSalePageState();
}

class _CreateSalePageState extends State<CreateSalePage> {
  final List<SaleItem> _saleItems = [];
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  String _paymentMethod = 'cash';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductBloc>().add(LoadProducts());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SaleBloc(),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return Scaffold(
              appBar: AppBar(title: const Text('New Sale')),
              body: const Center(child: Text('Please log in to create sales')),
            );
          }

          final user = authState.user;

          return Scaffold(
            appBar: AppBar(
              title: const Text('New Sale'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saleItems.isNotEmpty
                      ? () => _completeSale(user.id)
                      : null,
                ),
              ],
            ),
            body: Column(
              children: [
                // Customer Info
                _buildCustomerInfo(),

                // Products List
                Expanded(
                  child: BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (state is ProductsLoadInProgress) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is ProductsLoadFailure) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load products',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(state.error, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<ProductBloc>().add(
                                    LoadProducts(),
                                  );
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is ProductsLoadSuccess) {
                        final products = state.products;

                        // Filter products with stock and convert to Product objects
                        final availableProducts = products.where((productData) {
                          if (productData is Map<String, dynamic>) {
                            final currentStock =
                                productData['currentStock'] ?? 0;
                            return currentStock > 0;
                          } else if (productData is Product) {
                            return productData.currentStock > 0;
                          }
                          return false;
                        }).toList();

                        return _buildProductsGrid(availableProducts);
                      }

                      return const Center(
                        child: Text('Load products to start sale'),
                      );
                    },
                  ),
                ),

                // Sale Summary
                _buildSaleSummary(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Add this
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _customerPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Cash')),
                DropdownMenuItem(value: 'card', child: Text('Card')),
                DropdownMenuItem(value: 'upi', child: Text('UPI')),
                DropdownMenuItem(value: 'online', child: Text('Online')),
              ],
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid(List<dynamic> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final productData = products[index];
        final product = _convertToProduct(productData);
        final saleItem = _saleItems.firstWhere(
          (item) => item.productId == product.id,
          orElse: () => const SaleItem(
            productId: '',
            productName: '',
            quantity: 0,
            unitBuyingPrice: 0,
            unitSellingPrice: 0,
          ),
        );

        return _buildProductCard(product, saleItem);
      },
    );
  }

  Product _convertToProduct(dynamic productData) {
    if (productData is Product) {
      return productData;
    } else if (productData is Map<String, dynamic>) {
      return Product(
        id: productData['id'] ?? productData['_id'],
        name: productData['name'] ?? 'Unknown Product',
        categoryId: productData['categoryId'],
        buyingPrice: (productData['buyingPrice'] ?? 0).toDouble(),
        sellingPrice: (productData['sellingPrice'] ?? 0).toDouble(),
        currentStock: productData['currentStock'] ?? 0,
        minStockLevel: productData['minStockLevel'] ?? 10,
        barcode: productData['barcode'],
        supplierId: productData['supplierId'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: productData['createdBy'] ?? '',
      );
    } else {
      return Product(
        id: 'unknown',
        name: 'Unknown Product',
        categoryId: '',
        buyingPrice: 0,
        sellingPrice: 0,
        currentStock: 0,
        minStockLevel: 10,
        barcode: null,
        supplierId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'system',
      );
    }
  }

  Widget _buildProductCard(Product product, SaleItem saleItem) {
    final isInCart = saleItem.quantity > 0;

    return Card(
      elevation: isInCart ? 4 : 1,
      color: isInCart ? Colors.blue[50] : null,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Stock: ${product.currentStock}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              '₹${product.sellingPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const Spacer(),
            if (isInCart)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: () =>
                        _updateQuantity(product, saleItem.quantity - 1),
                  ),
                  Text(
                    saleItem.quantity.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () =>
                        _updateQuantity(product, saleItem.quantity + 1),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _updateQuantity(product, 1),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Add to Sale'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleSummary() {
    final totalAmount = _saleItems.fold<double>(
      0.0,
      (sum, item) => sum + item.totalAmount,
    );
    final totalProfit = _saleItems.fold<double>(
      0.0,
      (sum, item) => sum + item.totalProfit,
    );

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Items:'),
                Text(_saleItems.length.toString()),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount:'),
                Text(
                  '₹${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Profit:'),
                Text(
                  '₹${totalProfit.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BlocConsumer<SaleBloc, SaleState>(
              listener: (context, state) {
                if (state is SaleOperationFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sale failed: ${state.error}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is SalesLoadSuccess) {
                  // Sale was added successfully and sales reloaded
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sale completed successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _saleItems.isNotEmpty &&
                            state is! SaleOperationInProgress
                        ? () {
                            final authState = context.read<AuthBloc>().state;
                            if (authState is AuthAuthenticated) {
                              _completeSale(authState.user.id);
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                    ),
                    child: state is SaleOperationInProgress
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Complete Sale',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateQuantity(Product product, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _saleItems.removeWhere((item) => item.productId == product.id);
      } else {
        if (newQuantity > product.currentStock) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Not enough stock available'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final existingIndex = _saleItems.indexWhere(
          (item) => item.productId == product.id,
        );

        if (existingIndex >= 0) {
          _saleItems[existingIndex] = SaleItem(
            productId: product.id!,
            productName: product.name,
            quantity: newQuantity,
            unitBuyingPrice: product.buyingPrice,
            unitSellingPrice: product.sellingPrice,
          );
        } else {
          _saleItems.add(
            SaleItem(
              productId: product.id!,
              productName: product.name,
              quantity: newQuantity,
              unitBuyingPrice: product.buyingPrice,
              unitSellingPrice: product.sellingPrice,
            ),
          );
        }
      }
    });
  }

  void _completeSale(String userId) {
    if (_saleItems.isEmpty) return;

    final totalAmount = _saleItems.fold<double>(
      0.0,
      (sum, item) => sum + item.totalAmount,
    );
    final totalCost = _saleItems.fold<double>(
      0.0,
      (sum, item) => sum + item.totalCost,
    );
    final totalProfit = _saleItems.fold<double>(
      0.0,
      (sum, item) => sum + item.totalProfit,
    );

    final sale = Sale.create(
      items: _saleItems,
      customerName: _customerNameController.text.isEmpty
          ? null
          : _customerNameController.text.trim(),
      customerPhone: _customerPhoneController.text.isEmpty
          ? null
          : _customerPhoneController.text.trim(),
      paymentMethod: _paymentMethod,
      createdBy: userId,
    );

    context.read<SaleBloc>().add(AddSale(sale: sale));
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }
}
