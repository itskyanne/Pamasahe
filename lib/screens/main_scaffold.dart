import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'history/history_tab.dart';
import 'home/home_tab.dart';
import 'lines/lines_tab.dart';
import 'routes/routes_tab.dart';
import 'settings/settings_tab.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tabs = [
      HomeTab(onNavigateToTab: _navigateToTab),
      const RoutesTab(),
      const LinesTab(),
      const HistoryTab(),
      const SettingsTab(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 40 : 10),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: SizedBox(
                height: 68,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: _NavBarItem(
                        index: 0,
                        currentIndex: _currentIndex,
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        label: 'Home',
                        onTap: () => setState(() => _currentIndex = 0),
                      ),
                    ),
                    Expanded(
                      child: _NavBarItem(
                        index: 1,
                        currentIndex: _currentIndex,
                        icon: Icons.alt_route_outlined,
                        activeIcon: Icons.alt_route_rounded,
                        label: 'Routes',
                        onTap: () => setState(() => _currentIndex = 1),
                      ),
                    ),
                    Expanded(
                      child: _NavBarItem(
                        index: 2,
                        currentIndex: _currentIndex,
                        icon: Icons.directions_bus_outlined,
                        activeIcon: Icons.directions_bus_filled_rounded,
                        label: 'Lines',
                        onTap: () => setState(() => _currentIndex = 2),
                      ),
                    ),
                    Expanded(
                      child: _NavBarItem(
                        index: 3,
                        currentIndex: _currentIndex,
                        icon: Icons.history_outlined,
                        activeIcon: Icons.history_rounded,
                        label: 'History',
                        onTap: () => setState(() => _currentIndex = 3),
                      ),
                    ),
                    Expanded(
                      child: _NavBarItem(
                        index: 4,
                        currentIndex: _currentIndex,
                        icon: Icons.settings_outlined,
                        activeIcon: Icons.settings_rounded,
                        label: 'Settings',
                        onTap: () => setState(() => _currentIndex = 4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Spec:
    // Active destination uses dark background with white icon and text
    // Inactive destinations use white/transparent background with dark icon and text
    final activeBg = isDark ? const Color(0xFF1F8F55) : const Color(0xFF1E1E1E);
    final activeFg = Colors.white;
    final inactiveFg = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: Material(
        color: isSelected ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 20,
                  color: isSelected ? activeFg : inactiveFg,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? activeFg : inactiveFg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
