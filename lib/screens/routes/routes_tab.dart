import 'package:flutter/material.dart';
import '../../models/saved_route.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../widgets/currency_format.dart';
import '../history/log_trip_screen.dart';
import 'add_edit_route_screen.dart';
import 'route_detail_screen.dart';

class RoutesTab extends StatefulWidget {
  const RoutesTab({super.key});

  @override
  State<RoutesTab> createState() => _RoutesTabState();
}

class _RoutesTabState extends State<RoutesTab> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (_searchQuery != query) {
      setState(() {
        _searchQuery = query;
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openAddRoute(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditRouteScreen(),
      ),
    );
  }

  void _openLogTripWithRoute(BuildContext context, SavedRoute route) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LogTripScreen(initialRoute: route),
      ),
    );
  }

  void _openRouteDetail(BuildContext context, SavedRoute route) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RouteDetailScreen(route: route),
      ),
    );
  }

  String _getPrimaryTransport(SavedRoute route) {
    if (route.steps.isEmpty) {
      final lower = route.name.toLowerCase();
      if (lower.contains('bus')) return 'Bus';
      if (lower.contains('trike') || lower.contains('tricycle')) return 'Trike';
      return 'Jeep';
    }
    final firstStepType = route.steps.first.rideType.toLowerCase();
    if (firstStepType.contains('bus')) return 'Bus';
    if (firstStepType.contains('trike') || firstStepType.contains('tricycle')) return 'Trike';
    if (firstStepType.contains('jeep')) return 'Jeep';

    final name = route.steps.first.rideType;
    return name.isNotEmpty ? name[0].toUpperCase() + name.substring(1) : 'Jeep';
  }

  String _getRouteUsageText(SavedRoute route, AppState state) {
    if (route.monthlyTrips != null) {
      return '${route.monthlyTrips} trips this month';
    }
    if (route.lastUsed != null) {
      return 'Last used ${route.lastUsed}';
    }

    final matchingTrips = state.trips
        .where((t) =>
            t.routeId == route.id ||
            (t.routeName.toLowerCase().contains(route.from.toLowerCase()) &&
                t.routeName.toLowerCase().contains(route.to.toLowerCase())))
        .toList();

    if (matchingTrips.isNotEmpty) {
      return '${matchingTrips.length} trips this month';
    }
    return 'Regular route';
  }

  List<SavedRoute> _filterRoutes(List<SavedRoute> routes) {
    if (_searchQuery.isEmpty) return routes;

    return routes.where((route) {
      final name = route.name.toLowerCase();
      final from = route.from.toLowerCase();
      final to = route.to.toLowerCase();
      final transport = _getPrimaryTransport(route).toLowerCase();
      final stepTypes = route.steps.map((s) => s.rideType.toLowerCase()).toList();

      return name.contains(_searchQuery) ||
          from.contains(_searchQuery) ||
          to.contains(_searchQuery) ||
          transport.contains(_searchQuery) ||
          stepTypes.any((t) => t.contains(_searchQuery));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final allRoutes = state.routes;
    final filteredRoutes = _filterRoutes(allRoutes);
    final hasDiscount = state.hasDiscount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 600;
            final horizontalPadding = isTablet ? 24.0 : 16.0;

            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                top: 14,
                bottom: 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. TOP HEADER (Minimal Pamasahe wordmark bar)
                  const Text(
                    'Pamasahe',
                    style: TextStyle(
                      color: AppColors.deepGreen,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. PAGE HEADER
                  const Text(
                    'YOUR COMMUTE',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Color(0xFF165B47),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 4),

                  if (isTablet)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Routes',
                                style: TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.9,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Save the trips you take most and log them again in one tap.',
                                style: TextStyle(
                                  color: Color(0xFF5A726E),
                                  fontSize: 14,
                                  height: 1.35,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildAddRouteButton(isTablet: true),
                      ],
                    )
                  else ...[
                    const Text(
                      'Routes',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.9,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Save the trips you take most and log them again in one tap.',
                      style: TextStyle(
                        color: Color(0xFF5A726E),
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAddRouteButton(isTablet: false),
                  ],

                  const SizedBox(height: 16),

                  // 3. ROUTE SEARCH
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFE5ECE8), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF6B7280),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Search saved routes',
                              hintStyle: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF6B7280)),
                            onPressed: () {
                              _searchController.clear();
                            },
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4. SAVED ROUTES SECTION HEADING
                  const Text(
                    'SAVED',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Color(0xFF8DA39F),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          'Your regular routes',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${filteredRoutes.length} ${filteredRoutes.length == 1 ? 'route' : 'routes'}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Color(0xFF6B7280),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 5. ROUTE CARDS (Responsive: 1-col on mobile, 2-col on tablet)
                  if (filteredRoutes.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFE5ECE8)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.search_off_rounded,
                              color: Color(0xFF6B7280),
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'No matching routes',
                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No saved route matches "$_searchQuery". Try another location or transport type.'
                                : 'No saved routes yet. Add your regular commutes to log them in one tap.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF5A726E),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          if (_searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            TextButton(
                              onPressed: () => _searchController.clear(),
                              child: const Text(
                                'Clear search',
                                style: TextStyle(
                                  color: Color(0xFF1F8A4C),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  else if (isTablet)
                    LayoutBuilder(
                      builder: (context, cardConstraints) {
                        final cardWidth = (cardConstraints.maxWidth - 14) / 2;
                        return Wrap(
                          spacing: 14,
                          runSpacing: 14,
                          children: List.generate(filteredRoutes.length, (index) {
                            final route = filteredRoutes[index];
                            return SizedBox(
                              width: cardWidth,
                              child: _RouteCard(
                                route: route,
                                colorIndex: index,
                                hasDiscount: hasDiscount,
                                usageText: _getRouteUsageText(route, state),
                                primaryTransport: _getPrimaryTransport(route),
                                onTap: () => _openRouteDetail(context, route),
                                onLogTrip: () => _openLogTripWithRoute(context, route),
                              ),
                            );
                          }),
                        );
                      },
                    )
                  else
                    ...List.generate(filteredRoutes.length, (index) {
                      final route = filteredRoutes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RouteCard(
                          route: route,
                          colorIndex: index,
                          hasDiscount: hasDiscount,
                          usageText: _getRouteUsageText(route, state),
                          primaryTransport: _getPrimaryTransport(route),
                          onTap: () => _openRouteDetail(context, route),
                          onLogTrip: () => _openLogTripWithRoute(context, route),
                        ),
                      );
                    }),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddRouteButton({required bool isTablet}) {
    if (isTablet) {
      return ElevatedButton.icon(
        onPressed: () => _openAddRoute(context),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text(
          'Add route',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          minimumSize: const Size(130, 42),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () => _openAddRoute(context),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text(
          'Add route',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final SavedRoute route;
  final int colorIndex;
  final bool hasDiscount;
  final String usageText;
  final String primaryTransport;
  final VoidCallback onTap;
  final VoidCallback onLogTrip;

  static const List<Color> _routeColors = [
    Color(0xFFFFB800), // Yellow
    Color(0xFF4A80F0), // Blue
    Color(0xFFFF6584), // Pink
    Color(0xFF1F8A4C), // Green
  ];

  const _RouteCard({
    required this.route,
    required this.colorIndex,
    required this.hasDiscount,
    required this.usageText,
    required this.primaryTransport,
    required this.onTap,
    required this.onLogTrip,
  });

  @override
  Widget build(BuildContext context) {
    final fare = route.getDiscountedTotal(hasDiscount);
    final cardColor = _routeColors[colorIndex % _routeColors.length];
    final travelTime = route.travelTimeMinutes != null ? '${route.travelTimeMinutes} min' : null;
    final transportPill = travelTime != null ? '$primaryTransport · $travelTime' : primaryTransport;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5ECE8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Visual Route Origin & Destination on Left, Route Squircle on Right
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Origin
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF1F8A4C),
                                    width: 2.2,
                                  ),
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  route.from,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827),
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          // Connecting vertical line
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Container(
                              width: 1.8,
                              height: 14,
                              color: const Color(0xFFD1D5DB),
                            ),
                          ),
                          // Destination
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  route.to,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827),
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Colored squircle container
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.route_outlined,
                          color: Color(0xFF1E2825),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Middle: Transport Pill & Usage Pill
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        transportPill,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        usageText,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(color: Color(0xFFF1F5F3), height: 1, thickness: 1),
                const SizedBox(height: 12),

                // Bottom row: Fare and Log this trip action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          CurrencyFormat.format(fare),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onLogTrip,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Log this trip',
                              style: TextStyle(
                                color: Color(0xFF1F8A4C),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF1F8A4C),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
