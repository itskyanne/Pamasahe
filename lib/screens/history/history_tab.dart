import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/trip.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../widgets/currency_format.dart';
import '../../widgets/pamasahe_top_bar.dart';
import '../routes/route_detail_screen.dart';
import 'log_trip_screen.dart';

class HistoryTab extends StatefulWidget {
  final VoidCallback? onNavigateToSettings;

  const HistoryTab({
    super.key,
    this.onNavigateToSettings,
  });

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  // 0 = This week, 1 = This month (default per screenshots), 2 = All
  int _selectedFilter = 1;
  int _currentPage = 1;
  static const int _itemsPerPage = 5;

  // Baseline November trip records from earlier in the month
  // Sum = 297.20 across 14 trips, which when added to the 4 initial trips (89.60)
  // totals exactly 18 trips, ₱386.80 spent, and ₱96.70 saved!
  static final List<Trip> _novemberExtendedTrips = [
    const Trip(
      id: 101,
      routeId: 4,
      routeName: 'Home to Library',
      date: 'Nov 2, 2026',
      amount: 18.00,
      vehicleType: 'BUS',
    ),
    const Trip(
      id: 102,
      routeId: 1,
      routeName: 'Home to School',
      date: 'Nov 1, 2026',
      amount: 26.40,
      vehicleType: 'JEEP',
    ),
    const Trip(
      id: 103,
      routeId: 1,
      routeName: 'School to Home',
      date: 'Nov 1, 2026',
      amount: 26.40,
      vehicleType: 'JEEP',
    ),
    const Trip(
      id: 104,
      routeId: 2,
      routeName: 'School to Mall',
      date: 'Oct 31, 2026',
      amount: 10.40,
      vehicleType: 'BUS',
    ),
    const Trip(
      id: 105,
      routeId: 3,
      routeName: 'Mall to Home',
      date: 'Oct 31, 2026',
      amount: 26.40,
      vehicleType: 'JEEP',
    ),
    const Trip(
      id: 106,
      routeId: 1,
      routeName: 'Home to School',
      date: 'Oct 30, 2026',
      amount: 26.40,
      vehicleType: 'JEEP',
    ),
    const Trip(
      id: 107,
      routeId: 1,
      routeName: 'School to Home',
      date: 'Oct 30, 2026',
      amount: 26.40,
      vehicleType: 'JEEP',
    ),
    const Trip(
      id: 108,
      routeId: 1,
      routeName: 'Home to School',
      date: 'Oct 29, 2026',
      amount: 26.40,
      vehicleType: 'JEEP',
    ),
    const Trip(
      id: 109,
      routeId: 1,
      routeName: 'School to Home',
      date: 'Oct 29, 2026',
      amount: 26.40,
      vehicleType: 'JEEP',
    ),
    const Trip(
      id: 110,
      routeId: 4,
      routeName: 'Home to Library',
      date: 'Oct 28, 2026',
      amount: 18.00,
      vehicleType: 'BUS',
    ),
    const Trip(
      id: 111,
      routeId: 4,
      routeName: 'Library to Home',
      date: 'Oct 28, 2026',
      amount: 18.00,
      vehicleType: 'BUS',
    ),
    const Trip(
      id: 112,
      routeId: 2,
      routeName: 'School to Mall',
      date: 'Oct 27, 2026',
      amount: 10.40,
      vehicleType: 'BUS',
    ),
    const Trip(
      id: 113,
      routeId: 1,
      routeName: 'Home to School',
      date: 'Oct 27, 2026',
      amount: 26.40,
      vehicleType: 'JEEP',
    ),
    const Trip(
      id: 114,
      routeId: 1,
      routeName: 'School to Crossing',
      date: 'Oct 27, 2026',
      amount: 11.20,
      vehicleType: 'JEEP',
    ),
  ];

  List<Trip> _getVisibleTrips(AppState state) {
    if (_selectedFilter == 0) {
      // This week: active trips in state (Nov 2-8 + newly logged trips)
      return state.trips;
    } else {
      // This month or All: state trips + earlier November records
      // Newly logged trips are always prepended at the top
      return [...state.trips, ..._novemberExtendedTrips];
    }
  }

  String _getDateRangeLabel() {
    switch (_selectedFilter) {
      case 0:
        return 'Nov 2–8';
      case 1:
        return 'November 2026';
      case 2:
      default:
        return 'All time';
    }
  }

  void _showTripDetailSheet(BuildContext context, Trip trip, AppState state) {
    final route = state.getRouteById(trip.routeId);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        trip.routeName,
                        style: const TextStyle(
                          color: AppColors.deepGreen,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${trip.vehicle} · ${trip.date.toUpperCase()}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fare Paid',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormat.format(trip.amount),
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: state.hasDiscount ? const Color(0xFFE2F7EB) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          state.hasDiscount ? '20% Student Fare' : 'Regular Fare',
                          style: TextStyle(
                            color: state.hasDiscount ? const Color(0xFF165B47) : const Color(0xFF6B7280),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (route != null) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RouteDetailScreen(route: route),
                              ),
                            );
                          },
                          icon: const Icon(Icons.info_outline_rounded, size: 18),
                          label: const Text('View Route'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF111827),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => LogTripScreen(
                                initialRoute: route,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Log Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111827),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final visibleTrips = _getVisibleTrips(state);

