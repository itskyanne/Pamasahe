import 'package:flutter/material.dart';
import '../../models/saved_route.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../widgets/notification_banner.dart';

class LogTripScreen extends StatefulWidget {
  final SavedRoute? initialRoute;

  const LogTripScreen({super.key, this.initialRoute});

  @override
  State<LogTripScreen> createState() => _LogTripScreenState();
}

class _LogTripScreenState extends State<LogTripScreen> {
  SavedRoute? _selectedRoute;
  late TextEditingController _amountController;
  late TextEditingController _dateController;

  String? _routeError;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    _selectedRoute = widget.initialRoute;
    _amountController = TextEditingController();
    _dateController = TextEditingController(text: 'Nov 6, 2026'); // Today's date

    // Prefill amount if initialRoute is passed
    if (widget.initialRoute != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final state = AppStateScope.of(context);
        final initialFare = widget.initialRoute!.getDiscountedTotal(state.studentDiscount);
        _amountController.text = initialFare.toStringAsFixed(2);
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _onRouteChanged(SavedRoute? route) {
    if (route == null) return;
    setState(() {
      _selectedRoute = route;
      _routeError = null;

      final state = AppStateScope.of(context);
      final fare = route.getDiscountedTotal(state.studentDiscount);
      _amountController.text = fare.toStringAsFixed(2);
      _amountError = null;
    });
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _routeError = null;
      _amountError = null;

      if (_selectedRoute == null) {
        _routeError = 'Please select a saved route';
        valid = false;
      }

      final amount = double.tryParse(_amountController.text.trim());
      if (amount == null || amount <= 0) {
        _amountError = 'Amount must be greater than ₱0.00';
        valid = false;
      }
    });
    return valid;
  }

  void _saveTrip() {
    if (!_validate()) return;

    final state = AppStateScope.of(context);
    final amount = double.parse(_amountController.text.trim());
    final date = _dateController.text.trim().isNotEmpty ? _dateController.text.trim() : 'Nov 6, 2026';

    state.logTrip(
      routeId: _selectedRoute!.id,
      routeName: _selectedRoute!.name,
      amount: amount,
      date: date,
    );

    NotificationBanner.showSuccess(context, 'Trip logged! Added to your history.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final routes = state.routes;
    final isStudentDiscount = state.studentDiscount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Log Trip'),
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
            onPressed: _saveTrip,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: AppColors.mainGreen,
            ),
            child: const Text(
              'Save Completed Trip',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
              // Card with fields
              Container(
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
                    const Text(
                      'Trip Details',
                      style: TextStyle(
                        color: AppColors.deepGreen,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Saved route dropdown
                    const Text(
                      'Saved Commute Route',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<SavedRoute>(
                      initialValue: _selectedRoute != null && routes.any((r) => r.id == _selectedRoute!.id)
                          ? routes.firstWhere((r) => r.id == _selectedRoute!.id)
                          : null,
                      isExpanded: true,
                      decoration: InputDecoration(
                        hintText: 'Select a route you took...',
                        errorText: _routeError,
                      ),
                      items: routes.map((route) {
                        return DropdownMenuItem<SavedRoute>(
                          value: route,
                          child: Text(
                            '${route.name} (${route.from} → ${route.to})',
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: _onRouteChanged,
                    ),

                    if (_selectedRoute != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                isStudentDiscount ? 'Calculated Student Fare (20% off):' : 'Calculated Regular Fare:',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '₱${_selectedRoute!.getDiscountedTotal(isStudentDiscount).toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.mainGreen,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // Editable Fare
                    const Text(
                      'Actual Amount Paid (₱)',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        prefixText: '₱ ',
                        prefixStyle: const TextStyle(
                          color: AppColors.deepGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        helperText: 'Editable in case of temporary discounts or fare adjustments.',
                        errorText: _amountError,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Editable Date
                    const Text(
                      'Trip Date',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Nov 6, 2026',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_month_rounded, color: AppColors.mainGreen),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2025),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              const months = [
                                'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                              ];
                              setState(() {
                                _dateController.text = '${months[picked.month - 1]} ${picked.day}, ${picked.year}';
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Student Discount Notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      state.discountType == DiscountType.senior
                          ? Icons.elderly_rounded
                          : (state.discountType == DiscountType.pwd
                              ? Icons.accessible_rounded
                              : Icons.school_rounded),
                      color: AppColors.mainGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isStudentDiscount
                            ? '${state.discountTypeName} discount (20%) is currently active in Settings.'
                            : 'Concession discount is turned off in Settings.',
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
            ],
          ),
        ),
      ),
    );
  }
}
