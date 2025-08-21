import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/profile_page.dart';
import 'features/sites/presentation/pages/sites_page.dart';
import 'features/sites/presentation/pages/site_birds_page.dart';
import 'features/bird_counting/presentation/pages/counting_site_page.dart';
import 'features/bird_counting/presentation/pages/bird_counter_page.dart';
import 'features/notes/presentation/pages/note_page.dart';
import 'features/notes/presentation/pages/camera_page.dart';
import 'screens/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avicast Mobile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
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
          color: Color(0xFF87CEEB), // Light blue like in the second image
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
            
            // Bird icon (center) - Floating action button style
            Container(
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