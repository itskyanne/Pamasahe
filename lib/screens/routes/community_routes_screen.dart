import 'package:flutter/material.dart';
import '../../models/route_step.dart';
import '../../models/saved_route.dart';
import '../../services/supabase_service.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../widgets/currency_format.dart';
import '../../widgets/notification_banner.dart';

class CommunityRoutesScreen extends StatefulWidget {
  const CommunityRoutesScreen({super.key});

  @override
  State<CommunityRoutesScreen> createState() => _CommunityRoutesScreenState();
}

class _CommunityRoutesScreenState extends State<CommunityRoutesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _communityRoutes = [];

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
  }

  Future<void> _fetchRoutes() async {
    setState(() => _isLoading = true);
    final data = await SupabaseService().getCommunityRoutes();
    if (mounted) {
      setState(() {
        _communityRoutes = data;
        _isLoading = false;
      });
    }
  }

  void _importRoute(BuildContext context, AppState state, Map<String, dynamic> raw) {
    final stepsRaw = raw['steps'] as List<dynamic>? ?? [];
    final steps = stepsRaw.asMap().entries.map((entry) {
      final s = entry.value as Map<String, dynamic>;
      return RouteStep(
        id: 500 + entry.key,
        rideType: s['ride_type'] ?? 'Jeepney',
        boardingPoint: s['boarding_point'] ?? '',
        fare: (s['fare'] as num?)?.toDouble() ?? 13.0,
      );
    }).toList();

    final newRoute = SavedRoute(
      id: 999, // Will be auto-assigned by AppState
      name: raw['name'] ?? 'Imported Route',
      from: raw['from'] ?? 'Origin',
      to: raw['to'] ?? 'Destination',
      travelTimeMinutes: raw['travel_minutes'] ?? 30,
      steps: steps,
      faresUpdated: 'Nov 20, 2026',
    );

    state.addRoute(newRoute);

    NotificationBanner.showSuccess(
      context,
      'Imported "${newRoute.name}" to your personal routes!',
    );
  }

  void _showPublishDialog(BuildContext context, AppState state) {
    if (state.routes.isEmpty) {
      NotificationBanner.showError(context, 'You have no saved routes to share yet.');
      return;
    }

    SavedRoute selectedRoute = state.routes.first;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Share Route to Community',
                        style: TextStyle(
                          color: AppColors.deepGreen,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Select one of your regular commute routes to publish to fellow Davao commuters via Supabase:',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<SavedRoute>(
                    initialValue: selectedRoute,
                    isExpanded: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    items: state.routes.map((r) {
                      return DropdownMenuItem<SavedRoute>(
                        value: r,
                        child: Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedRoute = val);
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      final success = await SupabaseService().publishRouteToCommunity(
                        route: selectedRoute,
                        authorName: '${state.userName} (Student)',
                      );
                      if (context.mounted && success) {
                        NotificationBanner.showSuccess(
                          context,
                          'Published "${selectedRoute.name}" to Community Routes!',
                        );
                        _fetchRoutes();
                      }
                    },
                    icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 18),
                    label: const Text('Publish to Community', style: TextStyle(fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.deepGreen, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Community Routes',
          style: TextStyle(
            color: AppColors.deepGreen,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _showPublishDialog(context, state),
            icon: const Icon(Icons.share_rounded, size: 16, color: AppColors.mainGreen),
            label: const Text(
              'Share Mine',
              style: TextStyle(color: AppColors.mainGreen, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.mainGreen))
          : RefreshIndicator(
              color: AppColors.mainGreen,
              onRefresh: _fetchRoutes,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  // COMMUNITY HEADER BANNER
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF165B47), Color(0xFF0D3D2E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.hub_rounded, color: Color(0xFF86EFAC), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'SUPABASE CLOUD NETWORK',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                color: Color(0xFF86EFAC),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Davao Commuter Community',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Explore tested commute paths submitted by fellow students. Import any route into your personal notebook with 1 tap.',
                          style: TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_communityRoutes.length} Popular Routes',
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.bolt_rounded, size: 14, color: AppColors.amber),
                          SizedBox(width: 4),
                          Text(
                            'Live Cloud Feed',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // LIST OF COMMUNITY ROUTES
                  ..._communityRoutes.map((r) {
                    final steps = r['steps'] as List<dynamic>? ?? [];
                    final double totalFare = steps.fold(0.0, (sum, s) => sum + ((s['fare'] as num?)?.toDouble() ?? 0.0));
                    final double studentFare = totalFare * 0.80;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.mainGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.alt_route_rounded, color: AppColors.mainGreen, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r['name'] ?? 'Commute Route',
                                      style: const TextStyle(
                                        color: Color(0xFF111827),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Shared by ${r['author'] ?? 'Student'}',
                                      style: const TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.favorite_rounded, size: 14, color: Color(0xFFEF4444)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${r['likes'] ?? 0}',
                                    style: const TextStyle(
                                      color: Color(0xFF4B5563),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ORIGIN & DESTINATION
                          Row(
                            children: [
                              const Icon(Icons.trip_origin_rounded, size: 13, color: AppColors.mainGreen),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'From: ${r['from']}',
                                  style: const TextStyle(color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 13, color: Color(0xFFEF4444)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'To: ${r['to']}',
                                  style: const TextStyle(color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // STEPS PILLS
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: steps.map((s) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${s['ride_type']} (₱${(s['fare'] as num).toStringAsFixed(0)})',
                                  style: const TextStyle(
                                    color: Color(0xFF4B5563),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 14),

                          const Divider(height: 1, color: Color(0xFFF3F4F6)),

                          const SizedBox(height: 12),

                          // FARES & IMPORT BUTTON
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '20% Student: ${CurrencyFormat.format(studentFare)}',
                                    style: const TextStyle(
                                      color: AppColors.mainGreen,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'Regular: ${CurrencyFormat.format(totalFare)} · ~${r['travel_minutes']} mins',
                                    style: const TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _importRoute(context, state, r),
                                icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                                label: const Text('Import', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.mainGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
