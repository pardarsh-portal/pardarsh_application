import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/project_provider.dart';
import '../../provider/report_provider.dart';

class DashboardScreen extends StatefulWidget {
  final String userRole;

  const DashboardScreen({super.key, required this.userRole});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isLoading = true;
  Map<String, dynamic> projectStats = {};
  Map<String, dynamic> reportStats = {};

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to defer the API call until after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() => isLoading = true);

    try {
      final projectProvider = Provider.of<ProjectProvider>(
        context,
        listen: false,
      );
      final reportProvider = Provider.of<ReportProvider>(
        context,
        listen: false,
      );

      // Load project statistics
      try {
        projectStats = await projectProvider.getProjectStatistics();
      } catch (e) {
        projectStats = {};
      }

      // Load report statistics
      try {
        reportStats = await reportProvider.getReportStatistics();
      } catch (e) {
        reportStats = {};
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading dashboard: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              widget.userRole == 'contractor'
                                  ? Icons.engineering
                                  : Icons.account_balance,
                              size: 36,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back!',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall,
                                  ),
                                  Text(
                                    widget.userRole == 'contractor'
                                        ? 'Contractor Dashboard'
                                        : 'Government Dashboard',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Project Statistics
                    const Text(
                      'Project Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                      children: [
                        _buildStatCard(
                          title: 'Total Projects',
                          value: '${projectStats['totalProjects'] ?? 0}',
                          icon: Icons.work,
                          color: Colors.blue,
                        ),
                        _buildStatCard(
                          title: 'Active Projects',
                          value: '${projectStats['activeProjects'] ?? 0}',
                          icon: Icons.play_circle,
                          color: Colors.green,
                        ),
                        _buildStatCard(
                          title: 'Completed',
                          value: '${projectStats['completedProjects'] ?? 0}',
                          icon: Icons.check_circle,
                          color: Colors.purple,
                        ),
                        _buildStatCard(
                          title: 'Pending',
                          value: '${projectStats['pendingProjects'] ?? 0}',
                          icon: Icons.pending,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Report Statistics (for contractors)
                    if (widget.userRole == 'contractor') ...[
                      const Text(
                        'Report Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                        children: [
                          _buildStatCard(
                            title: 'Total Reports',
                            value: '${reportStats['totalReports'] ?? 0}',
                            icon: Icons.description,
                            color: Colors.indigo,
                          ),
                          _buildStatCard(
                            title: 'Pending Review',
                            value: '${reportStats['pendingReports'] ?? 0}',
                            icon: Icons.rate_review,
                            color: Colors.amber,
                          ),
                          _buildStatCard(
                            title: 'Approved',
                            value: '${reportStats['approvedReports'] ?? 0}',
                            icon: Icons.thumb_up,
                            color: Colors.teal,
                          ),
                          _buildStatCard(
                            title: 'This Week',
                            value: '${reportStats['thisWeekReports'] ?? 0}',
                            icon: Icons.today,
                            color: Colors.pink,
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Recent Activity (placeholder)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recent Activity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const ListTile(
                              leading: Icon(Icons.info, color: Colors.grey),
                              title: Text('Recent activity will appear here'),
                              subtitle: Text(
                                'Complete actions to see your activity timeline',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
