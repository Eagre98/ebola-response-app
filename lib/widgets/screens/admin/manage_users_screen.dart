import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/app_provider.dart';
import '../../services/auth_service.dart';
import '../../services/localization_service.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.translate('users')),
        backgroundColor: const Color(0xFF1E2328),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.hourglass_empty),
              text: LocalizationService.translate('pending_approval'),
            ),
            Tab(
              icon: const Icon(Icons.people),
              text: 'All Users',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingUsersTab(),
          _buildAllUsersTab(),
        ],
      ),
    );
  }

  Widget _buildPendingUsersTab() {
    return StreamBuilder<List<UserModel>>(
      stream: _authService.getPendingApprovalUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  'No pending approvals',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'All applications have been processed',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildPendingUserCard(user);
          },
        );
      },
    );
  }

  Widget _buildAllUsersTab() {
    return StreamBuilder<List<UserModel>>(
      stream: _authService.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return Center(
            child: Text(
              LocalizationService.translate('no_data'),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[400],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildUserCard(user);
          },
        );
      },
    );
  }

  Widget _buildPendingUserCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Text(
                    user.firstName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Pending',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Applied: ${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _rejectUser(user),
                  child:
                      const Text('Reject', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _approveUser(user),
                  child: Text(LocalizationService.translate('approve')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.role),
          child: Text(
            user.firstName.substring(0, 1).toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.email,
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.role).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getRoleDisplayName(user.role),
                    style: TextStyle(
                      color: _getRoleColor(user.role),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (!user.isApproved)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Pending',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (!user.isApproved)
              PopupMenuItem(
                value: 'approve',
                child: Row(
                  children: [
                    const Icon(Icons.check, size: 16),
                    const SizedBox(width: 8),
                    Text(LocalizationService.translate('approve')),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'change_role',
              child: const Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Change Role'),
                ],
              ),
            ),
            if (user.role != UserRole.admin)
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(LocalizationService.translate('delete')),
                  ],
                ),
              ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'approve':
                _approveUser(user);
                break;
              case 'change_role':
                _showChangeRoleDialog(user);
                break;
              case 'delete':
                _showDeleteUserDialog(user);
                break;
            }
          },
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.purple;
      case UserRole.medicalTeam:
        return Colors.green;
      case UserRole.normalUser:
        return Colors.blue;
      case UserRole.pendingApproval:
        return Colors.orange;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return LocalizationService.translate('admin');
      case UserRole.medicalTeam:
        return LocalizationService.translate('medical_team');
      case UserRole.normalUser:
        return LocalizationService.translate('normal_user');
      case UserRole.pendingApproval:
        return LocalizationService.translate('pending_approval');
    }
  }

  void _approveUser(UserModel user) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    bool success = await appProvider.approveUser(user.uid);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocalizationService.translate('user_approved')),
          backgroundColor: Colors.green,
        ),
      );
    } else if (appProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _rejectUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Application'),
        content: Text(
            'Are you sure you want to reject ${user.fullName}\'s application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LocalizationService.translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement user rejection (delete user)
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(UserModel user) {
    UserRole selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change User Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Change role for ${user.fullName}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: UserRole.values
                    .where((role) => role != UserRole.pendingApproval)
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(_getRoleDisplayName(role)),
                        ))
                    .toList(),
                onChanged: (UserRole? value) {
                  if (value != null) {
                    setState(() {
                      selectedRole = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(LocalizationService.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final appProvider =
                    Provider.of<AppProvider>(context, listen: false);
                bool success =
                    await appProvider.updateUserRole(user.uid, selectedRole);

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User role updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text(LocalizationService.translate('save')),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteUserDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
            'Are you sure you want to delete ${user.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LocalizationService.translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement user deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User deletion feature will be implemented'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: Text(
              LocalizationService.translate('delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
