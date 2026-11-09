import 'package:flutter/material.dart';
import '../../models/saved_route.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/currency_format.dart';
import '../../widgets/notification_banner.dart';
import '../../widgets/ride_icon_badge.dart';
import '../history/log_trip_screen.dart';
import 'add_edit_route_screen.dart';

class RouteDetailScreen extends StatelessWidget {
  final SavedRoute route;

  const RouteDetailScreen({super.key, required this.route});

  void _handleReverseRoute(BuildContext context) {
    final state = AppStateScope.of(context);
    final returnRoute = state.reverseRoute(route);
    NotificationBanner.showSuccess(context, 'Created return route: "${returnRoute.name}"');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => RouteDetailScreen(route: returnRoute),
      ),
    );
  }

  Future<void> _handleDeleteRoute(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Route',
      message: 'Are you sure you want to delete "${route.name}"? Previously logged trips using this route will remain in your history.',
      confirmText: 'Delete Route',
    );

    if (confirmed && context.mounted) {
      final state = AppStateScope.of(context);
      state.deleteRoute(route.id);
      NotificationBanner.showSuccess(context, 'Route deleted');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    // Fetch latest version from state in case it was edited
    final currentRoute = state.getRouteById(route.id) ?? route;
    final isStudentDiscount = state.studentDiscount;
    final regularTotal = currentRoute.regularTotal;
    final discountedTotal = currentRoute.getDiscountedTotal(isStudentDiscount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Route Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.deepGreen),
            tooltip: 'Edit route',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEditRouteScreen(routeToEdit: currentRoute),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.coral),
            tooltip: 'Delete route',
            onPressed: () => _handleDeleteRoute(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () => _handleReverseRoute(context),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                  label: const Text('Reverse route'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LogTripScreen(initialRoute: currentRoute),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: const Text('Log this trip'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: AppColors.mainGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Outdated warning card if applicable
              if (currentRoute.faresOutdated)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.coralLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.coral.withAlpha(60)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: AppColors.coral, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Fares may be outdated. Tap edit to update with current driver rates.',
                          style: TextStyle(
                            color: AppColors.coral,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Overview Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route name
                    Text(
                      currentRoute.name,
                      style: const TextStyle(
                        color: AppColors.deepGreen,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // From -> To
                    Row(
                      children: [
                        const Icon(Icons.place_rounded, color: AppColors.mainGreen, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          currentRoute.from,
                          style: const TextStyle(
                            color: AppColors.deepGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.arrow_forward_rounded, color: AppColors.textMuted, size: 16),
                        ),
                        const Icon(Icons.flag_rounded, color: AppColors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          currentRoute.to,
                          style: const TextStyle(
                            color: AppColors.deepGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: AppColors.borderLight, height: 1),
                    const SizedBox(height: 16),

                    // Fare Breakdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Commute Fare',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  CurrencyFormat.format(discountedTotal),
                                  style: const TextStyle(
                                    color: AppColors.deepGreen,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                if (isStudentDiscount) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    CurrencyFormat.format(regularTotal),
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 16,
                                      decoration: TextDecoration.lineThrough,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),

                        if (currentRoute.travelTimeMinutes != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.amberLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.schedule_rounded, color: AppColors.amber, size: 15),
                                const SizedBox(width: 5),
                                Text(
                                  '${currentRoute.travelTimeMinutes} mins',
                                  style: const TextStyle(
                                    color: AppColors.amber,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    if (isStudentDiscount) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.lightMint,
                          borderRadius: BorderRadius.circular(8),
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
                              color: AppColors.mainGreen,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${state.discountBadgeText} active',
                              style: const TextStyle(
                                color: AppColors.mainGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Ride Steps Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Commute Timeline',
                    style: TextStyle(
                      color: AppColors.deepGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${currentRoute.steps.length} rides',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Vertical Ride Timeline
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: currentRoute.steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    final isLast = index == currentRoute.steps.length - 1;
                    final stepRegularFare = step.fare;
                    final stepDiscountedFare = currentRoute.getStepFare(step, isStudentDiscount);

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Timeline indicator column
                          Column(
                            children: [
                              RideIconBadge(rideType: step.rideType, size: 38, iconSize: 20),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    color: AppColors.mintAccent,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 14),

                          // Step detail
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        step.rideType,
                                        style: const TextStyle(
                                          color: AppColors.deepGreen,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            CurrencyFormat.format(stepDiscountedFare),
                                            style: const TextStyle(
                                              color: AppColors.deepGreen,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                            ),
                                          ),
                                          if (isStudentDiscount)
                                            Text(
                                              CurrencyFormat.format(stepRegularFare),
                                              style: const TextStyle(
                                                color: AppColors.textMuted,
                                                fontSize: 11,
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.transfer_within_a_station_rounded, size: 14, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Board at: ${step.boardingPoint}',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Last updated notice
              Center(
                child: Text(
                  'Fares last updated: ${currentRoute.faresUpdated}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
