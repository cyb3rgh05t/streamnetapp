import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:streamnet_tv/config/app_config.dart';
import 'package:streamnet_tv/controllers/auth_controller.dart';
import 'package:streamnet_tv/screens/login_screen.dart';
import 'package:streamnet_tv/screens/home_screen.dart';
import 'package:streamnet_tv/services/auth_service.dart';
import 'package:streamnet_tv/utils/app_themes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkAuthAndNavigate();
  }

  void _initAnimations() {
    // Logo fade and scale animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Pulse animation for the logo
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _logoController.forward();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animations to complete
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // Check if user is already logged in
    final isLoggedIn = await AuthService.isLoggedIn();
    debugPrint('SplashScreen: isLoggedIn = $isLoggedIn');

    if (!mounted) return;

    if (isLoggedIn) {
      debugPrint('SplashScreen: User is logged in, loading data...');
      // Load user data via AuthController
      try {
        final authController =
            Provider.of<AuthController>(context, listen: false);
        await authController.loadUserInfo();
        await authController.loadCategories();
        await authController.loadLiveChannels();
        await authController.loadMovies();
        await authController.loadSeries();
      } catch (e) {
        // If loading fails, redirect to login
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const LoginScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
        return;
      }

      if (!mounted) return;

      // Navigate to home screen
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      // Navigate to login screen
      debugPrint('SplashScreen: User NOT logged in, navigating to LoginScreen');
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppThemes.splashGradient,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Animated Logo
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _logoController,
                    _pulseController,
                  ]),
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value * _pulseAnimation.value,
                        child: _buildLogo(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // App Name
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    AppConfig.appName,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Slogan
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Your Premium IPTV Experience',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Loading Spinner
                const SpinKitWave(color: AppThemes.primaryGold, size: 40.0),

                const SizedBox(height: 16),

                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),

                const Spacer(),

                // Version
                Text(
                  'v${AppConfig.appVersion}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [AppThemes.primaryGold, AppThemes.buttonColor],
        ),
        boxShadow: [
          BoxShadow(
            color: AppThemes.primaryGold.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.play_circle_filled, size: 70, color: Colors.white),
      ),
    );
  }
}