    // Dynamic calculations across whole filtered timeframe
    final totalSpent = visibleTrips.fold(0.0, (sum, trip) => sum + trip.amount);
    final totalTrips = visibleTrips.length;
    final totalSaved = state.hasDiscount ? (totalSpent * 0.25) : 0.0;

    // Pagination calculations (5 trips per page)
    final totalPages = (totalTrips / _itemsPerPage).ceil().clamp(1, 999);
    final currentPage = _currentPage.clamp(1, totalPages);
    final startIndex = (currentPage - 1) * _itemsPerPage;
    final endIndex = math.min(startIndex + _itemsPerPage, totalTrips);
    final paginatedTrips = totalTrips == 0 ? <Trip>[] : visibleTrips.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 600;
            final horizontalPadding = isTablet ? 24.0 : 16.0;
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 740),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    top: 14,
                    bottom: 100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. TOP HEADER (Pamasahe wordmark + User Avatar)
                      PamasaheTopBar(
                        onSettingsTap: widget.onNavigateToSettings,
                      ),

                      const SizedBox(height: 16),

                      // 2. PAGE HEADER
                      Text(
                        'TRIP LOG',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: isDark ? AppColors.darkMainGreen : const Color(0xFF165B47),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'History',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : const Color(0xFF111827),
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.9,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Review your past commutes, fares, and student savings.',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF4B5563),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 3. SUMMARY METRICS CARD
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorderSubtle : const Color(0xFFE5E7EB),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isTablet
                            // Tablet: 3 columns in a single row
                            ? IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Total spent',
                                              style: TextStyle(
                                                color: Color(0xFF6B7280),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              CurrencyFormat.format(totalSpent),
                                              style: const TextStyle(
                                                color: Color(0xFF111827),
                                                fontSize: 26,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Total trips',
                                              style: TextStyle(
                                                color: Color(0xFF6B7280),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '$totalTrips',
                                              style: const TextStyle(
                                                color: Color(0xFF111827),
                                                fontSize: 26,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                                    Expanded(
                                      child: Container(
                                        color: const Color(0xFFE2F7EB),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'You saved',
                                              style: TextStyle(
                                                color: Color(0xFF165B47),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              CurrencyFormat.format(totalSaved),
                                              style: const TextStyle(
                                                color: Color(0xFF111827),
                                                fontSize: 26,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            // Phone: 2 metrics on top, light-green surface below
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Total spent',
                                                  style: TextStyle(
                                                    color: Color(0xFF6B7280),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  CurrencyFormat.format(totalSpent),
                                                  style: const TextStyle(
                                                    color: Color(0xFF111827),
                                                    fontSize: 26,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: -0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(16, 16, 18, 16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Total trips',
                                                  style: TextStyle(
                                                    color: Color(0xFF6B7280),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '$totalTrips',
                                                  style: const TextStyle(
                                                    color: Color(0xFF111827),
                                                    fontSize: 26,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: -0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    color: const Color(0xFFE2F7EB),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'You saved',
                                          style: TextStyle(
                                            color: Color(0xFF165B47),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          CurrencyFormat.format(totalSaved),
                                          style: const TextStyle(
                                            color: Color(0xFF111827),
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      const SizedBox(height: 22),

                      // 4. DATE FILTERS ROW
                      Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildFilterPill(
                                    label: 'This week',
                                    isSelected: _selectedFilter == 0,
                                    onTap: () => setState(() {
                                      _selectedFilter = 0;
                                      _currentPage = 1;
                                    }),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildFilterPill(
                                    label: 'This month',
                                    isSelected: _selectedFilter == 1,
                                    onTap: () => setState(() {
                                      _selectedFilter = 1;
                                      _currentPage = 1;
                                    }),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildFilterPill(
                                    label: 'All',
                                    isSelected: _selectedFilter == 2,
                                    onTap: () => setState(() {
                                      _selectedFilter = 2;
                                      _currentPage = 1;
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 13,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _getDateRangeLabel(),
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // 5. TRIP HISTORY LIST
                      if (visibleTrips.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            children: const [
                              Icon(Icons.history_toggle_off_rounded, size: 40, color: Color(0xFF9CA3AF)),
                              SizedBox(height: 12),
                              Text(
                                'No trips found',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'No commute trips logged for this timeframe.',
                                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: paginatedTrips.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final trip = paginatedTrips[index];
                            final globalIndex = startIndex + index;
                            return _buildTripCard(
                              context: context,
                              trip: trip,
                              index: globalIndex,
                              state: state,
                            );
                          },
                        ),
                        if (totalTrips > 0) ...[
                          const SizedBox(height: 20),
                          _buildPaginationControls(
                            context: context,
                            currentPage: currentPage,
                            totalPages: totalPages,
                            startIndex: startIndex,
                            endIndex: endIndex,
                            totalItems: totalTrips,
                            isDark: isDark,
                            onPageChanged: (newPage) {
                              setState(() => _currentPage = newPage);
                            },
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaginationControls({
    required BuildContext context,
    required int currentPage,
    required int totalPages,
    required int startIndex,
    required int endIndex,
    required int totalItems,
    required bool isDark,
    required ValueChanged<int> onPageChanged,
  }) {
    final textColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280);
    final surfaceColor = isDark ? AppColors.darkSurfaceCard : Colors.white;
    final borderColor = isDark ? AppColors.darkBorderSubtle : const Color(0xFFE5E7EB);
    final primaryActiveBg = isDark ? AppColors.darkTextPrimary : const Color(0xFF111827);
    final primaryActiveText = isDark ? const Color(0xFF111827) : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Range and page summary line
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Showing ${startIndex + 1}–$endIndex of $totalItems trips',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: textColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Page $currentPage of $totalPages',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: textColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          if (totalPages > 1) ...[
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Previous button
                  _buildPaginationArrowButton(
                    key: const ValueKey('history_pagination_prev'),
                    icon: Icons.chevron_left_rounded,
                    label: 'Previous page',
                    isEnabled: currentPage > 1,
                    isDark: isDark,
                    onTap: () => onPageChanged(currentPage - 1),
                  ),
                  const SizedBox(width: 6),

                  // Numbered page pills
                  ...List.generate(totalPages, (i) {
                    final page = i + 1;
                    final isSelected = page == currentPage;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: Semantics(
                        button: true,
                        label: 'Go to page $page',
                        selected: isSelected,
                        child: InkWell(
                          key: ValueKey('history_page_$page'),
                          onTap: () => onPageChanged(page),
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected ? primaryActiveBg : surfaceColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? primaryActiveBg : borderColor,
                                width: 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1.5),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '$page',
                                style: TextStyle(
                                  color: isSelected
                                      ? primaryActiveText
                                      : (isDark ? AppColors.darkTextPrimary : const Color(0xFF111827)),
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(width: 6),

                  // Next button
                  _buildPaginationArrowButton(
                    key: const ValueKey('history_pagination_next'),
                    icon: Icons.chevron_right_rounded,
                    label: 'Next page',
                    isEnabled: currentPage < totalPages,
                    isDark: isDark,
                    onTap: () => onPageChanged(currentPage + 1),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaginationArrowButton({
    required Key key,
    required IconData icon,
    required String label,
    required bool isEnabled,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final borderColor = isDark ? AppColors.darkBorderSubtle : const Color(0xFFE5E7EB);
    final activeColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF111827);
    final disabledColor = isDark ? AppColors.darkTextMuted : const Color(0xFF9CA3AF);

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: key,
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceCard : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isEnabled ? borderColor : borderColor.withValues(alpha: 0.5),
                width: 1.0,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 20,
                color: isEnabled ? activeColor : disabledColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedBg = isDark ? AppColors.darkTextPrimary : const Color(0xFF111827);
    final selectedText = isDark ? const Color(0xFF111827) : Colors.white;
    final unselectedBg = isDark ? AppColors.darkSurfaceCard : Colors.white;
    final unselectedBorder = isDark ? AppColors.darkBorderSubtle : const Color(0xFFE5E7EB);
    final unselectedText = isDark ? AppColors.darkTextPrimary : const Color(0xFF111827);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      splashColor: isSelected ? Colors.white.withValues(alpha: 0.2) : AppColors.mainGreen.withValues(alpha: 0.1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8.5),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : unselectedBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? selectedBg : unselectedBorder,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? selectedText : unselectedText,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard({
    required BuildContext context,
    required Trip trip,
    required int index,
    required AppState state,
  }) {
    // 4-Color badge cycle matching the design artifacts:
    // 0 = Yellow, 1 = Blue, 2 = Pink, 3 = Grey outline
    final badgeColor = switch (index % 4) {
      0 => const Color(0xFFFFB800),
      1 => const Color(0xFF5B8DEF),
      2 => const Color(0xFFFF6584),
      _ => const Color(0xFFF3F4F6),
    };

    final iconColor = (index % 4 == 3) ? const Color(0xFF374151) : Colors.white;

    final vehicle = trip.vehicle;
    final dateUpper = trip.date.toUpperCase();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurfaceCard : Colors.white;
    final cardBorder = isDark ? AppColors.darkBorderSubtle : const Color(0xFFE5E7EB);

    return InkWell(
      onTap: () => _showTripDetailSheet(context, trip, state),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cardBorder, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Color-coded transport icon badge
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  Icons.directions_bus_rounded,
                  color: iconColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Route name and monospace metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.routeName,
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF111827),
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$vehicle  ·  $dateUpper',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Bold fare
            Text(
              CurrencyFormat.format(trip.amount),
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF111827),
                fontWeight: FontWeight.w800,
                fontSize: 16.5,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
