import 'package:flutter/material.dart';
import '../../models/ride_type.dart';
import '../../models/route_step.dart';
import '../../models/saved_route.dart';
import '../../models/transport_line.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../widgets/notification_banner.dart';
import '../../widgets/ride_icon_badge.dart';

class _StepDraft {
  int id;
  String rideType;
  TextEditingController boardingController;
  TextEditingController fareController;
  int? pickedLineId;
  String? boardingError;
  String? fareError;

  _StepDraft({
    required this.id,
    required this.rideType,
    required String boardingPoint,
    required String fareText,
    this.pickedLineId,
  })  : boardingController = TextEditingController(text: boardingPoint),
        fareController = TextEditingController(text: fareText);

  void dispose() {
    boardingController.dispose();
    fareController.dispose();
  }
}

class AddEditRouteScreen extends StatefulWidget {
  final SavedRoute? routeToEdit;
  final TransportLine? prefilledLine;
  final String? prefilledBoardingPoint;
  final String? prefilledDestinationPoint;
  final double? prefilledFare;

  const AddEditRouteScreen({
    super.key,
    this.routeToEdit,
    this.prefilledLine,
    this.prefilledBoardingPoint,
    this.prefilledDestinationPoint,
    this.prefilledFare,
  });

  @override
  State<AddEditRouteScreen> createState() => _AddEditRouteScreenState();
}

class _AddEditRouteScreenState extends State<AddEditRouteScreen> {
  late TextEditingController _nameController;
  late TextEditingController _travelTimeController;

  String? _fromPlace;
  String? _toPlace;
  String? _nameError;
  String? _generalError;

  final List<_StepDraft> _steps = [];
  int _stepIdCounter = 1;

