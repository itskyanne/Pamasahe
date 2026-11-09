import 'package:flutter/material.dart';
import '../../models/saved_place.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/notification_banner.dart';
import 'map_place_picker_screen.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  void _openMapPicker(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MapPlacePickerScreen(),
      ),
    );
  }

  void _viewOnMap(BuildContext context, SavedPlace place) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapPlacePickerScreen(
          initialPlace: place,
          isViewOnly: true,
        ),
      ),
    );
  }

  Future<void> _handleDeletePlace(BuildContext context, String place) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Remove Saved Place',
      message: 'Remove "$place" from your saved places list?',
      confirmText: 'Remove',
    );

    if (confirmed && context.mounted) {
      final state = AppStateScope.of(context);
      state.deleteSavedPlace(place);
      NotificationBanner.showSuccess(context, 'Removed "$place"');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Concession Discount Card (Student, Senior Citizen, PWD)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.lightMint,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.loyalty_rounded, color: AppColors.mainGreen, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Concession Fare Discount',
                                style: TextStyle(
                                  color: AppColors.deepGreen,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '20% off • Student, Senior & PWD',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: state.hasDiscount,
                          activeThumbColor: AppColors.mainGreen,
                          onChanged: (val) {
                            state.toggleStudentDiscount(val);
                            NotificationBanner.showInfo(
                              context,
                              val ? '20% Concession discount enabled (${state.discountTypeName})' : 'Discount turned off',
                            );
                          },
                        ),
                      ],
                    ),

                    if (state.hasDiscount) ...[
                      const SizedBox(height: 14),
                      const Text(
                        'Select Concession Category:',
                        style: TextStyle(
                          color: AppColors.deepGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Concession Type Options: Student, Senior Citizen, PWD
                      Column(
                        children: [
                          _DiscountOptionTile(
                            title: 'Student',
                            subtitle: 'Republic Act No. 11314 (Student Fare Discount Act)',
                            icon: Icons.school_rounded,
                            isSelected: state.discountType == DiscountType.student,
                            onTap: () {
                              state.setDiscountType(DiscountType.student);
                              NotificationBanner.showSuccess(context, 'Set discount type to Student (20% off)');
                            },
                          ),
                          const SizedBox(height: 8),
                          _DiscountOptionTile(
                            title: 'Senior Citizen',
                            subtitle: 'Republic Act No. 9994 (Expanded Senior Citizens Act)',
                            icon: Icons.elderly_rounded,
                            isSelected: state.discountType == DiscountType.senior,
                            onTap: () {
                              state.setDiscountType(DiscountType.senior);
                              NotificationBanner.showSuccess(context, 'Set discount type to Senior Citizen (20% off)');
                            },
                          ),
                          const SizedBox(height: 8),
                          _DiscountOptionTile(
                            title: 'PWD (Person with Disability)',
                            subtitle: 'Republic Act No. 10754 (Benefits & Privileges of PWDs)',
                            icon: Icons.accessible_rounded,
                            isSelected: state.discountType == DiscountType.pwd,
                            onTap: () {
                              state.setDiscountType(DiscountType.pwd);
                              NotificationBanner.showSuccess(context, 'Set discount type to PWD (20% off)');
                            },
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 12),
                    const Divider(color: AppColors.borderLight, height: 1),
                    const SizedBox(height: 12),
                    Text(
                      state.hasDiscount
                          ? 'Active: 20% discount for ${state.discountTypeName} is automatically applied across route cards, timelines, and trip logs.'
                          : 'Inactive: Full regular fares are displayed throughout the application.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Saved Places Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Saved Places',
                        style: TextStyle(
                          color: AppColors.deepGreen,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Pin origins & destinations on the map',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openMapPicker(context),
                    icon: const Icon(Icons.add_location_alt_rounded, size: 16),
                    label: const Text(
                      'Pin on Map',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(110, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: state.savedPlaceObjects.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No saved places. Tap "+ Pin on Map" to drop your first location pin.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.savedPlaceObjects.length,
                        separatorBuilder: (context, index) => const Divider(color: AppColors.borderLight, height: 1),
                        itemBuilder: (context, index) {
                          final place = state.savedPlaceObjects[index];

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: place.color.withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                place.icon,
                                color: place.color,
                                size: 22,
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  place.name,
                                  style: const TextStyle(
                                    color: AppColors.deepGreen,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceMint,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    place.category,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    place.address,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${place.latitude.toStringAsFixed(4)}° N, ${place.longitude.toStringAsFixed(4)}° E',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.map_rounded, color: AppColors.mainGreen, size: 22),
                                  tooltip: 'View on map',
                                  onPressed: () => _viewOnMap(context, place),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.coral, size: 20),
                                  tooltip: 'Remove place',
                                  onPressed: () => _handleDeletePlace(context, place.name),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 28),

              // About & Filipino Commuter Tips Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMint,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.directions_bus_filled_rounded, color: AppColors.mainGreen, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Pamasahe — Commuter Notebook',
                          style: TextStyle(
                            color: AppColors.deepGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A mobile-first commute fare tracker, route notebook, and public transport line reference built for Filipino commuters & students.\n\nDesigned offline-first with zero server tracking. Fares are saved on your phone and can be adjusted anytime.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.textMuted),
                        SizedBox(width: 4),
                        Text(
                          'In-Memory Prototype • v1.0.0',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
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

class _DiscountOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DiscountOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightMint : AppColors.surfaceMint,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.mainGreen : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.mainGreen : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.deepGreen,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: AppColors.deepGreen,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.mainGreen : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-20%',
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? AppColors.mainGreen : AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
