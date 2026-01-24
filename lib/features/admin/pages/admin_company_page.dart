import 'package:flutter/material.dart';
import '../../../core/services/company_service.dart';
import '../../../data/models/company_model.dart';
import '../../company/widgets/invite_user_dialog.dart';

class AdminCompanyPage extends StatefulWidget {
  const AdminCompanyPage({super.key});

  @override
  State<AdminCompanyPage> createState() => _AdminCompanyPageState();
}

class _AdminCompanyPageState extends State<AdminCompanyPage> {
  List<Company> _companies = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final companies = await CompanyService.getAllCompanies();
      setState(() {
        _companies = companies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Companies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCompanies,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCompanyDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCompanies,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_companies.isEmpty) {
      return const Center(child: Text('No companies found'));
    }

    return ListView.builder(
      itemCount: _companies.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final company = _companies[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: company.isActive
                  ? Colors.green[100]
                  : Colors.red[100],
              child: Icon(
                Icons.business,
                color: company.isActive ? Colors.green[800] : Colors.red[800],
              ),
            ),
            title: Text(
              company.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(company.email ?? 'No email provided'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCompanyDetails(company),
          ),
        );
      },
    );
  }

  void _showCompanyDetails(Company company) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      company.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                _buildDetailItem(
                  Icons.info_outline,
                  'Description',
                  company.description ?? 'No description',
                ),
                _buildDetailItem(
                  Icons.phone,
                  'Phone',
                  company.phone ?? 'No phone',
                ),
                _buildDetailItem(
                  Icons.email,
                  'Email',
                  company.email ?? 'No email',
                ),
                _buildDetailItem(
                  Icons.location_on,
                  'Address',
                  company.address ?? 'No address',
                ),
                _buildDetailItem(
                  Icons.monetization_on,
                  'Currency',
                  company.currency,
                ),
                _buildDetailItem(
                  Icons.schedule,
                  'Timezone',
                  company.timezone ?? 'Asia/Dhaka',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showInviteToCompanyDialog(company);
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Invite Manager to this Company'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInviteToCompanyDialog(Company company) {
    showDialog(
      context: context,
      builder: (context) => InviteUserDialog(companyId: company.id),
    );
  }

  void _showCreateCompanyDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Company'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Company Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;

              Navigator.pop(context);
              setState(() => _isLoading = true);

              try {
                await CompanyService.createCompany(
                  name: nameController.text,
                  email: emailController.text,
                  phone: phoneController.text,
                );
                _loadCompanies();
              } catch (e) {
                setState(() {
                  _error = e.toString();
                  _isLoading = false;
                });
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
