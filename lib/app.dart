import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/sites/presentation/pages/sites_page.dart';
import 'features/bird_counting/presentation/pages/counting_site_page.dart';
import 'features/notes/presentation/pages/note_page.dart';
import 'features/notes/presentation/pages/camera_page.dart';
import 'features/sites/presentation/pages/site_birds_page.dart';
import 'features/bird_counting/presentation/pages/bird_counter_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'utils/theme.dart';
import 'features/sites/data/services/sites_database_service.dart';
import 'features/notes/data/services/notes_local_storage_service.dart';
import 'core/services/user_context_service.dart';
import 'screens/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avicast Mobile',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/main': (context) => const MainApp(),
        '/sites': (context) => const SitesPage(),
        '/site-birds': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return SiteBirdsPage(siteName: args ?? 'Unknown Site');
        },
        '/counting': (context) => const CountingSitePage(),
        '/bird-counter': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          if (args != null) {
            return BirdCounterPage(
              birdName: args['birdName'] ?? 'Unknown Bird',
              birdImage: args['birdImage'] ?? '',
              birdStatus: args['birdStatus'] ?? 'Unknown',
              birdFamily: args['birdFamily'] ?? 'Unknown',
              birdScientificName: args['birdScientificName'] ?? 'Unknown',
              siteName: args['siteName'] ?? 'Unknown Site',
            );
          }
          return const BirdCounterPage(
            birdName: 'Unknown Bird',
            birdImage: '',
            birdStatus: 'Unknown',
            birdFamily: 'Unknown',
            birdScientificName: 'Unknown',
            siteName: 'Unknown Site',
          );
        },
        '/notes': (context) => const NotePage(),
        '/camera': (context) => const CameraPage(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Check authentication status immediately when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(AuthCheckRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const MainApp();
        } else if (state is Unauthenticated) {
          return const LoginPage();
        } else {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const SitesPage(),
    const CountingSitePage(),
    const NotePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: AppTheme.avicastBlue,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Document icon (left)
            IconButton(
              icon: const Icon(
                Icons.description,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                setState(() {
                  _currentIndex = 2; // Notes page
                });
              },
            ),
            
            // Bird icon (center) - Now clickable for save data functionality
            GestureDetector(
              onTap: _showSaveDataConfirmation,
              child: Container(
                width: 70,
                height: 70,
                margin: const EdgeInsets.only(bottom: 20), // Overlap the top edge
                decoration: BoxDecoration(
                  color: const Color(0xFF87CEEB), // Light blue background
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.flutter_dash,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            
            // Camera icon
            IconButton(
              icon: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CameraPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Show save data confirmation dialog
  Future<void> _showSaveDataConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.save_alt,
                color: AppTheme.avicastBlue,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Save All Data',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: const Text(
            'Do you want to save all the data of the system? This will ensure your data is preserved and you can come back anytime without losing information.',
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'No',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.avicastBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Yes, Save Data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      // User chose to save data
      await _saveAllDataAndLogout();
    }
    // If result is false, user chose not to save, so stay in the system
  }

  // Save all data and logout
  Future<void> _saveAllDataAndLogout() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Saving all data...'),
              ],
            ),
          );
        },
      );

      // Save all data using available services
      await _saveAllSystemData();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ All data saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Wait a moment for user to see the success message
      await Future.delayed(const Duration(seconds: 2));

      // Navigate to login page
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      // Close loading dialog if there's an error
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error saving data: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Save all system data
  Future<void> _saveAllSystemData() async {
    try {
      // Get instances of services
      final sitesService = SitesDatabaseService.instance;
      final notesService = NotesLocalStorageService.instance;

      // Save sites data
      final sites = await sitesService.getAllSites();
      final sitesData = sites.map((site) => site.toJson()).toList();

      // Save bird counts data
      List<Map<String, dynamic>> allBirdCounts = [];
      for (final site in sites) {
        final counts = await sitesService.getBirdCountsForSite(site.name);
        allBirdCounts.addAll(counts.map((count) => count.toJson()));
      }

      // Save notes data
      final notes = await notesService.getAllNotes();
      final notesData = notes.map((note) => note.toJson()).toList();

      // Save additional data to SharedPreferences for backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_backup_timestamp', DateTime.now().toIso8601String());
      await prefs.setString('backup_sites_count', sites.length.toString());
      await prefs.setString('backup_bird_counts_count', allBirdCounts.length.toString());
      await prefs.setString('backup_notes_count', notes.length.toString());

    } catch (e) {
      print('Error saving system data: $e');
      rethrow;
    }
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Sites';
      case 1:
        return 'Bird Counting';
      case 2:
        return 'Notes';
      default:
        return 'Avicast';
    }
  }
} 