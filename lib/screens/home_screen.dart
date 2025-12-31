import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streamnet_tv/controllers/auth_controller.dart';
import 'package:streamnet_tv/controllers/home_controller.dart';
import 'package:streamnet_tv/screens/login_screen.dart';
import 'package:streamnet_tv/screens/settings_screen.dart';
import 'package:streamnet_tv/screens/live_tv_screen.dart';
import 'package:streamnet_tv/screens/movies_screen.dart';
import 'package:streamnet_tv/screens/series_screen.dart';
import 'package:streamnet_tv/screens/watch_history_screen.dart';
import 'package:streamnet_tv/screens/search_screen.dart';
import 'package:streamnet_tv/utils/app_themes.dart';
import 'package:streamnet_tv/utils/responsive_helper.dart';
import 'package:streamnet_tv/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  static const double _desktopBreakpoint = 900.0;

  final List<Widget> _pages = const [
    WatchHistoryScreen(),
    LiveTvScreen(),
    MoviesScreen(),
    SeriesScreen(),
    SettingsScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _desktopBreakpoint) {
          return _buildDesktopLayout(l10n);
        }
        return _buildMobileLayout(l10n);
      },
    );
  }

  Widget _buildMobileLayout(AppLocalizations? l10n) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(l10n),
    );
  }

  Widget _buildDesktopLayout(AppLocalizations? l10n) {
    return Scaffold(
      body: Row(
        children: [
          _buildNavigationRail(l10n),
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _pages),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(AppLocalizations? l10n) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onNavigationTap,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.history),
          label: l10n?.history ?? 'History',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.live_tv),
          label: l10n?.liveTV ?? 'Live TV',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.movie),
          label: l10n?.movies ?? 'Movies',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.tv),
          label: l10n?.series ?? 'Series',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: l10n?.settings ?? 'Settings',
        ),
      ],
    );
  }

  Widget _buildNavigationRail(AppLocalizations? l10n) {
    return NavigationRail(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      labelType: NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [AppThemes.primaryGold, AppThemes.buttonColor],
            ),
          ),
          child: const Icon(
            Icons.play_circle_filled,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.history_outlined),
          selectedIcon: const Icon(Icons.history),
          label: Text(l10n?.history ?? 'History'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.live_tv_outlined),
          selectedIcon: const Icon(Icons.live_tv),
          label: Text(l10n?.liveTV ?? 'Live TV'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.movie_outlined),
          selectedIcon: const Icon(Icons.movie),
          label: Text(l10n?.movies ?? 'Movies'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.tv_outlined),
          selectedIcon: const Icon(Icons.tv),
          label: Text(l10n?.series ?? 'Series'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: Text(l10n?.settings ?? 'Settings'),
        ),
      ],
    );
  }
}
