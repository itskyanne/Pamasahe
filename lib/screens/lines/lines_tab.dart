import 'package:flutter/material.dart';
import '../../models/transport_line.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import 'line_detail_screen.dart';

class LinesTab extends StatefulWidget {
  const LinesTab({super.key});

  @override
  State<LinesTab> createState() => _LinesTabState();
}

class _LinesTabState extends State<LinesTab> {
  String _selectedFilter = 'All';

  final List<String> _filters = const [
    'All',
    'Jeepney',
    'Bus',
    'Train',
  ];

  static const List<Color> _defaultColors = [
    Color(0xFFFFB800), // Yellow
    Color(0xFF5B8DEF), // Blue
    Color(0xFFFF6584), // Pink
    Color(0xFF1F8A4C), // Green
  ];

  void _openLineDetailScreen(BuildContext context, TransportLine line) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LineDetailScreen(line: line),
      ),
    );
  }

  String _getLineCode(TransportLine line, int index) {
    if (line.code != null && line.code!.isNotEmpty) {
      return line.code!;
    }
    final prefix = line.rideType.isNotEmpty ? line.rideType[0].toUpperCase() : 'L';
    return '$prefix${(index + 1).toString().padLeft(2, '0')}';
  }

  String _getRideTypeLabel(TransportLine line) {
    final lower = line.rideType.toLowerCase();
    if (lower.contains('train')) return 'TRAIN';
    if (lower.contains('bus')) return 'BUS';
    if (lower.contains('jeep')) return 'JEEPNEY';
    if (lower.contains('trike') || lower.contains('tricycle')) return 'TRICYCLE';
    if (lower.contains('uv')) return 'UV EXPRESS';
    return line.rideType.toUpperCase();
  }

  String _getRouteCoverage(TransportLine line) {
    if (line.routeCoverage != null && line.routeCoverage!.isNotEmpty) {
      return line.routeCoverage!;
    }
    if (line.stops.isNotEmpty) {
      return line.stops.take(3).join(' → ');
    }
    if (line.via.isNotEmpty) {
      return '${line.origin} → ${line.via} → ${line.destination}';
    }
    return '${line.origin} → ${line.destination}';
  }

  String _getFrequency(TransportLine line) {
    if (line.frequency != null && line.frequency!.isNotEmpty) {
      return line.frequency!;
    }
    return 'Every 10–15 min';
  }

  String _getStatus(TransportLine line) {
    return line.status ?? 'Operating';
  }

  Color _getLineColor(TransportLine line, int index) {
    if (line.color != null) return line.color!;
    return _defaultColors[index % _defaultColors.length];
  }

  List<TransportLine> _filterLines(List<TransportLine> allLines) {
    if (_selectedFilter == 'All') return allLines;

    final filterLower = _selectedFilter.toLowerCase();
    return allLines.where((line) {
      final typeLower = line.rideType.toLowerCase();
      if (filterLower == 'train') {
        return typeLower.contains('train') || line.name.toLowerCase().contains('train');
      }
      if (filterLower == 'bus') {
        return typeLower.contains('bus');
      }
      if (filterLower == 'jeepney') {
        return typeLower.contains('jeep');
      }
      return typeLower == filterLower;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final allLines = state.lines;
    final filteredLines = _filterLines(allLines);
    final operatingCount = filteredLines
        .where((l) => _getStatus(l).toLowerCase() == 'operating')
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 600;
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

                  // 2. PAGE HEADER
                  const Text(
                    'PUBLIC TRANSPORT',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Color(0xFF165B47),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Lines',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.9,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Browse nearby transport lines and check their current service status.',
                    style: TextStyle(
                      color: Color(0xFF5A726E),
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 3. TRANSPORT FILTERS
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () {
                              if (_selectedFilter != filter) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF1E1E1E)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF1E1E1E)
                                      : const Color(0xFFE5E7EB),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF1F2937),
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4. AVAILABLE LINES SECTION HEADING
                  const Text(
                    'NEAR YOU',
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
                          'Available lines',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        operatingCount > 0
                            ? '$operatingCount operating'
                            : '${filteredLines.length} available',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Color(0xFF6B7280),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 5. TRANSPORT LINE CARDS
                  if (filteredLines.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 36,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFE5ECE8)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.directions_bus_filled_outlined,
                              color: Color(0xFF6B7280),
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'No lines found',
                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'No transport services currently match the "$_selectedFilter" category.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF5A726E),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...List.generate(filteredLines.length, (index) {
                      final line = filteredLines[index];
                      final code = _getLineCode(line, index);
                      final rideType = _getRideTypeLabel(line);
                      final routeCoverage = _getRouteCoverage(line);
                      final frequency = _getFrequency(line);
                      final status = _getStatus(line);
                      final color = _getLineColor(line, index);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _LineCard(
                          line: line,
                          code: code,
                          rideType: rideType,
                          routeCoverage: routeCoverage,
                          frequency: frequency,
                          status: status,
                          color: color,
                          onTap: () => _openLineDetailScreen(context, line),
                        ),
                      );
                    }),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LineCard extends StatelessWidget {
  final TransportLine line;
  final String code;
  final String rideType;
  final String routeCoverage;
  final String frequency;
  final String status;
  final Color color;
  final VoidCallback onTap;

  const _LineCard({
    required this.line,
    required this.code,
    required this.rideType,
    required this.routeCoverage,
    required this.frequency,
    required this.status,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOperating = status.toLowerCase() == 'operating';
    // Dark slate text for bright badges, white text for darker greens
    final codeTextColor = (color.r * 255 * 0.299 +
                color.g * 255 * 0.587 +
                color.b * 255 * 0.114) >
            150
        ? const Color(0xFF1E2825)
        : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE5ECE8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Line Code Block
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      code,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: codeTextColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // 2. Route Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rideType,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9.5,
                          color: Color(0xFF6B7280),
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        line.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        routeCoverage,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF6B7280),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      // Status and Frequency Row
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          // Status Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: isOperating
                                  ? const Color(0xFFD6F5E3)
                                  : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isOperating
                                    ? const Color(0xFFBCEBD0)
                                    : const Color(0xFFFDE68A),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isOperating
                                        ? const Color(0xFF1F8A4C)
                                        : const Color(0xFFD97706),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  status,
                                  style: TextStyle(
                                    color: isOperating
                                        ? const Color(0xFF165B47)
                                        : const Color(0xFF92400E),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Frequency Text
                          Text(
                            frequency,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10.5,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // 3. Details Circular Action Button
                InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1.2,
                      ),
                      color: Colors.transparent,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
