import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:pardarsh_application/screens/government/contractor_list_screen.dart';
import 'package:pardarsh_application/screens/dashboard_screen.dart';
import 'package:pardarsh_application/provider/auth_provider.dart';
import 'package:pardarsh_application/provider/project_provider.dart';
import 'package:pardarsh_application/provider/report_provider.dart';
import '../../widgets/enhanced_widgets.dart';
import '../../theme/app_theme.dart';
import '../profile/profile_screen.dart';
import 'project_list_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
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
      Provider.of<ProjectProvider>(context, listen: false).fetchProjects();
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
          _buildContractorsPage(),
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
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Projects'),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Contractors',
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(user),
                    const SizedBox(height: 24),
                    _buildStatsGrid(projectProvider, reportProvider),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildRecentActivity(projectProvider),
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
                        //       ? const Icon(Icons.person, color: Colors.white)
                        //       : null,
                        // ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                              ),
                              Text(
                                user?.legalName ?? 'User',
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
                          icon: const Icon(
                            Icons.notifications,
                            color: Colors.white,
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
                Icon(Icons.account_balance, size: 32, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pardarsh Portal',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Government Project Management',
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
              title: 'Active Projects',
              value: projectProvider.projects
                  .where((p) => p.status == 'active')
                  .length
                  .toString(),
              icon: Icons.work,
              color: AppTheme.primaryColor,
              onTap: () => _onItemTapped(1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Pending Reports',
              value: reportProvider.reports
                  .where((r) => r.status == 'pending')
                  .length
                  .toString(),
              icon: Icons.pending_actions,
              color: AppTheme.warningColor,
              onTap: () {
                // Navigate to reports
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Contractors',
              value: '28',
              icon: Icons.people,
              color: AppTheme.successColor,
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
                'View analytics & insights',
                Icons.dashboard,
                AppTheme.primaryColor,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const DashboardScreen(userRole: 'government'),
                    ),
                  );
                },
              ),
              _buildQuickActionCard(
                'New Project',
                'Create a new project',
                Icons.add_circle,
                AppTheme.successColor,
                () {
                  // Navigate to new project
                },
              ),
              _buildQuickActionCard(
                'Reports',
                'Review project reports',
                Icons.description,
                AppTheme.warningColor,
                () {
                  // Navigate to reports
                },
              ),
              _buildQuickActionCard(
                'Settings',
                'App settings & preferences',
                Icons.settings,
                AppTheme.textSecondary,
                () {
                  // Navigate to settings
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

  Widget _buildRecentActivity(ProjectProvider projectProvider) {
    final recentProjects = projectProvider.projects.take(3).toList();

    return FadeInUp(
      delay: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Recent Activity',
            trailing: TextButton(
              onPressed: () => _onItemTapped(1),
              child: const Text('View All'),
            ),
          ),
          if (recentProjects.isEmpty)
            const EmptyStateWidget(
              title: 'No recent activity',
              subtitle: 'Your recent projects will appear here',
              icon: Icons.timeline,
            )
          else
            ...recentProjects.map(
              (project) => CustomCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.work, color: AppTheme.primaryColor),
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
                            project.description,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    StatusChip(
                      label: project.status,
                      color: _getStatusColor(project.status),
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
    return const ProjectListScreen();
  }

  Widget _buildContractorsPage() {
    return const ContractorListScreen();
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
}
