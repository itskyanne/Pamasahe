import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/saved_route.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../widgets/currency_format.dart';
import '../history/log_trip_screen.dart';
import '../routes/route_detail_screen.dart';

class HomeTab extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;

  const HomeTab({
    super.key,
    this.onNavigateToTab,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // Period selection: 0 = This week, 1 = This month
  int _selectedPeriod = 0;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Magandang umaga!';
    } else if (hour < 18) {
      return 'Magandang hapon!';
    } else {
      return 'Magandang gabi!';
    }
  }

  String _getFormattedToday() {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final now = DateTime.now();
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    return '$dayName, $monthName ${now.day}';
  }

  String _getPeriodDateRange() {
    if (_selectedPeriod == 0) {
      return 'Nov 2 – 8, 2026';
    } else {
      return 'November 2026';
    }
  }

  void _openLogTrip(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LogTripScreen(),
      ),
    );
  }

  void _openRouteDetail(BuildContext context, SavedRoute? route) {
    if (route != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RouteDetailScreen(route: route),
        ),
      );
    } else {
      widget.onNavigateToTab?.call(1);
    }
  }

  String _cleanRouteName(String rawName) {
    return rawName.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
  }

  void _showSpendingBreakdownModal({
    required BuildContext context,
    required bool isWeekly,
    required double totalSpent,
    required double totalSaved,
    required double jeepneySpending,
    required double busSpending,
    required double otherSpending,
    required AppState state,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Spending Breakdown',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.deepGreen,
                          ),
                        ),
                        Text(
                          isWeekly ? 'November 2 – 8, 2026' : 'November 2026',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11.5,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildBreakdownItem(
                  icon: Icons.directions_bus_filled_rounded,
                  iconColor: const Color(0xFFFFB800),
                  label: 'Jeepney Commutes',
                  amount: jeepneySpending,
                  total: totalSpent,
                ),
                const SizedBox(height: 10),
                _buildBreakdownItem(
                  icon: Icons.directions_bus_rounded,
                  iconColor: const Color(0xFF4A80F0),
                  label: 'City & P2P Bus',
                  amount: busSpending,
                  total: totalSpent,
                ),
                const SizedBox(height: 10),
                _buildBreakdownItem(
                  icon: Icons.electric_rickshaw_rounded,
                  iconColor: const Color(0xFFFF6584),
                  label: 'Tricycle & Other',
                  amount: otherSpending,
                  total: totalSpent,
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE5E7EB), height: 1),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6F5E3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Concession Savings',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF135A45),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state.hasDiscount
                                ? '20% LTFRB discount applied'
                                : 'No concession discount active',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10.5,
                              color: Color(0xFF33705E),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        CurrencyFormat.format(totalSaved),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.deepGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBreakdownItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required double amount,
    required double total,
  }) {
    final pct = total > 0 ? (amount / total).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Text(
                CurrencyFormat.format(amount),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deepGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 4,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(iconColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    final isWeekly = _selectedPeriod == 0;
    final weeklySpending = state.weeklySpending;
    final monthlySpending = state.trips.fold(0.0, (sum, trip) => sum + trip.amount);
    final totalSpent = isWeekly ? weeklySpending : monthlySpending;

    final tripCount = state.trips.length;
    final avgFare = tripCount > 0 ? (totalSpent / tripCount) : 0.0;
    final totalSaved = state.hasDiscount ? totalSpent * 0.25 : 0.0;

    final budget = isWeekly ? state.weeklyBudget : state.monthlyBudget;
    final remainingBudget = (budget - totalSpent).clamp(0.0, budget);
    final isOnTrack = totalSpent <= budget;
    final budgetProgress = budget > 0 ? (totalSpent / budget).clamp(0.0, 1.0) : 0.0;

    // Transport category spending breakdowns
    final jeepneySpending = state.trips.fold(0.0, (sum, trip) {
      final nameLower = trip.routeName.toLowerCase();
      if (nameLower.contains('jeep') || (!nameLower.contains('bus') && !nameLower.contains('tricycle') && !nameLower.contains('trike'))) {
        return sum + trip.amount;
      }
      return sum;
    });

    final busSpending = state.trips.fold(0.0, (sum, trip) {
      if (trip.routeName.toLowerCase().contains('bus')) {
        return sum + trip.amount;
      }
      return sum;
    });

    final otherSpending = math.max(0.0, totalSpent - (jeepneySpending + busSpending));

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
      } else {
        mostFrequentRouteName = state.trips.first.routeName;
        mostFrequentCount = maxCount;
      }
    }

    // Chart Data
    final Map<String, double> chartData = isWeekly
        ? state.weeklySpendingByDay
        : {
            'W1': totalSpent * 0.45,
            'W2': totalSpent * 0.35,
            'W3': totalSpent * 0.20,
            'W4': 0.0,
          };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 600;
            final isWideScreen = constraints.maxWidth >= 720;
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

                  // 2. GREETING AREA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  _getFormattedToday().toUpperCase(),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    color: Color(0xFF5A726E),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: state.hasDiscount ? const Color(0xFFDDF3E8) : const Color(0xFFEAECE8),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: state.hasDiscount ? const Color(0xFF1F8A4C) : const Color(0xFF8DA39F),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        state.hasDiscount ? 'Student fare active' : 'Regular fare',
                                        style: TextStyle(
                                          color: state.hasDiscount ? const Color(0xFF0B3D3A) : const Color(0xFF5A726E),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _getGreeting(),
                              style: TextStyle(
                                color: const Color(0xFF111827),
                                fontSize: isTablet ? 30 : 27,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Saan ang biyahe natin ngayon?',
                              style: TextStyle(
                                color: Color(0xFF5A726E),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isTablet)
                        ElevatedButton.icon(
                          onPressed: () => _openLogTrip(context),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Log a trip', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(120, 42),
                            maximumSize: const Size(200, 48),
                            backgroundColor: const Color(0xFFFFC700),
                            foregroundColor: const Color(0xFF1E1E1E),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            elevation: 2,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 3. TIME-RANGE CONTROLS (This week vs This month)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _buildPeriodOption(0, 'This week')),
                        Expanded(child: _buildPeriodOption(1, 'This month')),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF5A726E)),
                        const SizedBox(width: 5),
                        Text(
                          _getPeriodDateRange(),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: Color(0xFF5A726E),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 4. QUICK STATISTICS (Responsive: 3 metrics)
                  _buildQuickStats(
                    isTablet: isTablet,
                    tripCount: tripCount,
                    avgFare: avgFare,
                    totalSaved: totalSaved,
                    isWeekly: isWeekly,
                  ),

                  const SizedBox(height: 16),

                  // 5. SPENDING CARD & ACTIVITY CHART
                  if (isWideScreen)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildSpendingCard(
                            context: context,
                            isWeekly: isWeekly,
                            totalSpent: totalSpent,
                            totalSaved: totalSaved,
                            budget: budget,
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
                          child: _buildActivityChart(
                            isWeekly: isWeekly,
                            chartData: chartData,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _buildSpendingCard(
                      context: context,
                      isWeekly: isWeekly,
                      totalSpent: totalSpent,
                      totalSaved: totalSaved,
                      budget: budget,
                      budgetProgress: budgetProgress,
                      jeepneySpending: jeepneySpending,
                      busSpending: busSpending,
                      otherSpending: otherSpending,
                      state: state,
                    ),
                    const SizedBox(height: 14),
                    _buildActivityChart(
                      isWeekly: isWeekly,
                      chartData: chartData,
                    ),
                  ],

                  // 6. MOBILE "LOG A TRIP" BUTTON (Full-width yellow pill below primary cards)
                  if (!isTablet) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _openLogTrip(context),
                        icon: const Icon(Icons.add_rounded, size: 22),
                        label: const Text(
                          'Log a trip',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC700),
                          foregroundColor: const Color(0xFF1E1E1E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 2,
                          shadowColor: const Color(0xFFFFC700).withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),

                  // 7. COMMUTE INSIGHTS (Smart summary)
                  _buildCommuteInsights(
                    context: context,
                    isTablet: isTablet,
                    mostFrequentRoute: mostFrequentRoute,
                    mostFrequentRouteName: mostFrequentRouteName,
                    mostFrequentCount: mostFrequentCount,
                    totalTrips: tripCount,
                    remainingBudget: remainingBudget,
                    isOnTrack: isOnTrack,
                  ),

                  const SizedBox(height: 24),

                  // 8. RECENT TRIPS LIST
                  _buildRecentTripsSection(
                    context: context,
                    state: state,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  Widget _buildPeriodOption(int index, String label) {
    final isSelected = _selectedPeriod == index;
    return InkWell(
      onTap: () {
        if (_selectedPeriod != index) {
          setState(() {
            _selectedPeriod = index;
          });
        }
      },
      borderRadius: BorderRadius.circular(17),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E1E1E) : Colors.transparent,
          borderRadius: BorderRadius.circular(17),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF4B5563),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats({
    required bool isTablet,
    required int tripCount,
    required double avgFare,
    required double totalSaved,
    required bool isWeekly,
  }) {
    final tripsCard = _buildMetricCard(
      label: 'Total trips',
      value: '$tripCount',
      subtitle: isWeekly ? 'logged this week' : 'logged this month',
    );

    final avgFareCard = _buildMetricCard(
      label: 'Average fare',
      value: CurrencyFormat.format(avgFare),
      subtitle: 'per commute',
    );

    final savingsCard = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFD6F5E3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBCEBD0), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Total saved',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF165B47),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'with student fare',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: Color(0xFF3B7362),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              CurrencyFormat.format(totalSaved),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.deepGreen,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );

    if (isTablet) {
      return Row(
        children: [
          Expanded(child: tripsCard),
          const SizedBox(width: 10),
          Expanded(child: avgFareCard),
          const SizedBox(width: 10),
          Expanded(child: savingsCard),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: tripsCard),
              const SizedBox(width: 10),
              Expanded(child: avgFareCard),
            ],
          ),
          const SizedBox(height: 10),
          savingsCard,
        ],
      );
    }
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5ECE8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5A726E),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: Color(0xFF8DA39F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingCard({
    required BuildContext context,
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B3D3A), Color(0xFF0E4743)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B3D3A).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isWeekly ? 'SPENT THIS WEEK' : 'SPENT THIS MONTH',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Color(0xFFD2E8E1),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
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
                  _showSpendingBreakdownModal(
                    context: context,
                    isWeekly: isWeekly,
                    totalSpent: totalSpent,
                    totalSaved: totalSaved,
                    jeepneySpending: jeepneySpending,
                    busSpending: busSpending,
                    otherSpending: otherSpending,
                    state: state,
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'View details',
                        style: TextStyle(
                          color: Color(0xFF98DFB6),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF98DFB6),
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            CurrencyFormat.format(totalSpent),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 6),

          // Concession discount badge pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: state.hasDiscount ? const Color(0xFF1F8A4C) : Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  state.hasDiscount ? Icons.verified_rounded : Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 11,
                ),
                const SizedBox(width: 4),
                Text(
                  state.hasDiscount ? '20% student discount' : 'Regular fare',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget used',
                style: const TextStyle(
                  color: Color(0xFFD2E8E1),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: budgetProgress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart({
    required bool isWeekly,
    required Map<String, double> chartData,
  }) {
    final maxVal = chartData.values.fold(0.0, (m, v) => math.max(m, v));
    final chartMax = maxVal > 0 ? maxVal : 50.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isWeekly ? 'Daily Commute Activity' : 'Weekly Commute Activity',
                  style: const TextStyle(
                    color: AppColors.deepGreen,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isWeekly ? 'Mon – Sun' : 'W1 – W4',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Color(0xFF5A726E),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.entries.map((entry) {
                final label = entry.key;
                final amount = entry.value;
                final fraction = (amount / chartMax).clamp(0.0, 1.0);
                final hasSpend = amount > 0;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        hasSpend ? '₱${amount.toStringAsFixed(0)}' : '–',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9,
                          fontWeight: hasSpend ? FontWeight.w700 : FontWeight.w400,
                          color: hasSpend ? AppColors.mainGreen : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Container(
                        width: 16,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 16,
                          height: math.max(6.0, 70 * fraction),
                          decoration: BoxDecoration(
                            gradient: hasSpend
                                ? const LinearGradient(
                                    colors: [Color(0xFF1F8A4C), Color(0xFF34D399)],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  )
                                : null,
                            color: hasSpend ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10.5,
                          fontWeight: hasSpend ? FontWeight.w700 : FontWeight.w500,
                          color: hasSpend ? AppColors.deepGreen : const Color(0xFF6B7280),
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

  Widget _buildCommuteInsights({
    required BuildContext context,
    required bool isTablet,
    required SavedRoute? mostFrequentRoute,
    required String mostFrequentRouteName,
    required int mostFrequentCount,
    required int totalTrips,
    required double remainingBudget,
    required bool isOnTrack,
  }) {
    final frequentCard = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5ECE8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openRouteDetail(context, mostFrequentRoute),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB800),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.route_outlined,
                color: Color(0xFF1E2825),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Most frequent route',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    mostFrequentRouteName,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$mostFrequentCount of $totalTrips trips',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Color(0xFF6B7280),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );

    final budgetRemainingCard = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5ECE8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6584),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Color(0xFF1E2825),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Budget remaining',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  CurrencyFormat.format(remainingBudget),
                  style: const TextStyle(
                    color: AppColors.deepGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isOnTrack ? "You're comfortably on track" : "Over budget limit",
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Color(0xFF6B7280),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
            decoration: BoxDecoration(
              color: isOnTrack ? const Color(0xFFD1F2DE) : const Color(0xFFFFE4E6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isOnTrack ? 'ON TRACK' : 'OVER BUDGET',
              style: TextStyle(
                fontFamily: 'monospace',
                color: isOnTrack ? const Color(0xFF168051) : const Color(0xFFDC2626),
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SMART SUMMARY',
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
          children: const [
            Flexible(
              child: Text(
                'Commute insights',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.deepGreen,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Updated today',
              style: TextStyle(
                fontFamily: 'monospace',
                color: Color(0xFF7A8B87),
                fontSize: 11.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isTablet)
          Row(
            children: [
              Expanded(child: frequentCard),
              const SizedBox(width: 12),
              Expanded(child: budgetRemainingCard),
            ],
          )
        else ...[
          frequentCard,
          const SizedBox(height: 12),
          budgetRemainingCard,
        ],
      ],
    );
  }

  Widget _buildRecentTripsSection({
    required BuildContext context,
    required AppState state,
  }) {
    final recentTrips = state.trips.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TRIP LOG',
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
                'Recent trips',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.deepGreen,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => widget.onNavigateToTab?.call(3),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'View all ${state.trips.length} trips',
                  style: const TextStyle(
                    color: AppColors.deepGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (recentTrips.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5ECE8)),
            ),
            child: const Center(
              child: Text(
                'No trips logged yet.',
                style: TextStyle(
                  color: Color(0xFF5A726E),
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          ...recentTrips.map((trip) {
            final savedRoute = state.getRouteById(trip.routeId);
            final nameLower = trip.routeName.toLowerCase();
            final isBus = nameLower.contains('bus');
            final isTricycle = nameLower.contains('trike') || nameLower.contains('tricycle');

            final badgeColor = isBus
                ? const Color(0xFF4A80F0)
                : (isTricycle ? const Color(0xFFFF6584) : const Color(0xFFFFB800));

            final iconData = isBus
                ? Icons.directions_bus_filled_rounded
                : (isTricycle ? Icons.electric_rickshaw_rounded : Icons.directions_bus_filled_rounded);

            final vehicleTag = isBus ? 'BUS' : (isTricycle ? 'TRIKE' : 'JEEP');
            final dateTag = trip.date.toUpperCase();
            final displayTitle = _cleanRouteName(trip.routeName);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5ECE8), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        iconData,
                        color: const Color(0xFF1E2825),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayTitle,
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$vehicleTag  ·  $dateTag',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: Color(0xFF6B7280),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormat.format(trip.amount),
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () => _openRouteDetail(context, savedRoute),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'View route',
                                  style: TextStyle(
                                    color: Color(0xFF1F8A4C),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF1F8A4C),
                                  size: 14,
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
            );
          }),
      ],
    );
  }
}
