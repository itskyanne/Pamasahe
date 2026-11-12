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
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      HomeTab(onNavigateToTab: _onNavigateToTab),
      const RoutesTab(),
      const LinesTab(),
      const HistoryTab(),
      const SettingsTab(),
    ];
  }

  void _onNavigateToTab(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: ColoredBox(
        color: AppColors.background,
        child: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: _FloatingBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavigateToTab,
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
  _NavDestinationItem(
    icon: Icons.settings_outlined,
    label: 'Settings',
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
                  // Primary downward drop shadow casting below the nav bar
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                    spreadRadius: 1,
                  ),
                  // Ambient brand deep-green shadow for rich depth
                  BoxShadow(
                    color: AppColors.deepGreen.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                  // Crisp contact shadow directly below the bar edge
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
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
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.08),
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
    const activeColor = AppColors.deepGreen; // Color(0xFF0B3D3A)
    const inactiveColor = Color(0xFF223631);

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
                      color: activeColor.withValues(alpha: 0.35),
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
                color: isSelected ? Colors.white : inactiveColor,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : inactiveColor,
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
