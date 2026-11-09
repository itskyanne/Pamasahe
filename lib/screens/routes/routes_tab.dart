import 'package:flutter/material.dart';
import '../../models/saved_route.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../widgets/currency_format.dart';
import 'add_edit_route_screen.dart';
import 'compare_routes_screen.dart';
import 'route_detail_screen.dart';

class RoutesTab extends StatelessWidget {
  const RoutesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final routes = state.routes;
    final isStudentDiscount = state.studentDiscount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Routes'),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CompareRoutesScreen(),
                ),
              );
            },
            icon: const Icon(Icons.compare_arrows_rounded, color: AppColors.mainGreen, size: 20),
            label: const Text(
              'Compare',
              style: TextStyle(
                color: AppColors.mainGreen,
                fontWeight: FontWeight.w700,
                fontSize: 14,
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
              builder: (context) => const AddEditRouteScreen(),
            ),
          );
        },
        backgroundColor: AppColors.mainGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'New Route',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: routes.isEmpty
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
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.alt_route_rounded,
                          color: AppColors.mainGreen,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No saved routes yet',
                        style: TextStyle(
                          color: AppColors.deepGreen,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Save your daily commutes with their steps and fares to track them easily.',
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
                              builder: (context) => const AddEditRouteScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add your first route'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 46),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
                itemCount: routes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final route = routes[index];
                  return _RouteCard(
                    route: route,
                    isStudentDiscount: isStudentDiscount,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RouteDetailScreen(route: route),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final SavedRoute route;
  final bool isStudentDiscount;
  final VoidCallback onTap;

  const _RouteCard({
    required this.route,
    required this.isStudentDiscount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final regularTotal = route.regularTotal;
    final discountedTotal = route.getDiscountedTotal(isStudentDiscount);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Route name and Outdated badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    route.name,
                    style: const TextStyle(
                      color: AppColors.deepGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (route.faresOutdated)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.coralLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.coral.withAlpha(50)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.warning_amber_rounded, color: AppColors.coral, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Fares may be outdated',
                          style: TextStyle(
                            color: AppColors.coral,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // From -> To
            Row(
              children: [
                const Icon(Icons.place_outlined, color: AppColors.textSecondary, size: 14),
                const SizedBox(width: 4),
                Text(
                  route.from,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.arrow_forward_rounded, color: AppColors.textMuted, size: 14),
                ),
                const Icon(Icons.flag_outlined, color: AppColors.textSecondary, size: 14),
                const SizedBox(width: 4),
                Text(
                  route.to,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(color: AppColors.borderLight, height: 1),
            const SizedBox(height: 12),

            // Bottom row: Fare & Travel time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Fare column
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      CurrencyFormat.format(discountedTotal),
                      style: const TextStyle(
                        color: AppColors.deepGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (isStudentDiscount) ...[
                      const SizedBox(width: 6),
                      Text(
                        CurrencyFormat.format(regularTotal),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.lightMint,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '-20%',
                          style: TextStyle(
                            color: AppColors.mainGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Travel time badge and steps count
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMint,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.directions_rounded, color: AppColors.textSecondary, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            '${route.steps.length} ${route.steps.length == 1 ? 'ride' : 'rides'}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (route.travelTimeMinutes != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.amberLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule_rounded, color: AppColors.amber, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              '${route.travelTimeMinutes} mins',
                              style: const TextStyle(
                                color: AppColors.amber,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
