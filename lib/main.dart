import 'package:flutter/material.dart';
import 'screens/main_scaffold.dart';
import 'state/app_scope.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'widgets/phone_frame.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PamasaheApp());
}

class PamasaheApp extends StatefulWidget {
  const PamasaheApp({super.key});

  @override
  State<PamasaheApp> createState() => _PamasaheAppState();
}

class _PamasaheAppState extends State<PamasaheApp> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: MaterialApp(
        title: 'Pamasahe — Commute Fare Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        color: AppColors.background,
        builder: (context, child) {
          // Centered responsive shell matching 390x844 mobile screen on larger displays
          return PhoneFrame(child: child ?? const SizedBox.shrink());
        },
        home: const MainScaffold(),
      ),
    );
  }
}
