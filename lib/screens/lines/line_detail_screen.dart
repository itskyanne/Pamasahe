import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/ride_type.dart';
import '../../models/transport_line.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/currency_format.dart';
import '../../widgets/notification_banner.dart';
import '../../widgets/ride_icon_badge.dart';
import '../routes/add_edit_route_screen.dart';
import 'add_edit_line_screen.dart';

class LineDetailScreen extends StatefulWidget {
  final TransportLine line;

  const LineDetailScreen({super.key, required this.line});

  @override
  State<LineDetailScreen> createState() => _LineDetailScreenState();
}

class _LineDetailScreenState extends State<LineDetailScreen> {
  int? _selectedStopA;
  int? _selectedStopB;

  Future<void> _handleDelete() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Line',
      message: 'Are you sure you want to delete "${widget.line.name}"? Any saved route steps already created from this line will not be affected.',
      confirmText: 'Delete Line',
    );

    if (confirmed && mounted) {
      final state = AppStateScope.of(context);
      state.deleteLine(widget.line.id);
      NotificationBanner.showSuccess(context, 'Line deleted from catalog');
      Navigator.of(context).pop();
    }
  }

  void _onStopCircleTapped(int index) {
    setState(() {
      if (_selectedStopA == null) {
        _selectedStopA = index;
      } else if (_selectedStopB == null) {
        if (_selectedStopA == index) {
          _selectedStopA = null; // Deselect Point A
        } else {
          _selectedStopB = index; // Set Point B
        }
      } else {
        // Both are selected
        if (_selectedStopA == index) {
          _selectedStopA = null;
        } else if (_selectedStopB == index) {
          _selectedStopB = null;
        } else {
          // Reset and start new Point A
          _selectedStopA = index;
          _selectedStopB = null;
        }
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedStopA = null;
      _selectedStopB = null;
    });
  }

  // Calculate estimated distance and fare between Point A and Point B
  ({double distanceKm, double regularFare, double discountedFare, int stopCount}) _calculateEstimatedMetrics({
    required List<String> stops,
    required double? totalKm,
    required String rideType,
  }) {
    if (_selectedStopA == null || _selectedStopB == null || stops.length <= 1) {
      return (distanceKm: 0.0, regularFare: 13.0, discountedFare: 10.4, stopCount: 0);
    }

    final stopCount = (_selectedStopB! - _selectedStopA!).abs();
    final totalDistance = totalKm ?? (stops.length * 2.0);
    final fraction = stopCount / (stops.length - 1);
    final distanceKm = totalDistance * fraction;

    double baseFare = 13.00;
    double baseKm = 4.0;
    double perKm = 1.80;

    if (rideType == RideType.eJeep) {
      baseFare = 15.00;
      baseKm = 4.0;
      perKm = 2.20;
    } else if (rideType == RideType.bus || rideType == RideType.p2pBus) {
      baseFare = 15.00;
      baseKm = 5.0;
      perKm = 2.20;
    } else if (rideType == RideType.uvExpress) {
      baseFare = 20.00;
      baseKm = 4.0;
      perKm = 2.50;
    }

    double regular = distanceKm <= baseKm ? baseFare : baseFare + (distanceKm - baseKm) * perKm;
    // Round to nearest 0.25 (typical Philippine coin denominations)
    regular = (regular * 4).round() / 4;
    double discounted = (regular * 0.80 * 4).round() / 4;

    return (
      distanceKm: distanceKm,
      regularFare: regular,
      discountedFare: discounted,
      stopCount: stopCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final currentLine = state.getLineById(widget.line.id) ?? widget.line;
    final stops = currentLine.stops.isNotEmpty
        ? currentLine.stops
        : [currentLine.origin, if (currentLine.via.isNotEmpty) 'Via: ${currentLine.via}', currentLine.destination];

    final hasBothSelected = _selectedStopA != null && _selectedStopB != null;

    final metrics = _calculateEstimatedMetrics(
      stops: stops,
      totalKm: currentLine.distanceKm,
      rideType: currentLine.rideType,
    );

    final stopAName = _selectedStopA != null ? stops[_selectedStopA!] : null;
    final stopBName = _selectedStopB != null ? stops[_selectedStopB!] : null;
    final effectiveFare = state.hasDiscount ? metrics.discountedFare : metrics.regularFare;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Line Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.deepGreen),
            tooltip: 'Edit line',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEditLineScreen(lineToEdit: currentLine),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.coral),
            tooltip: 'Delete line',
            onPressed: _handleDelete,
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
          child: hasBothSelected
              ? Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                CurrencyFormat.format(effectiveFare),
                                style: const TextStyle(
                                  color: AppColors.deepGreen,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (state.hasDiscount) ...[
                                const SizedBox(width: 6),
                                Text(
                                  CurrencyFormat.format(metrics.regularFare),
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            'Point A → Point B (~${metrics.distanceKm.toStringAsFixed(1)} km)',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddEditRouteScreen(
                              prefilledLine: currentLine,
                              prefilledBoardingPoint: stopAName,
                              prefilledDestinationPoint: stopBName,
                              prefilledFare: effectiveFare,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.alt_route_rounded, size: 18),
                      label: const Text('Use in a route'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainGreen,
                        minimumSize: const Size(150, 48),
                      ),
                    ),
                  ],
                )
              : ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddEditRouteScreen(
                          prefilledLine: currentLine,
                          prefilledBoardingPoint: stopAName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.alt_route_rounded, size: 20),
                  label: const Text('Use full line in a route'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: AppColors.mainGreen,
                  ),
                ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Caution Banner
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.amberLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.amber.withAlpha(80)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline_rounded, color: AppColors.amber, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Routes and fares change. Confirm with the driver or operator.',
                        style: TextStyle(
                          color: AppColors.amber,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Header Card
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RideIconBadge(rideType: currentLine.rideType, size: 48, iconSize: 26),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentLine.name,
                                style: const TextStyle(
                                  color: AppColors.deepGreen,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    currentLine.rideType,
                                    style: TextStyle(
                                      color: RideType.getColor(currentLine.rideType),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (currentLine.isSample) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Sample data',
                                        style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: AppColors.borderLight, height: 1),
                    const SizedBox(height: 14),

                    // Circuit Type & Distance
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: currentLine.isLoop ? AppColors.lightMint : AppColors.surfaceMint,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                currentLine.isLoop ? Icons.sync_rounded : Icons.trending_flat_rounded,
                                size: 16,
                                color: currentLine.isLoop ? AppColors.mainGreen : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                currentLine.isLoop ? 'Full Loop Circuit' : 'One-way Corridor',
                                style: TextStyle(
                                  color: currentLine.isLoop ? AppColors.mainGreen : AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (currentLine.distanceKm != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.amberLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.straighten_rounded, size: 16, color: AppColors.amber),
                                const SizedBox(width: 6),
                                Text(
                                  'Approx. ${currentLine.distanceKm} km',
                                  style: const TextStyle(
                                    color: AppColors.amber,
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

                    const SizedBox(height: 14),

                    // Origin and Destination badges
                    Row(
                      children: [
                        const Icon(Icons.place_rounded, color: AppColors.mainGreen, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Origin: ${currentLine.origin}',
                            style: const TextStyle(
                              color: AppColors.deepGreen,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.flag_rounded, color: AppColors.amber, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Destination: ${currentLine.destination}',
                            style: const TextStyle(
                              color: AppColors.deepGreen,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (currentLine.notes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentLine.notes,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Waypoint Selection Instruction & Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Key Stops & Waypoints',
                    style: TextStyle(
                      color: AppColors.deepGreen,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_selectedStopA != null || _selectedStopB != null)
                    TextButton(
                      onPressed: _clearSelection,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text(
                        'Reset points',
                        style: TextStyle(
                          color: AppColors.coral,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),

              // Interactive helper instruction
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app_rounded, color: AppColors.mainGreen, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedStopA == null
                            ? 'Tap any stop circle to set Point A (Boarding).'
                            : (_selectedStopB == null
                                ? 'Point A set to "${stops[_selectedStopA!]}". Tap a 2nd circle to set Point B.'
                                : 'Point A and Point B selected! Estimated fare calculated below.'),
                        style: const TextStyle(
                          color: AppColors.deepGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Stops Card with Clickable Circles
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: stops.asMap().entries.map((entry) {
                    final index = entry.key;
                    final stop = entry.value;
                    final isFirst = index == 0;
                    final isLast = index == stops.length - 1;

                    final isPointA = _selectedStopA == index;
                    final isPointB = _selectedStopB == index;

                    // Check if between Point A and Point B
                    bool isInBetween = false;
                    if (hasBothSelected) {
                      final minIdx = min(_selectedStopA!, _selectedStopB!);
                      final maxIdx = max(_selectedStopA!, _selectedStopB!);
                      isInBetween = index > minIdx && index < maxIdx;
                    }

                    // Check if timeline segment connects selected stops
                    bool isSegmentConnected = false;
                    if (hasBothSelected && !isLast) {
                      final minIdx = min(_selectedStopA!, _selectedStopB!);
                      final maxIdx = max(_selectedStopA!, _selectedStopB!);
                      isSegmentConnected = index >= minIdx && index < maxIdx;
                    }

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Timeline line & clickable circle
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () => _onStopCircleTapped(index),
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: (isPointA || isPointB) ? 28 : 22,
                                    height: (isPointA || isPointB) ? 28 : 22,
                                    decoration: BoxDecoration(
                                      color: isPointA
                                          ? AppColors.mainGreen
                                          : (isPointB
                                              ? AppColors.amber
                                              : (isInBetween
                                                  ? AppColors.lightMint
                                                  : (isFirst
                                                      ? AppColors.mainGreen
                                                      : (isLast ? AppColors.amber : AppColors.surfaceMint)))),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isPointA
                                            ? AppColors.deepGreen
                                            : (isPointB
                                                ? AppColors.amber
                                                : (isInBetween
                                                    ? AppColors.mainGreen
                                                    : (isFirst
                                                        ? AppColors.mainGreen
                                                        : (isLast ? AppColors.amber : AppColors.border)))),
                                        width: (isPointA || isPointB) ? 2.5 : (isInBetween ? 2 : 1.5),
                                      ),
                                      boxShadow: (isPointA || isPointB)
                                          ? [
                                              BoxShadow(
                                                color: (isPointA ? AppColors.mainGreen : AppColors.amber).withAlpha(80),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: isPointA
                                          ? const Text(
                                              'A',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 13,
                                              ),
                                            )
                                          : (isPointB
                                              ? const Text(
                                                  'B',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 13,
                                                  ),
                                                )
                                              : (isInBetween
                                                  ? Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration: const BoxDecoration(
                                                        color: AppColors.mainGreen,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    )
                                                  : Icon(
                                                      isFirst
                                                          ? Icons.play_arrow_rounded
                                                          : (isLast ? Icons.flag_rounded : Icons.circle),
                                                      size: isFirst || isLast ? 12 : 6,
                                                      color: isFirst || isLast ? Colors.white : AppColors.textSecondary,
                                                    ))),
                                    ),
                                  ),
                                ),
                              ),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: isSegmentConnected ? 3 : 2,
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    color: isSegmentConnected ? AppColors.mainGreen : AppColors.mintAccent,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 14),

                          // Stop name + interactive tap handler + badges
                          Expanded(
                            child: InkWell(
                              onTap: () => _onStopCircleTapped(index),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: EdgeInsets.only(top: 2, bottom: isLast ? 2 : 18),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        stop,
                                        style: TextStyle(
                                          color: (isPointA || isPointB)
                                              ? AppColors.deepGreen
                                              : (isInBetween ? AppColors.deepGreen : AppColors.textPrimary),
                                          fontWeight: (isPointA || isPointB)
                                              ? FontWeight.w800
                                              : (isFirst || isLast ? FontWeight.w700 : FontWeight.w500),
                                          fontSize: (isPointA || isPointB) ? 15 : 14,
                                        ),
                                      ),
                                    ),
                                    if (isPointA)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.mainGreen,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Point A • Board',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      )
                                    else if (isPointB)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.amber,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Point B • Alight',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ==========================================
              // SUGGESTED PLACEMENT FOR ESTIMATED PRICE:
              // Directly below the Key Stops card!
              // ==========================================
              if (hasBothSelected) ...[
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.mainGreen, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mainGreen.withAlpha(25),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.calculate_rounded, color: AppColors.mainGreen, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Estimated Segment Fare',
                                style: TextStyle(
                                  color: AppColors.deepGreen,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: _clearSelection,
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Segment description
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.trip_origin_rounded, size: 14, color: AppColors.mainGreen),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'From (Point A): $stopAName',
                                    style: const TextStyle(
                                      color: AppColors.deepGreen,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.pin_drop_rounded, size: 14, color: AppColors.amber),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'To (Point B): $stopBName',
                                    style: const TextStyle(
                                      color: AppColors.deepGreen,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: AppColors.borderLight, height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.straighten_rounded, size: 14, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '~${metrics.distanceKm.toStringAsFixed(1)} km',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.transfer_within_a_station_rounded, size: 14, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${metrics.stopCount} ${metrics.stopCount == 1 ? 'stop' : 'stops'}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Price Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.hasDiscount ? 'Estimated Concession Fare:' : 'Estimated Regular Fare:',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    CurrencyFormat.format(effectiveFare),
                                    style: const TextStyle(
                                      color: AppColors.deepGreen,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  if (state.hasDiscount) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      CurrencyFormat.format(metrics.regularFare),
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 14,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: state.hasDiscount ? AppColors.lightMint : AppColors.surfaceMint,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              state.hasDiscount ? state.discountBadgeText : 'Regular Fare',
                              style: TextStyle(
                                color: state.hasDiscount ? AppColors.mainGreen : AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Action button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddEditRouteScreen(
                                prefilledLine: currentLine,
                                prefilledBoardingPoint: stopAName,
                                prefilledDestinationPoint: stopBName,
                                prefilledFare: effectiveFare,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: Text('Use this segment in route (${CurrencyFormat.format(effectiveFare)})'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          backgroundColor: AppColors.mainGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
