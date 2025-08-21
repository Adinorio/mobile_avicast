import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _loadingController;
  late Animation<double> _logoAnimation;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Loading animation controller
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Logo fade-in and scale animation
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));
    
    // Loading rotation animation
    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.linear,
    ));
    
    // Start animations
    _logoController.forward();
    _loadingController.repeat();
    
    // Navigate to next screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // Light blue
              Color(0xFFB0E0E6), // Powder blue
              Colors.white,
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top section with logo and app name
              Expanded(
                flex: 3,
                child: Center(
                  child: FadeTransition(
                    opacity: _logoAnimation,
                    child: ScaleTransition(
                      scale: _logoAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                          // AVICAST Logo (Bird in circle)
                          Container(
                            width: 80,
                            height: 80,
                decoration: BoxDecoration(
                              color: const Color(0xFF87CEEB),
                              shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                              Icons.flutter_dash, // Bird icon
                  color: Colors.white,
                              size: 50,
                ),
              ),
                          const SizedBox(height: 20),
            
            // App Name
                          const Text(
                            'AVICAST',
                            style: TextStyle(
                              fontSize: 32,
                  fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                              letterSpacing: 2.0,
              ),
            ),
            
                          // Subtitle
                          const Text(
                            'FIELD TOOL',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF7F8C8D),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            
              // Loading section
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Loading dots animation
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: AnimatedBuilder(
                        animation: _loadingAnimation,
                        builder: (context, child) {
                          return Stack(
                            children: List.generate(10, (index) {
                              final angle = (index * 36) * (3.14159 / 180);
                              final radius = 50.0;
                              final x = radius * cos(angle);
                              final y = radius * sin(angle);
                              
                              final colorIndex = (index + (_loadingAnimation.value * 10).round()) % 10;
                              final colors = [
                                const Color(0xFFE0F2F1), // Light teal
                                const Color(0xFFB2DFDB), // Light teal
                                const Color(0xFF80CBC4), // Teal
                                const Color(0xFF4DB6AC), // Teal
                                const Color(0xFF26A69A), // Teal
                                const Color(0xFF00897B), // Teal
                                const Color(0xFF00796B), // Dark teal
                                const Color(0xFF00695C), // Dark teal
                                const Color(0xFF004D40), // Dark teal
                                const Color(0xFF00251A), // Very dark teal
                              ];
                              
                              return Positioned(
                                left: 60 + x,
                                top: 60 + y,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: colors[colorIndex],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }),
                          );
                        },
              ),
            ),
            
                    const SizedBox(height: 30),
            
                    // Loading text
                    const Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF7F8C8D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom section with logo and app name (smaller)
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: FadeTransition(
                    opacity: _logoAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Small logo
                        Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Color(0xFF87CEEB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.flutter_dash,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        
                        // App name (smaller)
                        const Text(
                          'AVICAST',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
} 