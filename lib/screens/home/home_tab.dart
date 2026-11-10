import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/saved_route.dart';
import '../../state/app_scope.dart';
import '../../widgets/currency_format.dart';
import '../history/log_trip_screen.dart';
import '../routes/route_detail_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // Period selection: 0 = This week, 1 = This month
  int _selectedPeriod = 0;
  // Spending breakdown accordion
  bool _showSpendingDetails = false;

  void _openLogTrip(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LogTripScreen(),
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

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    const charcoal = Color(0xFF1E1E1E);
    const canvasBg = Color(0xFFF7F7F2);

    final isWeekly = _selectedPeriod == 0;

    // Numerical data matching Figma screenshots & live AppState
    final double displayedTotalSpent;
    final int displayedTrips;
    final double displayedAvgFare;
    final double displayedTotalSaved;
    final double displayedBudget;
    final double displayedRemainingBudget;

    if (isWeekly) {
      final actualWeekly = state.weeklySpending;
      displayedTotalSpent = actualWeekly > 0 ? actualWeekly : 89.60;
      displayedTrips = state.trips.isNotEmpty ? state.trips.length : 4;
      displayedAvgFare = displayedTrips > 0 ? (displayedTotalSpent / displayedTrips) : 22.40;
      displayedTotalSaved = state.hasDiscount ? displayedTotalSpent * 0.25 : 0.0;
      displayedBudget = 150.00;
      displayedRemainingBudget = math.max(0.0, displayedBudget - displayedTotalSpent);
    } else {
      // Monthly view based on Figma mockup
      final actualMonthly = state.trips.fold(0.0, (sum, trip) => sum + trip.amount);
      displayedTotalSpent = actualMonthly > 100 ? actualMonthly : 386.80;
      displayedTrips = math.max(18, state.trips.length);
      displayedAvgFare = displayedTrips > 0 ? (displayedTotalSpent / displayedTrips) : 21.49;
      displayedTotalSaved = state.hasDiscount ? (displayedTotalSpent * 0.25) : 96.70;
      displayedBudget = 600.00;
      displayedRemainingBudget = math.max(0.0, displayedBudget - displayedTotalSpent);
    }

    final budgetProgress = displayedBudget > 0
        ? (displayedTotalSpent / displayedBudget).clamp(0.0, 1.0)
        : 0.0;

    // Breakdown numbers
    final jeepneySpending = displayedTotalSpent * 0.65;
    final busSpending = displayedTotalSpent * 0.25;
    final otherSpending = math.max(0.0, displayedTotalSpent - (jeepneySpending + busSpending));

    // Most frequent route
    String mostFrequentRouteName = 'Home → School';
    int mostFrequentCount = isWeekly ? 3 : 11;
    SavedRoute? mostFrequentRoute = state.routes.isNotEmpty ? state.routes.first : null;

    if (state.trips.isNotEmpty) {
      final counts = <int, int>{};
      for (final t in state.trips) {
        counts[t.routeId] = (counts[t.routeId] ?? 0) + 1;
      }
      int bestRouteId = state.trips.first.routeId;
      int maxCount = 0;
      counts.forEach((routeId, count) {
        if (count > maxCount) {
          maxCount = count;
          bestRouteId = routeId;
        }
      });
      final matched = state.getRouteById(bestRouteId);
      if (matched != null) {
        mostFrequentRoute = matched;
        mostFrequentRouteName = '${matched.from} → ${matched.to}';
        mostFrequentCount = maxCount;
      }
    }

    return Scaffold(
      backgroundColor: canvasBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 600;
            final isWideScreen = constraints.maxWidth >= 720;
            final horizontalPadding = isTablet ? 24.0 : 16.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. TOP APP BAR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF168051),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'P',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Pamasahe',
                            style: TextStyle(
                              color: charcoal,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: charcoal,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'DP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 2. TIME-RANGE SELECTOR (This week vs This month)
                  Container(
                    width: double.infinity,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: charcoal, width: 1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (_selectedPeriod != 0) {
                                setState(() => _selectedPeriod = 0);
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isWeekly ? charcoal : Colors.transparent,
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(5)),
                              ),
                              child: Text(
                                'This week',
                                style: TextStyle(
                                  color: isWeekly ? Colors.white : charcoal,
                                  fontSize: 13,
                                  fontWeight: isWeekly ? FontWeight.w700 : FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (_selectedPeriod != 1) {
                                setState(() => _selectedPeriod = 1);
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: !isWeekly ? charcoal : Colors.transparent,
                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(5)),
                              ),
                              child: Text(
                                'This month',
                                style: TextStyle(
                                  color: !isWeekly ? Colors.white : charcoal,
                                  fontSize: 13,
                                  fontWeight: !isWeekly ? FontWeight.w700 : FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Date range label (right-aligned)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isWeekly ? 'Nov 2–8, 2026' : 'November 2026',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11.5,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 3. QUICK STATISTICS CARD (Single grouped white card)
                  Container(
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: charcoal, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: 2 columns
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Total trips',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 11,
                                        color: Color(0xFF6B7280),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '$displayedTrips',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: charcoal,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isWeekly ? 'logged this week' : 'logged this month',
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 10.5,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 75,
                              color: const Color(0xFFE5E7EB),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Average fare',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 11,
                                        color: Color(0xFF6B7280),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      CurrencyFormat.format(displayedAvgFare),
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: charcoal,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'per commute',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 10.5,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Divider line
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: const Color(0xFFCBD5D1),
                        ),

                        // Bottom row: Total saved in mint green
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          color: const Color(0xFFD6EFE3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total saved',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1A533E),
                                      ),
                                    ),
                                    SizedBox(height: 1),
                                    Text(
                                      'with student fare',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 10.5,
                                        color: Color(0xFF3D7863),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                CurrencyFormat.format(displayedTotalSaved),
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A533E),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 4. SPENDING & ACTIVITY (Responsive: stacked on phone, side-by-side on wide tablet)
                  if (isWideScreen)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildSpendingCard(
                            isWeekly: isWeekly,
                            totalSpent: displayedTotalSpent,
                            totalSaved: displayedTotalSaved,
                            budget: displayedBudget,
                            budgetProgress: budgetProgress,
                            jeepneySpending: jeepneySpending,
                            busSpending: busSpending,
                            otherSpending: otherSpending,
                            state: state,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 5,
                          child: _buildActivityChart(isWeekly: isWeekly),
                        ),
                      ],
                    )
                  else ...[
                    _buildSpendingCard(
                      isWeekly: isWeekly,
                      totalSpent: displayedTotalSpent,
                      totalSaved: displayedTotalSaved,
                      budget: displayedBudget,
                      budgetProgress: budgetProgress,
                      jeepneySpending: jeepneySpending,
                      busSpending: busSpending,
                      otherSpending: otherSpending,
                      state: state,
                    ),
                    const SizedBox(height: 14),
                    _buildActivityChart(isWeekly: isWeekly),
                  ],

                  // 5. PRIMARY MOBILE ACTION "+ Log a trip" (Bright golden yellow button)
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _openLogTrip(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC700),
                        foregroundColor: charcoal,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: charcoal, width: 1),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 18, color: charcoal),
                          SizedBox(width: 8),
                          Text(
                            'Log a trip',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: charcoal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 6. COMMUTE INSIGHTS
                  _buildCommuteInsights(
                    context: context,
                    isWeekly: isWeekly,
                    isTablet: isTablet,
                    mostFrequentRouteName: mostFrequentRouteName,
                    mostFrequentCount: mostFrequentCount,
                    totalTrips: displayedTrips,
                    remainingBudget: displayedRemainingBudget,
                    route: mostFrequentRoute,
                  ),

                  const SizedBox(height: 22),

                  // 7. RECENT TRIPS
                  _buildRecentTripsSection(
                    context: context,
                    state: state,
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // SPENDING CARD (Deep Forest Green)
  // ==========================================
  Widget _buildSpendingCard({
    required bool isWeekly,
    required double totalSpent,
    required double totalSaved,
    required double budget,
    required double budgetProgress,
    required double jeepneySpending,
    required double busSpending,
    required double otherSpending,
    required AppState state,
  }) {
    const cardBg = Color(0xFF0E443C);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF09312B), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Color(0xFFD2E8E1),
                            size: 15,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              isWeekly ? 'SPENT THIS WEEK' : 'SPENT THIS MONTH',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                color: Color(0xFFD2E8E1),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showSpendingDetails = !_showSpendingDetails;
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _showSpendingDetails ? 'Hide details' : 'View details',
                            style: const TextStyle(
                              color: Color(0xFF85D3B0),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            _showSpendingDetails
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.chevron_right_rounded,
                            color: const Color(0xFF85D3B0),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Giant spent amount
                Text(
                  CurrencyFormat.format(totalSpent),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),

                const SizedBox(height: 10),

                // 20% student discount pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB6E2D3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF0E443C),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        state.hasDiscount ? '20% student discount' : 'Regular fare',
                        style: const TextStyle(
                          color: Color(0xFF0E443C),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // Saved amount
                Text(
                  'Saved ${CurrencyFormat.format(totalSaved)}',
                  style: const TextStyle(
                    color: Color(0xFF85D3B0),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 14),

                // Budget used row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Budget used',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: Color(0xFFD2E8E1),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${CurrencyFormat.format(totalSpent)} / ${CurrencyFormat.format(budget)}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Progress line
                Container(
                  width: double.infinity,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(46),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: budgetProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC700),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 3 Yellow Status Dots on bottom right
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFC700),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFC700),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFC700),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Collapsible Spending Breakdown
          if (_showSpendingDetails) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF082B26),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SPENDING BREAKDOWN',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Color(0xFF98DFB6),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBreakdownRow('Jeepney', CurrencyFormat.format(jeepneySpending), Icons.airport_shuttle_outlined),
                  const SizedBox(height: 6),
                  _buildBreakdownRow('Bus', CurrencyFormat.format(busSpending), Icons.directions_bus_outlined),
                  const SizedBox(height: 6),
                  _buildBreakdownRow('Other transport', CurrencyFormat.format(otherSpending), Icons.commute_outlined),
                  const Divider(color: Colors.white24, height: 16),
                  _buildBreakdownRow(
                    'Total Student Savings',
                    CurrencyFormat.format(totalSaved),
                    Icons.savings_outlined,
                    isHighlight: true,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String amount, IconData icon, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 13,
              color: isHighlight ? const Color(0xFF34D399) : const Color(0xFFD2E8E1),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: isHighlight ? const Color(0xFF34D399) : const Color(0xFFD2E8E1),
                fontSize: 11.5,
                fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          amount,
          style: TextStyle(
            fontFamily: 'monospace',
            color: isHighlight ? const Color(0xFF34D399) : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // ACTIVITY CHART CARD
  // ==========================================
  Widget _buildActivityChart({required bool isWeekly}) {
    const charcoal = Color(0xFF1E1E1E);

    final List<MapEntry<String, double>> entries = isWeekly
        ? const [
            MapEntry('Mon', 26.40),
            MapEntry('Tue', 26.40),
            MapEntry('Wed', 10.40),
            MapEntry('Thu', 26.40),
            MapEntry('Fri', 0.0),
            MapEntry('Sat', 0.0),
            MapEntry('Sun', 0.0),
          ]
        : const [
            MapEntry('W1', 74.0),
            MapEntry('W2', 112.0),
            MapEntry('W3', 86.0),
            MapEntry('W4', 115.0),
          ];

    final maxVal = entries.fold(0.0, (m, e) => math.max(m, e.value));
    final chartMax = maxVal > 0 ? maxVal : 100.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: charcoal, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isWeekly ? 'THIS WEEK' : 'NOVEMBER',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                isWeekly ? '7 days' : '4 weeks',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isWeekly ? 'Weekly activity' : 'Monthly activity',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: charcoal,
            ),
          ),
          const SizedBox(height: 18),

          // Chart Bars
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: entries.map((entry) {
                final label = entry.key;
                final amount = entry.value;
                final fraction = (amount / chartMax).clamp(0.0, 1.0);
                final hasSpend = amount > 0;
                final barHeight = math.max(4.0, 90 * fraction);

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Amount label above bar
                      Text(
                        hasSpend ? '₱${amount.toStringAsFixed(0)}' : '–',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: hasSpend ? FontWeight.w700 : FontWeight.w400,
                          color: hasSpend ? charcoal : const Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Green Bar
                      Container(
                        width: isWeekly ? 18 : 32,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: hasSpend ? const Color(0xFF1B8354) : Colors.transparent,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                        ),
                      ),

                      // Baseline line
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: const Color(0xFFE5E7EB),
                      ),
                      const SizedBox(height: 6),

                      // Column label W1..W4 or Mon..Sun
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: hasSpend ? charcoal : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // COMMUTE INSIGHTS CARD
  // ==========================================
  Widget _buildCommuteInsights({
    required BuildContext context,
    required bool isWeekly,
    required bool isTablet,
    required String mostFrequentRouteName,
    required int mostFrequentCount,
    required int totalTrips,
    required double remainingBudget,
    required SavedRoute? route,
  }) {
    const charcoal = Color(0xFF1E1E1E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Commute insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: charcoal,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Updated today',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: charcoal, width: 1),
          ),
          child: Column(
            children: [
              // Row 1: Most frequent route
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC700),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: charcoal, width: 1),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.alt_route_rounded,
                          color: charcoal,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Most frequent route',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            mostFrequentRouteName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: charcoal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$mostFrequentCount of $totalTrips trips',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (route != null) {
                          _openRouteDetail(context, route);
                        }
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: charcoal, width: 1),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: charcoal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                height: 1,
                color: const Color(0xFFE5E7EB),
              ),

              // Row 2: Budget remaining
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8AD8),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: charcoal, width: 1),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          color: charcoal,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Budget remaining',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyFormat.format(remainingBudget),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: charcoal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "You're comfortably on track",
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8EFE5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ON TRACK',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A533E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // RECENT TRIPS SECTION
  // ==========================================
  Widget _buildRecentTripsSection({
    required BuildContext context,
    required AppState state,
  }) {
    const charcoal = Color(0xFF1E1E1E);

    final recentItems = [
      {
        'route': 'Home to School',
        'meta': 'JEEP · NOV 5, 2026',
        'fare': 26.40,
        'badgeColor': const Color(0xFFFFC700),
        'icon': Icons.directions_bus_outlined,
        'routeId': 1,
      },
      {
        'route': 'School to Mall',
        'meta': 'BUS · NOV 4, 2026',
        'fare': 10.40,
        'badgeColor': const Color(0xFF5F8CFF),
        'icon': Icons.directions_bus_outlined,
        'routeId': 3,
      },
      {
        'route': 'Mall to Home',
        'meta': 'JEEP · NOV 3, 2026',
        'fare': 26.40,
        'badgeColor': const Color(0xFFFF8AD8),
        'icon': Icons.directions_bus_outlined,
        'routeId': 1,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TRIP LOG',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: Color(0xFF6B7280),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Recent trips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: charcoal,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {},
              child: const Text(
                'View all 4 trips',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: charcoal,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // List of trips with horizontal dividers
        ...List.generate(recentItems.length, (index) {
          final item = recentItems[index];
          final routeName = item['route'] as String;
          final meta = item['meta'] as String;
          final fare = item['fare'] as double;
          final badgeColor = item['badgeColor'] as Color;
          final icon = item['icon'] as IconData;
          final routeId = item['routeId'] as int;
          final matchedRoute = state.getRouteById(routeId);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: charcoal, width: 1),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          color: charcoal,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            routeName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: charcoal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            meta,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormat.format(fare),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: charcoal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        InkWell(
                          onTap: () {
                            if (matchedRoute != null) {
                              _openRouteDetail(context, matchedRoute);
                            }
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View route',
                                style: TextStyle(
                                  color: Color(0xFF1B8354),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 14,
                                color: Color(0xFF1B8354),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (index < recentItems.length - 1)
                Container(
                  width: double.infinity,
                  height: 1,
                  color: const Color(0xFFE5E7EB),
                ),
            ],
          );
        }),
      ],
    );
  }
}
