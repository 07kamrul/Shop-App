import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_management/core/utils/barcode_scanner.dart';
import '../../../../blocs/auth/auth_bloc.dart';
import '../../../../blocs/category/category_bloc.dart';
import '../../../../blocs/product/product_bloc.dart';
import '../../../../core/utils/validators.dart';

class EditProductPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late final _formKey = GlobalKey<FormState>();

  late final _nameController = TextEditingController(text: widget.product['name'] ?? '');
  late final _barcodeController = TextEditingController(text: widget.product['barcode']?.toString() ?? '');
  late final _buyingPriceController = TextEditingController(text: widget.product['buyingPrice']?.toString() ?? '');
  late final _sellingPriceController = TextEditingController(text: widget.product['sellingPrice']?.toString() ?? '');
  late final _stockController = TextEditingController(text: widget.product['currentStock']?.toString() ?? '');
  late final _minStockController = TextEditingController(
      text: (widget.product['minStockLevel'] ?? 10).toString());

  late String? _selectedCategoryId = widget.product['categoryId']?.toString() ??
      widget.product['category']?['_id']?.toString() ??
      widget.product['category']?['id']?.toString();

  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  void _loadCategories() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CategoryBloc>().add(const LoadCategories());
    }
  }

  void _scanBarcode() async {
    try {
      final barcode = await BarcodeScannerUtil.scanBarcode();
      if (barcode != null) {
        setState(() {
          _barcodeController.text = barcode;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scanned barcode: $barcode'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barcode scan failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(
                        labelText: 'Barcode (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _scanBarcode,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                    child: const Icon(Icons.qr_code_scanner),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _buyingPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Buying Price *',
                        border: OutlineInputBorder(),
                        prefixText: '₹',
                        prefixIcon: Icon(Icons.shopping_cart),
                      ),
                      keyboardType: TextInputType.number,
                      validator: Validators.validatePrice,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _sellingPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Selling Price *',
                        border: OutlineInputBorder(),
                        prefixText: '₹',
                        prefixIcon: Icon(Icons.sell),
                      ),
                      keyboardType: TextInputType.number,
                      validator: Validators.validatePrice,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Current Stock *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      keyboardType: TextInputType.number,
                      validator: Validators.validateStock,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _minStockController,
                      decoration: const InputDecoration(
                        labelText: 'Min Stock Level',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.warning),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildProfitPreview(),
              const SizedBox(height: 32),
              _UpdateProductButton(formKey: _formKey, onUpdate: _updateProduct),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoriesLoadInProgress) return const LinearProgressIndicator();
        if (state is CategoriesLoadFailure) {
          return Column(
            children: [
              Text('Error loading categories: ${state.error}', style: const TextStyle(color: Colors.red)),
              ElevatedButton(onPressed: _loadCategories, child: const Text('Retry')),
            ],
          );
        }
        if (state is CategoriesLoadSuccess) {
          _categories = state.categories;

          if (_categories.isEmpty) {
            return const Text('No categories available', style: TextStyle(color: Colors.orange));
          }

          return DropdownButtonFormField<String>(
            value: _selectedCategoryId,
            decoration: const InputDecoration(
              labelText: 'Category *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category),
            ),
            items: _categories.map((category) {
              final id = category is Map<String, dynamic>
                  ? (category['id'] ?? category['_id'])
                  : category.id;
              final name = category is Map<String, dynamic> ? category['name'] : category.name;

              return DropdownMenuItem<String>(value: id?.toString(), child: Text(name?.toString() ?? 'Unknown'));
            }).toList(),
            onChanged: (value) => setState(() => _selectedCategoryId = value),
            validator: (value) => value == null ? 'Please select a category' : null,
          );
        }
        return const Text('Loading categories...');
      },
    );
  }

  Widget _buildProfitPreview() {
    final buying = double.tryParse(_buyingPriceController.text) ?? 0;
    final selling = double.tryParse(_sellingPriceController.text) ?? 0;
    final profit = selling - buying;
    final margin = selling > 0 ? (profit / selling) * 100 : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Profit Preview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Profit per unit:'),
              Text('₹${profit.toStringAsFixed(2)}',
                  style: TextStyle(color: profit >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Profit margin:'),
              Text('${margin.toStringAsFixed(1)}%',
                  style: TextStyle(color: margin >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
            ]),
          ],
        ),
      ),
    );
  }

  void _updateProduct() {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      final updatedProduct = {
        'id': widget.product['id'] ?? widget.product['_id'], // important!
        'name': _nameController.text.trim(),
        'barcode': _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
        'categoryId': _selectedCategoryId!,
        'buyingPrice': double.parse(_buyingPriceController.text),
        'sellingPrice': double.parse(_sellingPriceController.text),
        'currentStock': int.parse(_stockController.text),
        'minStockLevel': int.parse(_minStockController.text.isEmpty ? '10' : _minStockController.text),
      };

      context.read<ProductBloc>().add(UpdateProduct(product: updatedProduct));
    } else if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _buyingPriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }
}

// Button that listens to update success/failure
class _UpdateProductButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onUpdate;

  const _UpdateProductButton({required this.formKey, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductOperationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red),
          );
        } else if (state is ProductsLoadSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final bool inProgress = state is ProductOperationInProgress;
        return ElevatedButton(
          onPressed: inProgress ? null : onUpdate,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          child: inProgress
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                )
              : const Text('Update Product'),
        );
      },
    );
  }
}