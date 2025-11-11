import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/auth/auth_bloc.dart';
import '../../../../blocs/category/category_bloc.dart';
import '../../../../data/models/category_model.dart';
import '../../../../core/utils/validators.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetMarginController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Category')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Center(child: Text('Please log in to add categories'));
          }

          final user = authState.user;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Category Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _targetMarginController,
                    decoration: const InputDecoration(
                      labelText: 'Target Profit Margin % (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.percent),
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final margin = double.tryParse(value);
                        if (margin == null) {
                          return 'Please enter a valid number';
                        }
                        if (margin < 0 || margin > 100) {
                          return 'Profit margin must be between 0 and 100';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  BlocListener<CategoryBloc, CategoryState>(
                    listener: (context, state) {
                      if (state is CategoryOperationFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${state.error}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: ElevatedButton(
                      onPressed: () => _saveCategory(user.id),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, state) {
                          if (state is CategoryOperationInProgress) {
                            return const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            );
                          }
                          return const Text('Save Category');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveCategory(String userId) {
    if (_formKey.currentState!.validate()) {
      // Create category using the factory method
      final category = Category.create(
        name: _nameController.text.trim(),
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text.trim(),
        profitMarginTarget: _targetMarginController.text.isEmpty
            ? null
            : double.tryParse(_targetMarginController.text),
        createdBy: userId,
      );

      // Convert to the format expected by the CategoryBloc
      final categoryData = {
        'name': category.name,
        'description': category.description,
        'profitMarginTarget': category.profitMarginTarget,
        // Note: The current CategoryBloc expects a Map, not a Category object
        // You may need to update your CategoryBloc to accept Category objects directly
      };

      context.read<CategoryBloc>().add(AddCategory(category: categoryData));

      // Show success message immediately (the bloc will handle the actual operation)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adding category...'),
          backgroundColor: Colors.blue,
        ),
      );

      // Don't pop immediately - wait for the operation to complete
      // The navigation will happen when the operation succeeds via BlocListener
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetMarginController.dispose();
    super.dispose();
  }
}