  @override
  void initState() {
    super.initState();
    final edit = widget.routeToEdit;
    final prefill = widget.prefilledLine;

    final defaultName = edit?.name ??
        (widget.prefilledBoardingPoint != null && widget.prefilledDestinationPoint != null
            ? '${widget.prefilledBoardingPoint} to ${widget.prefilledDestinationPoint}'
            : (prefill != null ? '${prefill.origin} to ${prefill.destination}' : ''));

    _nameController = TextEditingController(text: defaultName);
    _travelTimeController = TextEditingController(
      text: edit?.travelTimeMinutes != null ? edit!.travelTimeMinutes.toString() : '',
    );

    if (edit != null) {
      _fromPlace = edit.from;
      _toPlace = edit.to;
      for (final step in edit.steps) {
        _steps.add(
          _StepDraft(
            id: _stepIdCounter++,
            rideType: step.rideType,
            boardingPoint: step.boardingPoint,
            fareText: step.fare.toStringAsFixed(2),
          ),
        );
      }
    } else if (prefill != null) {
      _fromPlace = 'Home';
      _toPlace = 'School';
      _steps.add(
        _StepDraft(
          id: _stepIdCounter++,
          rideType: prefill.rideType,
          boardingPoint: widget.prefilledBoardingPoint ?? prefill.origin,
          fareText: widget.prefilledFare != null ? widget.prefilledFare!.toStringAsFixed(2) : '',
          pickedLineId: prefill.id,
        ),
      );
    } else {
      _fromPlace = 'Home';
      _toPlace = 'School';
      _steps.add(
        _StepDraft(
          id: _stepIdCounter++,
          rideType: RideType.jeepney,
          boardingPoint: '',
          fareText: '',
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _travelTimeController.dispose();
    for (final s in _steps) {
      s.dispose();
    }
    super.dispose();
  }

  void _addStep() {
    setState(() {
      _steps.add(
        _StepDraft(
          id: _stepIdCounter++,
          rideType: RideType.jeepney,
          boardingPoint: '',
          fareText: '',
        ),
      );
      _generalError = null;
    });
  }

  void _removeStep(int index) {
    if (_steps.length <= 1) {
      setState(() {
        _generalError = 'At least one step is required';
      });
      return;
    }
    setState(() {
      final removed = _steps.removeAt(index);
      removed.dispose();
      _generalError = null;
    });
  }

  void _onLineSelected(_StepDraft draft, TransportLine? line) {
    if (line == null) return;
    setState(() {
      draft.pickedLineId = line.id;
      draft.rideType = line.rideType;
      draft.boardingController.text = line.origin;
      // Per brief: "Selecting a transport line must fill the ride type, fill boarding point with line origin, and CLEAR the fare so user enters current amount"
      draft.fareController.text = '';
      draft.boardingError = null;
      draft.fareError = null;
    });
  }

  bool _validate() {
    bool isValid = true;
    setState(() {
      _nameError = null;
      _generalError = null;

      if (_nameController.text.trim().isEmpty) {
        _nameError = 'Enter a route name';
        isValid = false;
      }

      if (_steps.isEmpty) {
        _generalError = 'At least one step is required';
        isValid = false;
      }

      for (final step in _steps) {
        step.boardingError = null;
        step.fareError = null;

        if (step.boardingController.text.trim().isEmpty) {
          step.boardingError = 'Enter a boarding point';
          isValid = false;
        }

        final fareVal = double.tryParse(step.fareController.text.trim());
        if (fareVal == null || fareVal <= 0) {
          step.fareError = 'Enter a fare greater than 0';
          isValid = false;
        }
      }
    });

    return isValid;
  }

  void _saveRoute() {
    if (!_validate()) return;

    final state = AppStateScope.of(context);
    final routeSteps = _steps.map((s) {
      return RouteStep(
        id: s.id,
        rideType: s.rideType,
        boardingPoint: s.boardingController.text.trim(),
        fare: double.parse(s.fareController.text.trim()),
      );
    }).toList();

    final travelTime = int.tryParse(_travelTimeController.text.trim());

    if (widget.routeToEdit != null) {
      final updated = widget.routeToEdit!.copyWith(
        name: _nameController.text.trim(),
        from: _fromPlace ?? 'Home',
        to: _toPlace ?? 'School',
        travelTimeMinutes: travelTime,
        steps: routeSteps,
        faresUpdated: 'Nov 6, 2026',
        faresOutdated: false,
      );
      state.updateRoute(updated);
      NotificationBanner.showSuccess(context, 'Route updated successfully');
    } else {
      final newRoute = SavedRoute(
        id: 0, // Assigned in state
        name: _nameController.text.trim(),
        from: _fromPlace ?? 'Home',
        to: _toPlace ?? 'School',
        travelTimeMinutes: travelTime,
        steps: routeSteps,
        faresUpdated: 'Nov 6, 2026',
        faresOutdated: false,
      );
      state.addRoute(newRoute);
      NotificationBanner.showSuccess(context, 'Route saved to your notebook');
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final places = state.savedPlaces;
    final lines = state.lines;
    final isEditing = widget.routeToEdit != null;

    // Ensure fallback places if deleted
    final effectiveFrom = places.contains(_fromPlace) ? _fromPlace : (places.isNotEmpty ? places.first : 'Home');
    final effectiveTo = places.contains(_toPlace) ? _toPlace : (places.length > 1 ? places[1] : (places.isNotEmpty ? places.first : 'School'));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Route' : 'Add Route'),
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
            onPressed: _saveRoute,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: AppColors.mainGreen,
            ),
            child: Text(
              isEditing ? 'Update Route' : 'Save Route',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
              // General Error banner
              if (_generalError != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.coralLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.coral),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.coral, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _generalError!,
                          style: const TextStyle(
                            color: AppColors.coral,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Route Info Card
              Container(
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
                      'Route Information',
                      style: TextStyle(
                        color: AppColors.deepGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Route Name
                    const Text(
                      'Route Name',
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
                        hintText: 'e.g. Home to School (jeep)',
                        errorText: _nameError,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // From & To dropdowns
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'From',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: effectiveFrom,
                                isExpanded: true,
                                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                                items: places.map((place) {
                                  return DropdownMenuItem<String>(
                                    value: place,
                                    child: Text(place, style: const TextStyle(fontSize: 14)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _fromPlace = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'To',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: effectiveTo,
                                isExpanded: true,
                                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                                items: places.map((place) {
                                  return DropdownMenuItem<String>(
                                    value: place,
                                    child: Text(place, style: const TextStyle(fontSize: 14)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _toPlace = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Travel time (minutes)
                    const Text(
                      'Travel Time (minutes, optional)',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _travelTimeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'e.g. 45',
                        suffixText: 'mins',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Commute Steps Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Commute Steps',
                    style: TextStyle(
                      color: AppColors.deepGreen,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addStep,
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.mainGreen),
                    label: const Text(
                      'Add step',
                      style: TextStyle(
                        color: AppColors.mainGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Commute Steps List
              ..._steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (step.boardingError != null || step.fareError != null)
                          ? AppColors.coral
                          : AppColors.border,
                      width: (step.boardingError != null || step.fareError != null) ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step Title + Remove
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.lightMint,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: AppColors.deepGreen,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ride #${index + 1}',
                                style: const TextStyle(
                                  color: AppColors.deepGreen,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          if (_steps.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.coral, size: 20),
                              tooltip: 'Remove step',
                              onPressed: () => _removeStep(index),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Optional "Pick from lines" dropdown
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMint,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.auto_awesome_rounded, color: AppColors.mainGreen, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'Pick from public transport lines (optional)',
                                  style: TextStyle(
                                    color: AppColors.deepGreen,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<TransportLine>(
                                hint: const Text(
                                  'Select a reference line...',
                                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                                ),
                                isExpanded: true,
                                icon: const Icon(Icons.expand_more_rounded, color: AppColors.mainGreen, size: 20),
                                items: lines.map((l) {
                                  return DropdownMenuItem<TransportLine>(
                                    value: l,
                                    child: Row(
                                      children: [
                                        RideIconBadge(rideType: l.rideType, size: 26, iconSize: 14),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            l.name,
                                            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (line) => _onLineSelected(step, line),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Ride Type Dropdown
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
                        initialValue: step.rideType,
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
                          if (val != null) setState(() => step.rideType = val);
                        },
                      ),

                      const SizedBox(height: 14),

                      // Boarding point
                      const Text(
                        'Boarding Point',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: step.boardingController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Barangay gate, Terminal, Station',
                          errorText: step.boardingError,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Fare
                      const Text(
                        'Fare (₱)',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: step.fareController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixText: '₱ ',
                          prefixStyle: const TextStyle(
                            color: AppColors.deepGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          errorText: step.fareError,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Add Step bottom button
              OutlinedButton.icon(
                onPressed: _addStep,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add another ride step'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
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
