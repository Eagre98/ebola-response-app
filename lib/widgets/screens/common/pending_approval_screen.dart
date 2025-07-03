import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/localization_service.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.translate('pending_approval')),
        backgroundColor: const Color(0xFF1E2328),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings, size: 20),
                    const SizedBox(width: 8),
                    Text(LocalizationService.translate('settings')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 20),
                    const SizedBox(width: 8),
                    Text(LocalizationService.translate('logout')),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'settings') {
                Navigator.pushNamed(context, '/settings');
              } else if (value == 'logout') {
                final appProvider =
                    Provider.of<AppProvider>(context, listen: false);
                await appProvider.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              }
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pending approval icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_empty,
                      size: 64,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Application Under Review',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Thank you for applying to join the medical team. Your application is currently being reviewed by our administrators.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[300],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // User info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Application Details',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow('Name:',
                              appProvider.currentUser?.fullName ?? 'N/A'),
                          _buildInfoRow('Email:',
                              appProvider.currentUser?.email ?? 'N/A'),
                          _buildInfoRow('Role:',
                              LocalizationService.translate('medical_team')),
                          _buildInfoRow(
                              'Applied:',
                              appProvider.currentUser?.createdAt != null
                                  ? '${appProvider.currentUser!.createdAt.day}/${appProvider.currentUser!.createdAt.month}/${appProvider.currentUser!.createdAt.year}'
                                  : 'N/A'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // What's next section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What happens next?',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildStepItem('1. Admin review of your application'),
                          _buildStepItem('2. Verification of credentials'),
                          _buildStepItem('3. Approval notification via email'),
                          _buildStepItem('4. Access to medical team features'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Refresh button
                  ElevatedButton.icon(
                    onPressed: () async {
                      await appProvider.refreshUserData();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Check Status'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chat access
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/chat');
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Access Information Chatbot'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2196F3),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String step) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Color(0xFF2196F3),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              step,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
