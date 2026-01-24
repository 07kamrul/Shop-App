import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_management/core/services/invitation_service.dart';
import 'package:shop_management/data/models/user_model.dart';
import '../../../../blocs/auth/auth_bloc.dart';

class UnassignedDashboard extends StatefulWidget {
  final User user;
  const UnassignedDashboard({super.key, required this.user});

  @override
  State<UnassignedDashboard> createState() => _UnassignedDashboardState();
}

class _UnassignedDashboardState extends State<UnassignedDashboard> {
  List<dynamic> _invitations = [];
  bool _isLoading = false;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _fetchInvitations();
  }

  Future<void> _fetchInvitations() async {
    setState(() => _isFetching = true);
    try {
      final invitations = await InvitationService.getMyInvitations();
      if (!mounted) return;
      setState(() => _invitations = invitations);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load invitations: $e')));
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  Future<void> _handleAccept(String id) async {
    print('UnassignedDashboard: Accepting invitation ID: $id');
    setState(() => _isLoading = true);
    try {
      final result = await InvitationService.acceptInvitationById(id);
      print('UnassignedDashboard: Accept result: $result');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully joined company!'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh user data to enable features
      context.read<AuthBloc>().add(AuthCheckRequested());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to accept: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleReject(String id) async {
    setState(() => _isLoading = true);
    try {
      await InvitationService.rejectInvitation(id);
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invitation rejected.')));
      _fetchInvitations();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to reject: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.business_outlined,
                  size: 64,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Company Assigned',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'You haven\'t joined a company yet. To enable all features, please accept an invitation sent by your company owner.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (_isFetching)
                  const Center(child: CircularProgressIndicator())
                else if (_invitations.isEmpty)
                  _buildNoInvitationsView()
                else
                  _buildInvitationsList(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.orange),
            title: const Text('Waiting for an invite?'),
            subtitle: Text(
              'Contact your administrator to send an invitation to ${widget.user.email}',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoInvitationsView() {
    return Column(
      children: [
        const Icon(Icons.mail_outline, size: 48, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'No pending invitations found',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: _fetchInvitations,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      ],
    );
  }

  Widget _buildInvitationsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pending Invitations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ..._invitations.map((invite) {
          final companyName = invite['companyName'] ?? 'Unknown Company';
          final id = invite['id'] as String;
          return Card(
            color: Colors.blue.withOpacity(0.05),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                companyName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Role: ${invite['role']}'),
              trailing: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          onPressed: () => _handleAccept(id),
                          tooltip: 'Accept',
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _handleReject(id),
                          tooltip: 'Reject',
                        ),
                      ],
                    ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
