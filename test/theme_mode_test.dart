import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pamasahe/main.dart';
import 'package:pamasahe/state/app_state.dart';
import 'package:pamasahe/theme/app_colors.dart';
import 'package:pamasahe/theme/app_theme.dart';
import 'package:pamasahe/widgets/theme_toggle_button.dart';

void main() {
  group('Theme Mode & Palette Unit Tests', () {
    test('AppState defaults to light theme and toggles to dark theme correctly', () {
      final state = AppState();
      expect(state.themeMode, ThemeMode.light);
      expect(state.isDarkMode, isFalse);

      state.toggleThemeMode();
      expect(state.themeMode, ThemeMode.dark);
      expect(state.isDarkMode, isTrue);

      state.toggleThemeMode();
      expect(state.themeMode, ThemeMode.light);
      expect(state.isDarkMode, isFalse);

      state.setThemeMode(ThemeMode.dark);
      expect(state.themeMode, ThemeMode.dark);
      expect(state.isDarkMode, isTrue);
    });

    test('Dark and Light palette design tokens match design specification', () {
      // Dark Mode (Off-Black & Soft White)
      expect(AppColors.darkBgBase, const Color(0xFF0B0D10));
      expect(AppColors.darkSurfaceCard, const Color(0xFF16191F));
      expect(AppColors.darkSurfaceModal, const Color(0xFF21252D));
      expect(AppColors.darkBorderSubtle, const Color(0xFF2A2F3A));
      expect(AppColors.darkTextPrimary, const Color(0xFFF3F4F6));
      expect(AppColors.darkTextSecondary, const Color(0xFF9CA3AF));
      expect(AppColors.darkTextMuted, const Color(0xFF6B7280));

      // Light Mode (Soft White & Charcoal)
      expect(AppColors.lightBgBase, const Color(0xFFF8F9FA));
      expect(AppColors.lightSurfaceCard, const Color(0xFFFFFFFF));
      expect(AppColors.lightSurfaceModal, const Color(0xFFFFFFFF));
      expect(AppColors.lightBorderSubtle, const Color(0xFFE5E7EB));
      expect(AppColors.lightTextPrimary, const Color(0xFF111827));
      expect(AppColors.lightTextSecondary, const Color(0xFF4B5563));
      expect(AppColors.lightTextMuted, const Color(0xFF9CA3AF));
    });

    test('AppTheme ThemeData configurations have correct brightness and scaffold backgrounds', () {
      final light = AppTheme.lightTheme;
      final dark = AppTheme.darkTheme;

      expect(light.brightness, Brightness.light);
      expect(light.scaffoldBackgroundColor, AppColors.lightBgBase);
      expect(light.cardColor, AppColors.lightSurfaceCard);

      expect(dark.brightness, Brightness.dark);
      expect(dark.scaffoldBackgroundColor, AppColors.darkBgBase);
      expect(dark.cardColor, AppColors.darkSurfaceCard);
      expect(dark.colorScheme.primary, AppColors.darkMainGreen);
    });
  });

  group('ThemeToggleButton Widget & Settings Integration Tests', () {
    testWidgets('ThemeToggleButton renders custom contrast icon with dividing lines and responds to tap', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ThemeToggleButton(
                themeMode: ThemeMode.light,
                onToggle: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ThemeToggleButton), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      await tester.tap(find.byKey(const ValueKey('theme_mode_toggle_button')));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('Settings screen contains theme toggle button in header and appearance card, toggling dark mode', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const PamasaheApp());
      await tester.pumpAndSettle();

      // Navigate to Settings tab
      await tester.tap(find.byKey(const ValueKey('nav_item_settings')));
      await tester.pumpAndSettle();

      // Verify Settings page and Appearance elements exist
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byKey(const ValueKey('settings_theme_toggle_header')), findsOneWidget);

      // Tap header theme toggle button
      await tester.tap(find.byKey(const ValueKey('settings_theme_toggle_header')));
      await tester.pumpAndSettle();

      // Verify Dark Mode active banner or text
      expect(find.textContaining('Dark Mode'), findsWidgets);

      // Tap again to switch back to Light Mode
      await tester.tap(find.byKey(const ValueKey('settings_theme_toggle_header')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Light Mode'), findsWidgets);
    });
  });
}
