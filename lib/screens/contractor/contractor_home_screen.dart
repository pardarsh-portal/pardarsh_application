import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:pardarsh_application/screens/contractor/assigned_project_screen.dart';
import 'package:pardarsh_application/provider/auth_provider.dart';
import 'package:pardarsh_application/provider/project_provider.dart';
import 'package:pardarsh_application/provider/report_provider.dart';
import '../../widgets/enhanced_widgets.dart';
import '../../theme/app_theme.dart';
import '../profile/profile_screen.dart';
import '../dashboard_screen.dart';
import 'enhanced_report_management_screen.dart';

class ContractorHomeScreen extends StatefulWidget {
  const ContractorHomeScreen({super.key});

  @override
  State<ContractorHomeScreen> createState() => _ContractorHomeScreenState();
}

class _ContractorHomeScreenState extends State<ContractorHomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectProvider>(
        context,
        listen: false,
      ).fetchAssignedProjects();
      Provider.of<ReportProvider>(context, listen: false).fetchReports();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          _buildHomePage(),
          _buildProjectsPage(),
          _buildReportsPage(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textTertiary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Reports',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    return Consumer3<AuthProvider, ProjectProvider, ReportProvider>(
      builder: (context, authProvider, projectProvider, reportProvider, child) {
        final user = authProvider.user;

        return CustomScrollView(
          slivers: [
            _buildHomeAppBar(user),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(user),
                    const SizedBox(height: 24),
                    _buildStatsGrid(projectProvider, reportProvider),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildUpcomingDeadlines(projectProvider),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHomeAppBar(dynamic user) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  FadeInDown(
                    child: Row(
                      children: [
                        // CircleAvatar(
                        //   radius: 25,
                        //   backgroundColor: Colors.white.withOpacity(0.2),
                        //   backgroundImage: user?.profilePicture != null
                        //       ? NetworkImage(user!.profilePicture!)
                        //       : null,
                        //   child: user?.profilePicture == null
                        //       ? const Icon(
                        //           Icons.engineering,
                        //           color: Colors.white,
                        //         )
                        //       : null,
                        // ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello,',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                              ),
                              Text(
                                user?.legalName ?? 'Contractor',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Show notifications
                          },
                          icon: Stack(
                            children: [
                              const Icon(
                                Icons.notifications,
                                color: Colors.white,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(dynamic user) {
    return FadeInUp(
      child: GradientCard(
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.engineering, size: 32, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contractor Portal',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Manage your assigned projects & reports',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    ProjectProvider projectProvider,
    ReportProvider reportProvider,
  ) {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              title: 'Assigned Projects',
              value: projectProvider.assignedProjects.length.toString(),
              icon: Icons.assignment,
              color: AppTheme.primaryColor,
              subtitle:
                  '${projectProvider.assignedProjects.where((p) => p.status == 'active').length} active',
              onTap: () => _onItemTapped(1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Reports Due',
              value: reportProvider.reports
                  .where((r) => r.status == 'pending')
                  .length
                  .toString(),
              icon: Icons.pending_actions,
              color: AppTheme.warningColor,
              subtitle: 'This week',
              onTap: () => _onItemTapped(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Completed',
              value: reportProvider.reports
                  .where((r) => r.status == 'completed')
                  .length
                  .toString(),
              icon: Icons.check_circle,
              color: AppTheme.successColor,
              subtitle: 'This month',
              onTap: () => _onItemTapped(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Quick Actions'),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
            children: [
              _buildQuickActionCard(
                'Dashboard',
                'View performance metrics',
                Icons.dashboard,
                AppTheme.primaryColor,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const DashboardScreen(userRole: 'contractor'),
                    ),
                  );
                },
              ),
              _buildQuickActionCard(
                'New Report',
                'Submit project report',
                Icons.add_circle,
                AppTheme.successColor,
                () {
                  _showProjectSelection(context);
                },
              ),
              _buildQuickActionCard(
                'Calendar',
                'View deadlines & schedule',
                Icons.calendar_today,
                AppTheme.infoColor,
                () {
                  // Navigate to calendar
                },
              ),
              _buildQuickActionCard(
                'Help & Support',
                'Get assistance',
                Icons.help,
                AppTheme.textSecondary,
                () {
                  // Navigate to help
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textTertiary),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingDeadlines(ProjectProvider projectProvider) {
    return FadeInUp(
      delay: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Upcoming Deadlines',
            trailing: TextButton(
              onPressed: () => _onItemTapped(1),
              child: const Text('View All'),
            ),
          ),
          if (projectProvider.assignedProjects.isEmpty)
            const EmptyStateWidget(
              title: 'No upcoming deadlines',
              subtitle: 'Your project deadlines will appear here',
              icon: Icons.schedule,
            )
          else
            ...projectProvider.assignedProjects
                .take(3)
                .map(
                  (project) => CustomCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.schedule,
                            color: AppTheme.warningColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'Report due in 3 days',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppTheme.warningColor),
                              ),
                            ],
                          ),
                        ),
                        StatusChip(
                          label: project.status,
                          color: _getStatusColor(project.status),
                          icon: Icons.schedule,
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildProjectsPage() {
    return const ContractorAssignedProjectsScreen();
  }

  Widget _buildReportsPage() {
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, child) {
        if (projectProvider.assignedProjects.isEmpty) {
          return const Center(
            child: EmptyStateWidget(
              title: 'No Projects Assigned',
              subtitle: 'You need to have assigned projects to manage reports',
              icon: Icons.assignment_outlined,
            ),
          );
        }

        // Show the first project's reports by default
        final firstProject = projectProvider.assignedProjects.first;
        return EnhancedReportManagementScreen(
          projectId: firstProject.id,
          projectName: firstProject.name,
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppTheme.successColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'completed':
        return AppTheme.primaryColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  void _showProjectSelection(BuildContext context) async {
    try {
      final projectProvider = Provider.of<ProjectProvider>(
        context,
        listen: false,
      );
      await projectProvider.fetchAssignedProjects();

      if (context.mounted) {
        // Check for errors first
        if (projectProvider.lastError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error loading projects: ${projectProvider.lastError}',
              ),
              backgroundColor: AppTheme.errorColor,
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () => _showProjectSelection(context),
              ),
            ),
          );
          return;
        }

        if (projectProvider.assignedProjects.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No assigned projects found'),
              backgroundColor: AppTheme.warningColor,
            ),
          );
          return;
        }

        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Project for Reports',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...projectProvider.assignedProjects.map((project) {
                  return CustomCard(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EnhancedReportManagementScreen(
                            projectId: project.id,
                            projectName: project.name,
                          ),
                        ),
                      );
                    },
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.assignment,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                project.region,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppTheme.textTertiary,
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load projects: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
