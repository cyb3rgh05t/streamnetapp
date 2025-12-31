import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streamnet_tv/controllers/auth_controller.dart';
import 'package:streamnet_tv/screens/home_screen.dart';
import 'package:streamnet_tv/screens/login_screen.dart';
import 'package:streamnet_tv/utils/app_themes.dart';
import 'package:streamnet_tv/l10n/app_localizations.dart';

enum LoadingStep { userInfo, categories, liveChannels, movies, series }

class DataLoaderScreen extends StatefulWidget {
  const DataLoaderScreen({super.key});

  @override
  State<DataLoaderScreen> createState() => _DataLoaderScreenState();
}

class _DataLoaderScreenState extends State<DataLoaderScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  LoadingStep _currentStep = LoadingStep.userInfo;
  String? _errorMessage;
  bool _hasError = false;

  final Map<LoadingStep, IconData> stepIcons = {
    LoadingStep.userInfo: Icons.wifi,
    LoadingStep.categories: Icons.category,
    LoadingStep.liveChannels: Icons.live_tv,
    LoadingStep.movies: Icons.movie,
    LoadingStep.series: Icons.tv,
  };

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authController = Provider.of<AuthController>(context, listen: false);

    try {
      // Step 1: User Info
      await _updateStep(LoadingStep.userInfo, 0.2);
      await authController.loadUserInfo();

      // Step 2: Categories
      await _updateStep(LoadingStep.categories, 0.4);
      await authController.loadCategories();

      // Step 3: Live Channels
      await _updateStep(LoadingStep.liveChannels, 0.6);
      await authController.loadLiveChannels();

      // Step 4: Movies
      await _updateStep(LoadingStep.movies, 0.8);
      await authController.loadMovies();

      // Step 5: Series
      await _updateStep(LoadingStep.series, 1.0);
      await authController.loadSeries();

      // Complete
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _updateStep(LoadingStep step, double progress) async {
    if (!mounted) return;

    setState(() {
      _currentStep = step;
    });

    await _progressController.animateTo(
      progress,
      duration: const Duration(milliseconds: 500),
    );

    await Future.delayed(const Duration(milliseconds: 300));
  }

  String _getStepTitle(LoadingStep step, AppLocalizations? l10n) {
    switch (step) {
      case LoadingStep.userInfo:
        return l10n?.connecting ?? 'Connecting...';
      case LoadingStep.categories:
        return l10n?.preparingCategories ?? 'Loading categories...';
      case LoadingStep.liveChannels:
        return l10n?.preparingLiveStreams ?? 'Loading live channels...';
      case LoadingStep.movies:
        return l10n?.preparingMovies ?? 'Loading movies...';
      case LoadingStep.series:
        return l10n?.preparingSeries ?? 'Loading series...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: AppThemes.splashGradient,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Section - Logo
                _buildLogoSection(l10n),

                // Middle Section - Current Step
                _buildStepSection(l10n),

                // Bottom Section - Progress
                _buildProgressSection(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(AppLocalizations? l10n) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [AppThemes.primaryGold, AppThemes.buttonColor],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppThemes.primaryGold.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_circle_filled,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'StreamNet TV',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n?.loadingContent ?? 'Loading your content...',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStepSection(AppLocalizations? l10n) {
    if (_hasError) {
      return _buildErrorSection(l10n);
    }

    return Column(
      children: [
        // Wave Animation
        AnimatedBuilder(
          animation: _waveAnimation,
          builder: (context, child) {
            return SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer waves
                  for (int i = 0; i < 3; i++)
                    Transform.scale(
                      scale: 1 + (i * 0.3) + (_waveAnimation.value * 0.5),
                      child: Container(
                        width: 120 + (i * 20),
                        height: 120 + (i * 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppThemes.primaryGold.withOpacity(
                              (1 - _waveAnimation.value) * (0.3 - i * 0.1),
                            ),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  // Center icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppThemes.primaryGold, AppThemes.buttonColor],
                      ),
                    ),
                    child: Icon(
                      stepIcons[_currentStep],
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // Current Step Title
        Text(
          _getStepTitle(_currentStep, l10n),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 16),

        // Step Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: LoadingStep.values.map((step) {
            final isActive = step.index <= _currentStep.index;
            return Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isActive
                    ? AppThemes.primaryGold
                    : Colors.white.withOpacity(0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildErrorSection(AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            l10n?.errorOccurred ?? 'An error occurred',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemes.primaryGold,
            ),
            child: Text(l10n?.backToLogin ?? 'Back to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(AppLocalizations? l10n) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progressAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: const LinearGradient(
                          colors: [
                            AppThemes.primaryGold,
                            AppThemes.buttonColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${(_progressAnimation.value * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppThemes.primaryGold,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
