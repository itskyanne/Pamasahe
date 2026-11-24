import 'dart:ui';
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
  int _previousIndex = 0;
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      HomeTab(onNavigateToTab: _onNavigateToTab),
      RoutesTab(onNavigateToSettings: () => _onNavigateToTab(4)),
      LinesTab(onNavigateToSettings: () => _onNavigateToTab(4)),
      HistoryTab(onNavigateToSettings: () => _onNavigateToTab(4)),
      SettingsTab(
        onNavigateToTab: _onNavigateToTab,
        onBack: _onBackFromSettings,
      ),
    ];
  }

  void _onNavigateToTab(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_currentIndex != index) {
      if (index == 4 && _currentIndex != 4) {
        _previousIndex = _currentIndex;
      }
      setState(() => _currentIndex = index);
    }
  }

  void _onBackFromSettings() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _currentIndex = (_previousIndex >= 0 && _previousIndex < 4) ? _previousIndex : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return PopScope(
      canPop: _currentIndex != 4,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex == 4) {
          _onBackFromSettings();
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        extendBody: true,
        body: ColoredBox(
          color: bgColor,
          child: IndexedStack(
            index: _currentIndex,
            children: _tabs,
          ),
        ),
        bottomNavigationBar: _FloatingBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onNavigateToTab,
        ),
      ),
    );
  }
}

class _NavDestinationItem {
  final IconData icon;
  final String label;

  const _NavDestinationItem({
    required this.icon,
    required this.label,
  });
}

const List<_NavDestinationItem> _destinations = [
  _NavDestinationItem(
    icon: Icons.home_outlined,
    label: 'Home',
  ),
  _NavDestinationItem(
    icon: Icons.route_outlined,
    label: 'Routes',
  ),
  _NavDestinationItem(
    icon: Icons.directions_bus_outlined,
    label: 'Lines',
  ),
  _NavDestinationItem(
    icon: Icons.access_time_outlined,
    label: 'History',
  ),
];

class _FloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 740),
            child: Container(
              height: 66,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: (isDark ? AppColors.darkMainGreen : AppColors.deepGreen).withValues(alpha: isDark ? 0.08 : 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceCard.withValues(alpha: 0.92)
                          : Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorderSubtle
                            : Colors.black.withValues(alpha: 0.08),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: List.generate(_destinations.length, (index) {
                        final destination = _destinations[index];
                        final isSelected = index == currentIndex;

                        return Expanded(
                          child: _NavBarItem(
                            key: ValueKey('nav_item_${destination.label.toLowerCase()}'),
                            icon: destination.icon,
                            label: destination.label,
                            isSelected: isSelected,
                            onTap: () => onTap(index),
                          ),
                        );
                      }),
                    ),
                  ),
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
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.darkMainGreen : AppColors.deepGreen;
    final activeTextColor = isDark ? const Color(0xFF0B0D10) : Colors.white;
    final inactiveColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF4B5563);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: isSelected
            ? Colors.white.withValues(alpha: 0.15)
            : activeColor.withValues(alpha: 0.12),
        highlightColor: isSelected
            ? Colors.white.withValues(alpha: 0.1)
            : AppColors.lightMint.withValues(alpha: 0.5),
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: isDark ? 0.25 : 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                icon,
                size: 21,
                color: isSelected ? activeTextColor : inactiveColor,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? activeTextColor : inactiveColor,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
