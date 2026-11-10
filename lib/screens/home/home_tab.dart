import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../state/app_scope.dart';
import '../../widgets/currency_format.dart';
import '../history/log_trip_screen.dart';
import '../routes/route_detail_screen.dart';

class HomeTab extends StatefulWidget {
  final void Function(int tabIndex)? onNavigateToTab;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Period-dependent metrics
    final isWeekly = _selectedPeriod == 0;
    final totalSpent = isWeekly ? state.weeklySpending : state.monthlySpending;
    final tripCount = isWeekly ? state.weeklyTripCount : state.monthlyTripCount;
    final avgFare = isWeekly ? state.averageWeeklyFare : state.averageMonthlyFare;
    final totalSaved = isWeekly ? state.weeklyStudentSavings : state.monthlyStudentSavings;
    final budget = isWeekly ? state.weeklyBudget : state.monthlyBudget;
    final remainingBudget = isWeekly ? state.remainingWeeklyBudget : state.remainingMonthlyBudget;
    final isOnTrack = isWeekly ? state.isWeeklyOnTrack : state.isMonthlyOnTrack;
    final budgetProgress = budget > 0 ? (totalSpent / budget).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101917) : const Color(0xFFF5F5F0),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 600;
            final isWideScreen = constraints.maxWidth >= 720;
            final horizontalPadding = isTablet ? 28.0 : 18.0;

            return Column(
              children: [
                // 1. COMPACT STICKY TOP APP BAR
                Container(
                  height: 56,
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF162320) : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? const Color(0xFF263935) : const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Pamasahe Brand Badge & Title
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F8F55),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.directions_bus_filled_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Pamasahe',
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                              fontSize: 18.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      // Circular User Avatar
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF263935) : const Color(0xFFEAF4F1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF34D399) : const Color(0xFF1F8F55),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'WP',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF34D399) : const Color(0xFF0E443C),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // SCROLLABLE DASHBOARD BODY
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2. GREETING SECTION
                        _buildGreetingSection(
                          context: context,
                          isTablet: isTablet,
                          isDark: isDark,
                          state: state,
                        ),

                        const SizedBox(height: 14),

                        // 3. PERIOD SELECTOR (This week vs This month)
                        _buildPeriodSelector(isDark: isDark),

                        const SizedBox(height: 14),

                        // 4. QUICK STATISTICS (3 metrics responsive)
                        _buildQuickStatistics(
                          isTablet: isTablet,
                          isDark: isDark,
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
                              // Spending Card (Left Column)
                              Expanded(
                                flex: 5,
                                child: _buildSpendingCard(
                                  context: context,
                                  isDark: isDark,
                                  isWeekly: isWeekly,
                                  totalSpent: totalSpent,
                                  totalSaved: totalSaved,
                                  budget: budget,
                                  budgetProgress: budgetProgress,
                                  state: state,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Activity Chart (Right Column)
                              Expanded(
                                flex: 5,
                                child: _buildActivityChart(
                                  isDark: isDark,
                                  isWeekly: isWeekly,
                                  state: state,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _buildSpendingCard(
                            context: context,
                            isDark: isDark,
                            isWeekly: isWeekly,
                            totalSpent: totalSpent,
                            totalSaved: totalSaved,
                            budget: budget,
                            budgetProgress: budgetProgress,
                            state: state,
                          ),
                          const SizedBox(height: 14),
                          _buildActivityChart(
                            isDark: isDark,
                            isWeekly: isWeekly,
                            state: state,
                          ),
                        ],

                        // 8. PRIMARY "LOG A TRIP" BUTTON (Below dashboard cards for thumb access on phones)
                        if (!isTablet) ...[
                          const SizedBox(height: 16),
                          _buildPhoneLogTripButton(context),
                        ],

                        const SizedBox(height: 16),

                        // 6. COMMUTE INSIGHTS (Most Frequent Route & Budget Remaining)
                        _buildCommuteInsights(
                          context: context,
                          isTablet: isTablet,
                          isDark: isDark,
                          isWeekly: isWeekly,
                          remainingBudget: remainingBudget,
                          isOnTrack: isOnTrack,
                          state: state,
                        ),

                        const SizedBox(height: 20),

                        // 7. RECENT TRIPS LIST
                        _buildRecentTripsSection(
                          context: context,
                          isDark: isDark,
                          state: state,
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // SECTION BUILDERS
  // ==========================================

  // 2. Greeting Section
  Widget _buildGreetingSection({
    required BuildContext context,
    required bool isTablet,
    required bool isDark,
    required AppState state,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date & Student Fare Pill
              Row(
                children: [
                  Text(
                    _getFormattedToday(),
                    style: TextStyle(
                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E3A32) : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF34D399) : const Color(0xFF1F8F55),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.school_rounded,
                          size: 11,
                          color: isDark ? const Color(0xFF34D399) : const Color(0xFF1F8F55),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          state.hasDiscount ? '${state.discountBadgeText} Active' : 'Regular Fare',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF34D399) : const Color(0xFF1F8F55),
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
              // Main Filipino Greeting
              Text(
                _getGreeting(),
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'Saan ang biyahe natin ngayon?',
                style: TextStyle(
                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Primary Log a Trip button on tablets
        if (isTablet)
          ElevatedButton.icon(
            onPressed: () => _openLogTrip(context),
            icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
            label: const Text('Log a trip', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F8F55),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
          ),
      ],
    );
  }

  // 3. Period Selector Segmented Control
  Widget _buildPeriodSelector({required bool isDark}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C2B27) : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPeriodOption(
                index: 0,
                label: 'This week',
                isDark: isDark,
              ),
              const SizedBox(width: 4),
              _buildPeriodOption(
                index: 1,
                label: 'This month',
                isDark: isDark,
              ),
            ],
          ),
        ),
        // Date Range Label
        Text(
          _getPeriodDateRange(),
          style: TextStyle(
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodOption({
    required int index,
    required String label,
    required bool isDark,
  }) {
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
          color: isSelected
              ? (isDark ? const Color(0xFF0E443C) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 50 : 20),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (isDark ? const Color(0xFF34D399) : const Color(0xFF1E1E1E))
                : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // 4. Quick Statistics (Responsive: 1 row on tablet, 2 cols + 1 full-width on phone)
  Widget _buildQuickStatistics({
    required bool isTablet,
    required bool isDark,
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
      isDark: isDark,
    );

    final avgFareCard = _buildStatCard(
      title: 'AVG FARE',
      value: CurrencyFormat.format(avgFare),
      unit: 'per trip',
      icon: Icons.confirmation_number_outlined,
      accentColor: const Color(0xFFFFC700),
      isDark: isDark,
    );

    final savingsCard = _buildStatCard(
      title: 'STUDENT SAVINGS',
      value: CurrencyFormat.format(totalSaved),
      unit: '20% LTFRB discount',
      icon: Icons.savings_outlined,
      accentColor: const Color(0xFF1F8F55),
      isDark: isDark,
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
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162320) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF263935) : const Color(0xFFE5E7EB),
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
                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(isDark ? 40 : 25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 13, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E1E1E),
              fontSize: 17.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            unit,
            style: TextStyle(
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 8. Large Primary "Log a Trip" Button for Phone Thumb Reach
  Widget _buildPhoneLogTripButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () => _openLogTrip(context),
        icon: const Icon(Icons.add_circle_outline_rounded, size: 19),
        label: const Text(
          'Log a trip',
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1F8F55),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
          shadowColor: const Color(0xFF1F8F55).withAlpha(80),
        ),
      ),
    );
  }

  // 5. Spending Card & Expandable Spending Details Panel
  Widget _buildSpendingCard({
    required BuildContext context,
    required bool isDark,
    required bool isWeekly,
    required double totalSpent,
    required double totalSaved,
    required double budget,
    required double budgetProgress,
    required AppState state,
  }) {
    final periodLabel = isWeekly ? 'Weekly' : 'Monthly';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0E443C), // Deep green signature card
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E443C).withAlpha(70),
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
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
                        Text(
                          isWeekly ? 'Spent this week' : 'Spent this month',
                          style: const TextStyle(
                            color: Color(0xFFD2E8E1),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    // "View details" Accordion Button
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
                          children: [
                            Text(
                              _showSpendingDetails ? 'Hide details' : 'View details',
                              style: const TextStyle(
                                color: Color(0xFF98DFB6),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              _showSpendingDetails
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: const Color(0xFF98DFB6),
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Large Amount Spent
                Text(
                  CurrencyFormat.format(totalSpent),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),

                const SizedBox(height: 5),

                // Discount Badge & Savings
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F8F55),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            state.discountType == DiscountType.senior
                                ? Icons.elderly_rounded
                                : (state.discountType == DiscountType.pwd
                                    ? Icons.accessible_rounded
                                    : Icons.school_rounded),
                            color: Colors.white,
                            size: 11,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            state.hasDiscount ? '${state.discountBadgeText} (-20%)' : 'Regular fare',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
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
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 14),

                // Budget Usage Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$periodLabel budget usage',
                      style: const TextStyle(
                        color: Color(0xFFD2E8E1),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
                    valueColor: AlwaysStoppedAnimation<Color>(
                      budgetProgress > 0.9 ? const Color(0xFFFF8AD8) : const Color(0xFF34D399),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Collapsible Spending Details Breakdown Panel
          if (_showSpendingDetails) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF09312B),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
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
                  _buildBreakdownRow('Jeepney', CurrencyFormat.format(state.jeepneySpending), Icons.airport_shuttle_rounded),
                  const SizedBox(height: 6),
                  _buildBreakdownRow('Bus', CurrencyFormat.format(state.busSpending), Icons.directions_bus_rounded),
                  const SizedBox(height: 6),
                  _buildBreakdownRow('Other transport', CurrencyFormat.format(state.otherSpending), Icons.commute_rounded),
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

  // 5. Activity Chart (Daily bars for weekly, Weekly bars for monthly)
  Widget _buildActivityChart({
    required bool isDark,
    required bool isWeekly,
    required AppState state,
  }) {
    final Map<String, double> chartData = isWeekly
        ? state.weeklySpendingByDay
        : state.monthlySpendingByWeek;

    final maxVal = chartData.values.fold(0.0, (m, v) => math.max(m, v));
    final chartMax = maxVal > 0 ? maxVal : 50.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162320) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF263935) : const Color(0xFFE5E7EB),
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
                isWeekly ? 'Daily Commute Activity' : 'Weekly Commute Activity',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                isWeekly ? 'Mon – Sun' : 'W1 – W4',
                style: TextStyle(
                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Activity Bars
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
                      // Amount label above bar or "-" empty state
                      Text(
                        hasSpend ? '₱${amount.toStringAsFixed(0)}' : '–',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: hasSpend ? FontWeight.w700 : FontWeight.w400,
                          color: hasSpend
                              ? (isDark ? const Color(0xFF34D399) : const Color(0xFF1F8F55))
                              : (isDark ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF)),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Bar Track
                      Container(
                        width: 15,
                        height: 70,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2E2A) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 15,
                          height: math.max(5.0, 70 * fraction),
                          decoration: BoxDecoration(
                            color: hasSpend
                                ? (isDark ? const Color(0xFF34D399) : const Color(0xFF1F8F55))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Day / Week Label
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: hasSpend ? FontWeight.w700 : FontWeight.w500,
                          color: hasSpend
                              ? (isDark ? Colors.white : const Color(0xFF1E1E1E))
                              : (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
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

  // 6. Commute Insights (Most Frequent Route & Budget Remaining)
  Widget _buildCommuteInsights({
    required BuildContext context,
    required bool isTablet,
    required bool isDark,
    required bool isWeekly,
    required double remainingBudget,
    required bool isOnTrack,
    required AppState state,
  }) {
    final mostFrequent = state.mostFrequentRoute;

    final frequentCard = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162320) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF263935) : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MOST FREQUENT ROUTE',
                style: TextStyle(
                  color: Color(0xFF5F8CFF),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              InkWell(
                onTap: () => widget.onNavigateToTab?.call(1), // Go to Routes Tab
                child: const Row(
                  children: [
                    Text(
                      'View routes',
                      style: TextStyle(
                        color: Color(0xFF5F8CFF),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_ios_rounded, size: 9, color: Color(0xFF5F8CFF)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            mostFrequent.routeName,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E1E1E),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${mostFrequent.count} ${mostFrequent.count == 1 ? 'trip logged' : 'trips logged'}',
            style: TextStyle(
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
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
        color: isDark ? const Color(0xFF162320) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF263935) : const Color(0xFFE5E7EB),
          width: 1,
        ),
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
                  color: Color(0xFF1F8F55),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isOnTrack
                      ? (isDark ? const Color(0xFF1E3A32) : const Color(0xFFE8F5E9))
                      : (isDark ? const Color(0xFF3E2323) : const Color(0xFFFFEBEE)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isOnTrack ? 'On track' : 'Exceeded',
                  style: TextStyle(
                    color: isOnTrack ? const Color(0xFF1F8F55) : const Color(0xFFC8412B),
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
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E1E1E),
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isOnTrack
                ? 'Within ${isWeekly ? 'weekly' : 'monthly'} budget'
                : 'Over budget limit',
            style: TextStyle(
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
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

  // 7. Recent Trips Section
  Widget _buildRecentTripsSection({
    required BuildContext context,
    required bool isDark,
    required AppState state,
  }) {
    final recentTrips = state.trips.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent trips',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            InkWell(
              onTap: () => widget.onNavigateToTab?.call(3), // Go to History Tab
              child: const Row(
                children: [
                  Text(
                    'View all trips',
                    style: TextStyle(
                      color: Color(0xFF1F8F55),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(Icons.arrow_forward_rounded, size: 12, color: Color(0xFF1F8F55)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (recentTrips.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162320) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? const Color(0xFF263935) : const Color(0xFFE5E7EB),
              ),
            ),
            child: const Center(
              child: Text(
                'No trips logged yet.',
                style: TextStyle(
                  color: Color(0xFF6B7280),
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
                    color: isDark ? const Color(0xFF162320) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF263935) : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Transport Type Icon Badge
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isBus
                              ? const Color(0xFF0E443C)
                              : (isTricycle
                                  ? const Color(0xFFFFC700).withAlpha(40)
                                  : (isDark ? const Color(0xFF1E3A32) : const Color(0xFFEAF4F1))),
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
                                  : (isDark ? const Color(0xFF34D399) : const Color(0xFF1F8F55))),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Route Name & Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.routeName,
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              trip.date,
                              style: TextStyle(
                                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Fare and View route affordance
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormat.format(trip.amount),
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          if (savedRoute != null)
                            const Text(
                              'View route →',
                              style: TextStyle(
                                color: Color(0xFF1F8F55),
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
