import 'package:flutter/material.dart';
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

  final List<Widget> _tabs = const [
    HomeTab(),
    RoutesTab(),
    LinesTab(),
    HistoryTab(),
    SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    const charcoal = Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Container(
                height: 70,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: charcoal, width: 1),
                    left: BorderSide(color: charcoal, width: 0.5),
                    right: BorderSide(color: charcoal, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _NavBarItem(
                        index: 0,
                        currentIndex: _currentIndex,
                        icon: Icons.home_outlined,
                        label: 'Home',
                        onTap: () => setState(() => _currentIndex = 0),
                      ),
                    ),
                    Expanded(
                      child: _NavBarItem(
                        index: 1,
                        currentIndex: _currentIndex,
                        icon: Icons.alt_route_rounded,
                        label: 'Routes',
                        onTap: () => setState(() => _currentIndex = 1),
                      ),
                    ),
                    Expanded(
                      child: _NavBarItem(
                        index: 2,
                        currentIndex: _currentIndex,
                        icon: Icons.directions_bus_outlined,
                        label: 'Lines',
                        onTap: () => setState(() => _currentIndex = 2),
                      ),
                    ),
                    Expanded(
                      child: _NavBarItem(
                        index: 3,
                        currentIndex: _currentIndex,
                        icon: Icons.access_time_rounded,
                        label: 'History',
                        onTap: () => setState(() => _currentIndex = 3),
                      ),
                    ),
                    Expanded(
                      child: _NavBarItem(
                        index: 4,
                        currentIndex: _currentIndex,
                        icon: Icons.settings_outlined,
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
  final String label;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    const charcoal = Color(0xFF1E1E1E);

    return Material(
      color: isSelected ? charcoal : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 21,
                color: isSelected ? Colors.white : charcoal,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : charcoal,
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
