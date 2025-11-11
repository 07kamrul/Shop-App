import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/auth/auth_bloc.dart';
import '../../../../blocs/category/category_bloc.dart';
import '../../../../data/models/category_model.dart';
import '../widgets/category_card.dart';
import 'add_category_page.dart';

class CategoriesListPage extends StatelessWidget {
  const CategoriesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return Scaffold(
            appBar: AppBar(title: const Text('Categories')),
            body: const Center(child: Text('Please log in to view categories')),
          );
        }

        final user = authState.user;

        return BlocProvider(
          create: (context) => CategoryBloc()..add(const LoadCategories()),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Categories'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddCategoryPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: BlocConsumer<CategoryBloc, CategoryState>(
              listener: (context, state) {
                // Handle success operations
                if (state is CategoryOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Operation completed successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  // Reload categories after any operation
                  context.read<CategoryBloc>().add(const LoadCategories());
                }
                
                // Handle operation failures
                if (state is CategoryOperationFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${state.error}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is CategoriesLoadInProgress || 
                    state is CategoryOperationInProgress) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CategoriesLoadFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load categories',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.error,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<CategoryBloc>().add(const LoadCategories());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is CategoriesLoadSuccess) {
                  final categories = state.categories;
                  
                  // Convert dynamic list to Category list
                  final categoryList = categories.map((data) {
                    if (data is Category) {
                      return data;
                    } else if (data is Map<String, dynamic>) {
                      return Category.fromJson(data);
                    } else {
                      // Handle unexpected data type
                      return Category.create(
                        name: 'Unknown Category',
                        createdBy: user.id,
                      );
                    }
                  }).toList();

                  return categoryList.isEmpty
                      ? _buildEmptyState()
                      : _buildCategoriesList(categoryList);
                }

                return const Center(child: Text('Load categories to get started'));
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddCategoryPage()),
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No Categories Yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first category to organize products',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(List<Category> categories) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard(category: category);
      },
    );
  }
}