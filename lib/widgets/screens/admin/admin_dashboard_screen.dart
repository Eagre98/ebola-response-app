import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/app_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/localization_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, int> _alertStats = {};
  Map<String, int> _userStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      final alertStats = await _firestoreService.getAlertStatistics();
      final userStats = await _firestoreService.getUserStatistics();

      setState(() {
        _alertStats = alertStats;
        _userStats = userStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading statistics: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.translate('dashboard')),
        backgroundColor: const Color(0xFF1E2328),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section
                    Consumer<AppProvider>(
                      builder: (context, appProvider, child) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: const Color(0xFF2196F3),
                                  child: Text(
                                    appProvider.currentUser?.firstName
                                            .substring(0, 1)
                                            .toUpperCase() ??
                                        'A',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome, ${appProvider.currentUser?.firstName ?? 'Admin'}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Administrator Dashboard',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Pending approvals alert
                    if (_userStats['pending'] != null &&
                        _userStats['pending']! > 0)
                      Card(
                        color: Colors.orange.withOpacity(0.1),
                        child: ListTile(
                          leading: const Icon(Icons.notification_important,
                              color: Colors.orange),
                          title: Text(
                            'Pending User Approvals',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange),
                          ),
                          subtitle: Text(
                            '${_userStats['pending']} users awaiting approval',
                            style: const TextStyle(color: Colors.orange),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              color: Colors.orange),
                          onTap: () =>
                              Navigator.pushNamed(context, '/manage-users'),
                        ),
                      ),
                    if (_userStats['pending'] != null &&
                        _userStats['pending']! > 0)
                      const SizedBox(height: 16),

                    // Statistics cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Alerts',
                            _alertStats['total']?.toString() ?? '0',
                            Icons.notification_important,
                            const Color(0xFF2196F3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Open Alerts',
                            _alertStats['open']?.toString() ?? '0',
                            Icons.warning,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Users',
                            _userStats['total']?.toString() ?? '0',
                            Icons.people,
                            const Color(0xFF03DAC6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Medical Team',
                            _userStats['medicalTeam']?.toString() ?? '0',
                            Icons.medical_services,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Alert status chart
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Alert Status Overview',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 200,
                              child: _buildAlertChart(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2,
                      children: [
                        _buildActionCard(
                          'Manage Users',
                          Icons.people_alt,
                          () => Navigator.pushNamed(context, '/manage-users'),
                        ),
                        _buildActionCard(
                          'Manage Alerts',
                          Icons.notification_important,
                          () => Navigator.pushNamed(context, '/manage-alerts'),
                        ),
                        _buildActionCard(
                          'View Reports',
                          Icons.assessment,
                          () => _showReportsDialog(),
                        ),
                        _buildActionCard(
                          'System Settings',
                          Icons.settings,
                          () => Navigator.pushNamed(context, '/settings'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertChart() {
    if (_alertStats.isEmpty || _alertStats['total'] == 0) {
      return Center(
        child: Text(
          'No alert data available',
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: Colors.red,
            value: (_alertStats['open'] ?? 0).toDouble(),
            title: 'Open\n${_alertStats['open']}',
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            color: Colors.orange,
            value: (_alertStats['assigned'] ?? 0).toDouble(),
            title: 'Assigned\n${_alertStats['assigned']}',
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            color: Colors.blue,
            value: (_alertStats['inProgress'] ?? 0).toDouble(),
            title: 'In Progress\n${_alertStats['inProgress']}',
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            color: Colors.green,
            value: (_alertStats['closed'] ?? 0).toDouble(),
            title: 'Closed\n${_alertStats['closed']}',
            radius: 60,
            titleStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF2196F3), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Reports'),
        content:
            const Text('Report generation feature will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
