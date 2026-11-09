import 'package:flutter/material.dart';
import '../../models/trip.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/currency_format.dart';
import '../../widgets/notification_banner.dart';
import '../routes/route_detail_screen.dart';
import 'log_trip_screen.dart';
import 'spending_summary_screen.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  Future<void> _handleDeleteTrip(BuildContext context, Trip trip) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Trip Log',
      message: 'Remove this trip record of ${CurrencyFormat.format(trip.amount)} on ${trip.date}?',
      confirmText: 'Delete Log',
    );

    if (confirmed && context.mounted) {
      final state = AppStateScope.of(context);
      state.deleteTrip(trip.id);
      NotificationBanner.showSuccess(context, 'Trip log removed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final trips = state.trips; // already sorted newest first in state

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Trip History'),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SpendingSummaryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.bar_chart_rounded, color: AppColors.mainGreen, size: 20),
            label: const Text(
              'Spending Summary',
              style: TextStyle(
                color: AppColors.mainGreen,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LogTripScreen(),
            ),
          );
        },
        backgroundColor: AppColors.mainGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'Log Trip',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: trips.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.lightMint,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.history_rounded,
                          color: AppColors.textMuted,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No trips logged yet.',
                        style: TextStyle(
                          color: AppColors.deepGreen,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Whenever you take a commute, tap Log Trip to record what you paid and track your spending.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LogTripScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Log a trip now'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(180, 46),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
                itemCount: trips.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  final savedRoute = state.getRouteById(trip.routeId);

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(6),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMint,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.directions_bus_rounded,
                              color: AppColors.mainGreen,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip.routeName,
                                style: const TextStyle(
                                  color: AppColors.deepGreen,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    trip.date,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (savedRoute != null) ...[
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => RouteDetailScreen(route: savedRoute),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        '• Route info',
                                        style: TextStyle(
                                          color: AppColors.mainGreen,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
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
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textMuted),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Delete log',
                              onPressed: () => _handleDeleteTrip(context, trip),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
