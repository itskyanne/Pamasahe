import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
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
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    return '$dayName, $monthName ${now.day}';
  }

  String _getPeriodDateRange() {
    if (_selectedPeriod == 0) {
      return 'Nov 3 – Nov 9, 2026';
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

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    // Period calculations
    final isWeekly = _selectedPeriod == 0;
    final weeklySpending = state.weeklySpending;
    final monthlySpending = state.trips.fold(0.0, (sum, trip) => sum + trip.amount);
    final totalSpent = isWeekly ? weeklySpending : monthlySpending;

    final tripCount = state.trips.length;
    final avgFare = tripCount > 0 ? (totalSpent / tripCount) : 0.0;
    final totalSaved = state.hasDiscount ? totalSpent * 0.25 : 0.0;

    const weeklyBudget = 250.00;
    const monthlyBudget = 1000.00;
    final budget = isWeekly ? weeklyBudget : monthlyBudget;
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
    String mostFrequentRouteName = 'No routes yet';
    int mostFrequentCount = 0;
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
      mostFrequentRouteName = matched?.name ?? state.trips.firstWhere((t) => t.routeId == bestRouteId).routeName;
      mostFrequentCount = maxCount;
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 600;
            final isWideScreen = constraints.maxWidth >= 720;
            final horizontalPadding = isTablet ? 24.0 : 16.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. TOP HEADER (Pamasahe Brand Title + User Avatar)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.mainGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.directions_bus_filled_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Pamasahe',
                            style: TextStyle(
                              color: AppColors.deepGreen,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.lightMint,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.mainGreen, width: 1.5),
                        ),
                        child: const Center(
                          child: Text(
                            'WP',
                            style: TextStyle(
                              color: AppColors.deepGreen,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 2. GREETING SECTION
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
                                  _getFormattedToday(),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceMint,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.mainGreen, width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.school_rounded,
                                        size: 11,
                                        color: AppColors.mainGreen,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        state.hasDiscount ? '${state.discountBadgeText} Active' : 'Regular Fare',
                                        style: const TextStyle(
                                          color: AppColors.deepGreen,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getGreeting(),
                              style: TextStyle(
                                color: AppColors.deepGreen,
                                fontSize: isTablet ? 24 : 21,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 1),
                            const Text(
                              'Saan ang biyahe natin ngayon?',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isTablet)
                        ElevatedButton.icon(
                          onPressed: () => _openLogTrip(context),
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                          label: const Text('Log a trip', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 3. PERIOD SELECTOR (This week vs This month)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildPeriodOption(0, 'This week'),
                            const SizedBox(width: 4),
                            _buildPeriodOption(1, 'This month'),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Text(
                          _getPeriodDateRange(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 4. QUICK STATISTICS (3 metrics responsive)
                  _buildQuickStats(
                    isTablet: isTablet,
                    tripCount: tripCount,
                    avgFare: avgFare,
                    totalSaved: totalSaved,
                  ),

                  const SizedBox(height: 16),

                  // 5. SPENDING & ACTIVITY DASHBOARD
                  if (isWideScreen)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildSpendingCard(
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

                  // 8. PRIMARY "LOG A TRIP" BUTTON (Below dashboard cards for thumb reach on phones)
                  if (!isTablet) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _openLogTrip(context),
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                        label: const Text(
                          'Log a trip',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                          shadowColor: AppColors.mainGreen.withAlpha(80),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // 6. COMMUTE INSIGHTS (Most Frequent Route & Budget Remaining)
                  _buildCommuteInsights(
                    isTablet: isTablet,
                    isWeekly: isWeekly,
                    mostFrequentRouteName: mostFrequentRouteName,
                    mostFrequentCount: mostFrequentCount,
                    remainingBudget: remainingBudget,
                    isOnTrack: isOnTrack,
                  ),

                  const SizedBox(height: 20),

                  // 7. RECENT TRIPS LIST
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
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.deepGreen : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
  }) {
    final tripsCard = _buildStatCard(
      title: 'TOTAL TRIPS',
      value: '$tripCount',
      unit: tripCount == 1 ? 'trip' : 'trips',
      icon: Icons.directions_bus_rounded,
      accentColor: const Color(0xFF5F8CFF),
    );

    final avgFareCard = _buildStatCard(
      title: 'AVG FARE',
      value: CurrencyFormat.format(avgFare),
      unit: 'per trip',
      icon: Icons.confirmation_number_outlined,
      accentColor: const Color(0xFFFFC700),
    );

    final savingsCard = _buildStatCard(
      title: 'TOTAL SAVED',
      value: CurrencyFormat.format(totalSaved),
      unit: 'with student fare',
      icon: Icons.savings_outlined,
      accentColor: AppColors.mainGreen,
      isHighlighted: true,
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
          const SizedBox(height: 8),
          savingsCard,
        ],
      );
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color accentColor,
    bool isHighlighted = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFEAF4F1) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlighted ? const Color(0xFFBFE3D6) : AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isHighlighted ? const Color(0xFF0E443C) : AppColors.textSecondary,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 13, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.deepGreen,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            unit,
            style: TextStyle(
              color: isHighlighted ? const Color(0xFF0E443C).withAlpha(180) : AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

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
    final periodLabel = isWeekly ? 'Weekly' : 'Monthly';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.deepGreen,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepGreen.withAlpha(60),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(25),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              isWeekly ? 'SPENT THIS WEEK' : 'SPENT THIS MONTH',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
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
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _showSpendingDetails ? 'Hide details' : 'View details',
                              style: const TextStyle(
                                color: Color(0xFF98DFB6),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Icon(
                              _showSpendingDetails
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.chevron_right_rounded,
                              color: const Color(0xFF98DFB6),
                              size: 16,
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
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),

                const SizedBox(height: 8),

                // 20% discount checkmark pill & savings amount
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCDE8DE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF0E443C),
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              state.hasDiscount
                                  ? (state.discountType == DiscountType.senior
                                      ? '20% senior discount'
                                      : (state.discountType == DiscountType.pwd
                                          ? '20% PWD discount'
                                          : '20% student discount'))
                                  : 'Regular fare',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF0E443C),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.hasDiscount && totalSaved > 0)
                      Text(
                        'Saved ${CurrencyFormat.format(totalSaved)}',
                        style: const TextStyle(
                          color: Color(0xFF98DFB6),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '$periodLabel budget usage',
                        style: const TextStyle(
                          color: Color(0xFFD2E8E1),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${CurrencyFormat.format(totalSpent)} / ${CurrencyFormat.format(budget)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: budgetProgress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withAlpha(40),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
                  ),
                ),
              ],
            ),
          ),

          if (_showSpendingDetails) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF09312B),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SPENDING BREAKDOWN',
                    style: TextStyle(
                      color: Color(0xFF98DFB6),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBreakdownRow('Jeepney', CurrencyFormat.format(jeepneySpending), Icons.airport_shuttle_rounded),
                  const SizedBox(height: 6),
                  _buildBreakdownRow('Bus', CurrencyFormat.format(busSpending), Icons.directions_bus_rounded),
                  const SizedBox(height: 6),
                  _buildBreakdownRow('Other transport', CurrencyFormat.format(otherSpending), Icons.commute_rounded),
                  const Divider(color: Colors.white24, height: 16),
                  _buildBreakdownRow(
                    'Total Student Savings',
                    CurrencyFormat.format(totalSaved),
                    Icons.savings_rounded,
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
            Icon(icon, size: 13, color: isHighlight ? const Color(0xFF34D399) : const Color(0xFFD2E8E1)),
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
            color: isHighlight ? const Color(0xFF34D399) : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
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
                  color: AppColors.textSecondary,
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
                          height: math.max(5.0, 70 * fraction),
                          decoration: BoxDecoration(
                            color: hasSpend ? AppColors.mainGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: hasSpend ? FontWeight.w700 : FontWeight.w500,
                          color: hasSpend ? AppColors.deepGreen : AppColors.textSecondary,
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
    required bool isTablet,
    required bool isWeekly,
    required String mostFrequentRouteName,
    required int mostFrequentCount,
    required double remainingBudget,
    required bool isOnTrack,
  }) {
    final frequentCard = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MOST FREQUENT ROUTE',
                style: TextStyle(
                  color: Color(0xFF5F8CFF),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(Icons.directions_outlined, size: 14, color: Color(0xFF5F8CFF)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            mostFrequentRouteName,
            style: const TextStyle(
              color: AppColors.deepGreen,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '$mostFrequentCount ${mostFrequentCount == 1 ? 'trip logged' : 'trips logged'}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    final budgetRemainingCard = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BUDGET REMAINING',
                style: TextStyle(
                  color: AppColors.mainGreen,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isOnTrack ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isOnTrack ? 'On track' : 'Exceeded',
                  style: TextStyle(
                    color: isOnTrack ? AppColors.mainGreen : AppColors.coral,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyFormat.format(remainingBudget),
            style: const TextStyle(
              color: AppColors.deepGreen,
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isOnTrack
                ? 'Within ${isWeekly ? 'weekly' : 'monthly'} budget'
                : 'Over budget limit',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (isTablet) {
      return Row(
        children: [
          Expanded(child: frequentCard),
          const SizedBox(width: 10),
          Expanded(child: budgetRemainingCard),
        ],
      );
    } else {
      return Column(
        children: [
          frequentCard,
          const SizedBox(height: 10),
          budgetRemainingCard,
        ],
      );
    }
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
          'Recent trips',
          style: TextStyle(
            color: AppColors.deepGreen,
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),

        if (recentTrips.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text(
                'No trips logged yet.',
                style: TextStyle(
                  color: AppColors.textSecondary,
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

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  if (savedRoute != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RouteDetailScreen(route: savedRoute),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isBus
                              ? AppColors.deepGreen
                              : (isTricycle
                                  ? const Color(0xFFFFC700).withAlpha(40)
                                  : AppColors.lightMint),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isBus
                              ? Icons.directions_bus_filled_rounded
                              : (isTricycle
                                  ? Icons.electric_rickshaw_rounded
                                  : Icons.airport_shuttle_rounded),
                          color: isBus
                              ? Colors.white
                              : (isTricycle
                                  ? const Color(0xFFB8690A)
                                  : AppColors.mainGreen),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.routeName,
                              style: const TextStyle(
                                color: AppColors.deepGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              trip.date,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
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
                              color: AppColors.deepGreen,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          if (savedRoute != null)
                            const Text(
                              'View route →',
                              style: TextStyle(
                                color: AppColors.mainGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
