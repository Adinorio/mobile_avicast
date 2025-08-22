import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_avicast/providers/auth_provider.dart';
import 'package:mobile_avicast/providers/sync_provider.dart';
import 'package:mobile_avicast/providers/network_provider.dart';
import 'package:mobile_avicast/utils/theme.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Avicast'),
        actions: [
          // Network Status Indicator
          Consumer<NetworkProvider>(
            builder: (context, networkProvider, child) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: Icon(
                  networkProvider.isLocalNetworkAvailable
                      ? Icons.wifi
                      : Icons.wifi_off,
                  color: networkProvider.isLocalNetworkAvailable
                      ? AppTheme.successColor
                      : AppTheme.warningColor,
                ),
              );
            },
          ),
          
          // Sync Status
          Consumer<SyncProvider>(
            builder: (context, syncProvider, child) {
              if (syncProvider.pendingUploads > 0 || syncProvider.pendingDownloads > 0) {
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Badge(
                    label: Text('${syncProvider.pendingUploads + syncProvider.pendingDownloads}'),
                    child: Icon(
                      Icons.sync,
                      color: AppTheme.infoColor,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          // User Menu
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              } else if (value == 'profile') {
                _showProfile();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardTab(),
          _buildDataTab(),
          _buildSyncTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.data_usage),
            label: 'Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sync),
            label: 'Sync',
          ),

        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Consumer3<AuthProvider, NetworkProvider, SyncProvider>(
      builder: (context, authProvider, networkProvider, syncProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authProvider.currentUser?.fullName ?? 'User',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Role: ${authProvider.currentUser?.role ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Network Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            networkProvider.isLocalNetworkAvailable
                                ? Icons.wifi
                                : Icons.wifi_off,
                            color: networkProvider.isLocalNetworkAvailable
                                ? AppTheme.successColor
                                : AppTheme.warningColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Network Status',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        networkProvider.isLocalNetworkAvailable
                            ? 'Connected to local network'
                            : 'Offline mode - using local data',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (networkProvider.currentNetworkName != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Network: ${networkProvider.currentNetworkName}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.add_location,
                      title: 'Add Site',
                      onTap: () {
                        // Navigate to add site
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.eco,
                      title: 'Add Species',
                      onTap: () {
                        // Navigate to add species
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.upload_file,
                      title: 'Import Data',
                      onTap: () {
                        // Navigate to import data
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.sync,
                      title: 'Sync Now',
                      onTap: () {
                        syncProvider.syncAllData();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataTab() {
    return const Center(
      child: Text('Data Management - Coming Soon'),
    );
  }

  Widget _buildSyncTab() {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sync Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.sync,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Sync Status',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Last Sync Time
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Last Sync: ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            syncProvider.lastSyncTime != null
                                ? DateTime.parse(syncProvider.lastSyncTime!).toString()
                                : 'Never',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Pending Items
                      Row(
                        children: [
                          Icon(
                            Icons.pending,
                            size: 16,
                            color: AppTheme.warningColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pending Uploads: ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${syncProvider.pendingUploads}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.warningColor,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Icon(
                            Icons.download,
                            size: 16,
                            color: AppTheme.infoColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pending Downloads: ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${syncProvider.pendingDownloads}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.infoColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Sync Actions
              ElevatedButton.icon(
                onPressed: syncProvider.isSyncing ? null : syncProvider.syncAllData,
                icon: syncProvider.isSyncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                label: Text(syncProvider.isSyncing ? 'Syncing...' : 'Sync All Data'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: syncProvider.isUploading ? null : syncProvider.forceUpload,
                      icon: syncProvider.isUploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload),
                      label: Text(syncProvider.isUploading ? 'Uploading...' : 'Upload'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: syncProvider.isDownloading ? null : syncProvider.forceDownload,
                      icon: syncProvider.isDownloading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: Text(syncProvider.isDownloading ? 'Downloading...' : 'Download'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }



  void _handleLogout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _showProfile() {
    // Show user profile dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Profile'),
        content: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.currentUser;
            if (user == null) return const Text('No user data');
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${user.fullName}'),
                Text('Employee ID: ${user.employeeId}'),
                Text('Role: ${user.role}'),
                if (user.email != null) Text('Email: ${user.email}'),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 