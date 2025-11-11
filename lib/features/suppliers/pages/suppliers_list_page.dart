import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/auth/auth_bloc.dart';
import '../../../../blocs/supplier/supplier_bloc.dart';
import '../../../../data/models/supplier_model.dart';
import '../widgets/supplier_card.dart';
import 'add_supplier_page.dart';

class SuppliersListPage extends StatefulWidget {
  const SuppliersListPage({super.key});

  @override
  State<SuppliersListPage> createState() => _SuppliersListPageState();
}

class _SuppliersListPageState extends State<SuppliersListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      _loadAllSuppliers();
    } else {
      _searchSuppliers(_searchController.text);
    }
  }

  void _loadAllSuppliers() {
    context.read<SupplierBloc>().add(const LoadSuppliers());
  }

  void _searchSuppliers(String query) {
    context.read<SupplierBloc>().add(SearchSuppliers(query: query));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return Scaffold(
            appBar: AppBar(title: const Text('Suppliers')),
            body: const Center(child: Text('Please log in to view suppliers')),
          );
        }

        return BlocProvider(
          create: (context) => SupplierBloc()..add(const LoadSuppliers()),
          child: Scaffold(
            appBar: AppBar(
              title: _isSearching ? _buildSearchField() : const Text('Suppliers'),
              actions: _buildAppBarActions(),
            ),
            body: BlocConsumer<SupplierBloc, SupplierState>(
              listener: (context, state) {
                // Handle success operations
                if (state is SupplierOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Operation completed successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  // Reload suppliers after any operation
                  context.read<SupplierBloc>().add(const LoadSuppliers());
                }
                
                // Handle operation failures
                if (state is SupplierOperationFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${state.error}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is SuppliersLoadInProgress || 
                    state is SupplierOperationInProgress) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SuppliersLoadFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load suppliers',
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
                            context.read<SupplierBloc>().add(const LoadSuppliers());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is SuppliersLoadSuccess) {
                  final suppliers = state.suppliers;
                  
                  if (suppliers.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Convert to Supplier list - simplified without unnecessary type checks
                  final supplierList = suppliers.map((data) {
                    // Direct conversion assuming data is already Map<String, dynamic>
                    return Supplier.fromJson(data as Map<String, dynamic>);
                  }).toList();

                  return _buildSuppliersList(supplierList);
                }

                return const Center(child: Text('Load suppliers to get started'));
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddSupplierPage()),
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search suppliers...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
            });
            _loadAllSuppliers();
          },
        ),
      ];
    } else {
      return [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
      ];
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No Suppliers Yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first supplier to manage inventory',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddSupplierPage(),
                ),
              );
            },
            child: const Text('Add First Supplier'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuppliersList(List<Supplier> suppliers) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${suppliers.length} supplier${suppliers.length == 1 ? '' : 's'} found',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              return SupplierCard(supplier: supplier);
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}