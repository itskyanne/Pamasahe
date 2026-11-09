import 'package:flutter/material.dart';
import '../../models/saved_route.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../widgets/currency_format.dart';
import 'route_detail_screen.dart';

class CompareRoutesScreen extends StatefulWidget {
  const CompareRoutesScreen({super.key});

  @override
  State<CompareRoutesScreen> createState() => _CompareRoutesScreenState();
}

class _CompareRoutesScreenState extends State<CompareRoutesScreen> {
  final Set<int> _selectedRouteIds = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final allRoutes = state.routes;
    final isStudentDiscount = state.studentDiscount;

    if (allRoutes.length < 2) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Compare Routes'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
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
                    Icons.compare_arrows_rounded,
                    color: AppColors.mainGreen,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Save at least two routes to compare.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.deepGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add alternate commutes with different vehicles or paths to find the cheapest and fastest.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // By default, if nothing is manually selected, compare all routes
    final List<SavedRoute> comparedRoutes = _selectedRouteIds.isEmpty
        ? allRoutes
        : allRoutes.where((r) => _selectedRouteIds.contains(r.id)).toList();

    // Calculate cheapest & fastest
    double minCost = double.infinity;
    int minTime = 999999;

    for (final r in comparedRoutes) {
      final cost = r.getDiscountedTotal(isStudentDiscount);
      if (cost < minCost) minCost = cost;
      if (r.travelTimeMinutes != null && r.travelTimeMinutes! < minTime) {
        minTime = r.travelTimeMinutes!;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Compare Routes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select routes to compare',
                style: TextStyle(
                  color: AppColors.deepGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              // Route selection filter chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allRoutes.map((route) {
                  final isSelected = _selectedRouteIds.isEmpty || _selectedRouteIds.contains(route.id);

                  return FilterChip(
                    label: Text(route.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (_selectedRouteIds.isEmpty) {
                          _selectedRouteIds.addAll(allRoutes.map((r) => r.id));
                        }
                        if (selected) {
                          _selectedRouteIds.add(route.id);
                        } else {
                          if (_selectedRouteIds.length > 2) {
                            _selectedRouteIds.remove(route.id);
                          } else {
                            // Keep at least 2 selected
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Keep at least 2 routes selected to compare.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      });
                    },
                    selectedColor: AppColors.lightMint,
                    checkmarkColor: AppColors.mainGreen,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppColors.mainGreen : AppColors.border,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.deepGreen : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Side-by-side / Comparison Cards
              ...comparedRoutes.map((route) {
                final cost = route.getDiscountedTotal(isStudentDiscount);
                final isCheapest = comparedRoutes.length > 1 && (cost - minCost).abs() < 0.01;
                final isFastest = comparedRoutes.length > 1 && route.travelTimeMinutes != null && route.travelTimeMinutes == minTime;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isCheapest
                          ? AppColors.mainGreen.withAlpha(120)
                          : (isFastest ? AppColors.amber.withAlpha(120) : AppColors.border),
                      width: (isCheapest || isFastest) ? 1.5 : 1,
                    ),
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
                      // Badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Wrap(
                            spacing: 6,
                            children: [
                              if (isCheapest)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.mainGreen,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.savings_outlined, color: Colors.white, size: 12),
                                      SizedBox(width: 4),
                                      Text(
                                        'Cheapest',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (isFastest)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.amber,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.bolt_rounded, color: Colors.white, size: 12),
                                      SizedBox(width: 4),
                                      Text(
                                        'Fastest',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // From -> To
                      Row(
                        children: [
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

                      const SizedBox(height: 16),
                      const Divider(color: AppColors.borderLight, height: 1),
                      const SizedBox(height: 14),

                      // Metrics row: Cost vs Time
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMint,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Discounted Cost',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    CurrencyFormat.format(cost),
                                    style: const TextStyle(
                                      color: AppColors.deepGreen,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (isStudentDiscount)
                                    Text(
                                      'Reg: ${CurrencyFormat.format(route.regularTotal)}',
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMint,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Est. Travel Time',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    route.travelTimeMinutes != null
                                        ? '${route.travelTimeMinutes} mins'
                                        : 'Not set',
                                    style: const TextStyle(
                                      color: AppColors.deepGreen,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '${route.steps.length} transfers/rides',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // View Detail link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RouteDetailScreen(route: route),
                              ),
                            );
                          },
                          child: const Text(
                            'Inspect Route Details →',
                            style: TextStyle(
                              color: AppColors.mainGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
