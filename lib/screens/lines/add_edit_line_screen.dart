import 'package:flutter/material.dart';
import '../../models/ride_type.dart';
import '../../models/transport_line.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../widgets/notification_banner.dart';
import '../../widgets/ride_icon_badge.dart';

class AddEditLineScreen extends StatefulWidget {
  final TransportLine? lineToEdit;

  const AddEditLineScreen({super.key, this.lineToEdit});

  @override
  State<AddEditLineScreen> createState() => _AddEditLineScreenState();
}

class _AddEditLineScreenState extends State<AddEditLineScreen> {
  late TextEditingController _nameController;
  late TextEditingController _originController;
  late TextEditingController _destinationController;
  late TextEditingController _viaController;
  late TextEditingController _notesController;
  late TextEditingController _distanceController;

  String _rideType = RideType.jeepney;
  bool _isLoop = false;

  String? _nameError;
  String? _originError;
  String? _destinationError;

  @override
  void initState() {
    super.initState();
    final edit = widget.lineToEdit;
    _nameController = TextEditingController(text: edit?.name ?? '');
    _originController = TextEditingController(text: edit?.origin ?? '');
    _destinationController = TextEditingController(text: edit?.destination ?? '');
    _viaController = TextEditingController(text: edit?.via ?? '');
    _notesController = TextEditingController(text: edit?.notes ?? '');
    _distanceController = TextEditingController(
      text: edit?.distanceKm != null ? edit!.distanceKm.toString() : '',
    );
    if (edit != null) {
      _rideType = edit.rideType;
      _isLoop = edit.isLoop;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    _viaController.dispose();
    _notesController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _nameError = null;
      _originError = null;
      _destinationError = null;

      if (_nameController.text.trim().isEmpty) {
        _nameError = 'Line name is required';
        valid = false;
      }
      if (_originController.text.trim().isEmpty) {
        _originError = 'Origin is required';
        valid = false;
      }
      if (_destinationController.text.trim().isEmpty) {
        _destinationError = 'Destination is required';
        valid = false;
      }
    });
    return valid;
  }

  void _saveLine() {
    if (!_validate()) return;

    final state = AppStateScope.of(context);
    final distance = double.tryParse(_distanceController.text.trim());
    final origin = _originController.text.trim();
    final destination = _destinationController.text.trim();
    final via = _viaController.text.trim();

    final stops = [
      origin,
      if (via.isNotEmpty) 'Via: $via',
      destination,
    ];

    if (widget.lineToEdit != null) {
      final updated = widget.lineToEdit!.copyWith(
        name: _nameController.text.trim(),
        rideType: _rideType,
        origin: origin,
        destination: destination,
        via: via,
        notes: _notesController.text.trim(),
        distanceKm: distance,
        isLoop: _isLoop,
        stops: stops,
      );
      state.updateLine(updated);
      NotificationBanner.showSuccess(context, 'Line updated');
    } else {
      final newLine = TransportLine(
        id: 0,
        name: _nameController.text.trim(),
        rideType: _rideType,
        origin: origin,
        destination: destination,
        via: via,
        notes: _notesController.text.trim(),
        distanceKm: distance,
        isLoop: _isLoop,
        stops: stops,
        isSample: false,
      );
      state.addLine(newLine);
      NotificationBanner.showSuccess(context, 'New line added to directory');
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.lineToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Line' : 'Add Transport Line'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
          child: ElevatedButton(
            onPressed: _saveLine,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: AppColors.mainGreen,
            ),
            child: Text(
              isEditing ? 'Update Line' : 'Save Line',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Line Profile',
                  style: TextStyle(
                    color: AppColors.deepGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),

                // Line Name
                const Text(
                  'Line Name',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Toril – Roxas / Bankerohan',
                    errorText: _nameError,
                  ),
                ),

                const SizedBox(height: 16),

                // Ride Type
                const Text(
                  'Ride Type',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _rideType,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                  items: RideType.all.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Row(
                        children: [
                          RideIconBadge(rideType: type, size: 28, iconSize: 16),
                          const SizedBox(width: 10),
                          Text(type, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _rideType = val);
                  },
                ),

                const SizedBox(height: 16),

                // Origin
                const Text(
                  'Origin Point',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _originController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Toril Public Terminal',
                    errorText: _originError,
                  ),
                ),

                const SizedBox(height: 16),

                // Destination
                const Text(
                  'Destination Point',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _destinationController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Bankerohan Market',
                    errorText: _destinationError,
                  ),
                ),

                const SizedBox(height: 16),

                // Via
                const Text(
                  'Via (Major Roads or Landmarks)',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _viaController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. McArthur Highway, Matina Crossing',
                  ),
                ),

                const SizedBox(height: 16),

                // Distance (km) & Loop toggle
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Distance (km)',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _distanceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              hintText: 'e.g. 16.5',
                              suffixText: 'km',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Circuit Type',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _isLoop,
                            activeThumbColor: AppColors.mainGreen,
                            title: Text(
                              _isLoop ? 'Full Loop' : 'One Way',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            onChanged: (val) => setState(() => _isLoop = val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Notes
                const Text(
                  'Commuter Notes',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Peak hours 6:00 - 8:30 AM. Expect delays during rush hour.',
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
