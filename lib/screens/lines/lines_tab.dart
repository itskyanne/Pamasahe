import 'package:flutter/material.dart';
import '../../models/ride_type.dart';
import '../../models/transport_line.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../widgets/ride_icon_badge.dart';
import 'add_edit_line_screen.dart';
import 'line_detail_screen.dart';

class LinesTab extends StatefulWidget {
  const LinesTab({super.key});

  @override
  State<LinesTab> createState() => _LinesTabState();
}

class _LinesTabState extends State<LinesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Jeepney',
    'Bus',
    'P2P bus',
    'UV Express',
    'Train',
    'Ferry',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final allLines = state.lines;

    // Filter logic
    final query = _searchController.text.trim().toLowerCase();
    final filteredLines = allLines.where((line) {
      // Search match
      final matchesSearch = query.isEmpty ||
          line.name.toLowerCase().contains(query) ||
          line.origin.toLowerCase().contains(query) ||
          line.destination.toLowerCase().contains(query) ||
          line.via.toLowerCase().contains(query);

      // Filter chip match
      bool matchesFilter = true;
      if (_selectedFilter == 'All') {
        matchesFilter = true;
      } else if (_selectedFilter == 'Train') {
        matchesFilter = line.rideType.contains('train') || line.rideType.contains('Train');
      } else {
        matchesFilter = line.rideType.toLowerCase() == _selectedFilter.toLowerCase();
      }

      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transport Lines'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditLineScreen(),
            ),
          );
        },
        backgroundColor: AppColors.mainGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'New Line',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search jeepney or bus name',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Filter Chips Bar
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;

                  return FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
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
                },
              ),
            ),

            const SizedBox(height: 12),

            // Lines List or Empty State
            Expanded(
              child: filteredLines.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.lightMint,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.search_off_rounded,
                                color: AppColors.textMuted,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No lines match. Try another name.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.deepGreen,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
                      itemCount: filteredLines.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final line = filteredLines[index];
                        return _LineCard(
                          line: line,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LineDetailScreen(line: line),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineCard extends StatelessWidget {
  final TransportLine line;
  final VoidCallback onTap;

  const _LineCard({required this.line, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Icon + Name + Tags
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RideIconBadge(rideType: line.rideType, size: 40, iconSize: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.name,
                        style: const TextStyle(
                          color: AppColors.deepGreen,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        line.rideType,
                        style: TextStyle(
                          color: RideType.getColor(line.rideType),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badges
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (line.isLoop)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: AppColors.lightMint,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Full loop',
                          style: TextStyle(
                            color: AppColors.mainGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMint,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'One way',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (line.isSample)
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
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Origin -> Destination
            Row(
              children: [
                const Icon(Icons.circle, size: 7, color: AppColors.mainGreen),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${line.origin} → ${line.destination}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            if (line.via.isNotEmpty) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 13),
                child: Text(
                  'via ${line.via}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            const SizedBox(height: 10),
            const Divider(color: AppColors.borderLight, height: 1),
            const SizedBox(height: 8),

            // Bottom distance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (line.distanceKm != null)
                  Row(
                    children: [
                      const Icon(Icons.straighten_rounded, size: 14, color: AppColors.amber),
                      const SizedBox(width: 4),
                      Text(
                        'Approx. ${line.distanceKm} km',
                        style: const TextStyle(
                          color: AppColors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox.shrink(),
                const Text(
                  'Details →',
                  style: TextStyle(
                    color: AppColors.mainGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
