import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pamasahe/theme/app_theme.dart';
import 'package:pamasahe/widgets/app_button.dart';

void main() {
  group('AppButton Component Tests', () {
    testWidgets('Renders Primary variant with text and trailing arrow in Light Mode', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: AppButton(
                text: 'Button',
                trailingIcon: const Icon(Icons.arrow_forward_rounded),
                variant: AppButtonVariant.primary,
                onPressed: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Button'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);

      await tester.tap(find.text('Button'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('Renders Secondary, Outline, and Ghost variants in Dark Mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Column(
              children: [
                AppButton(
                  text: 'Secondary',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {},
                ),
                AppButton(
                  text: 'Outline',
                  variant: AppButtonVariant.outline,
                  onPressed: () {},
                ),
                AppButton(
                  text: 'Ghost',
                  variant: AppButtonVariant.ghost,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Secondary'), findsOneWidget);
      expect(find.text('Outline'), findsOneWidget);
      expect(find.text('Ghost'), findsOneWidget);
    });

    testWidgets('Renders AppSplitButton with action and dropdown chevron', (tester) async {
      bool mainTapped = false;
      bool chevronTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: AppSplitButton(
                label: 'Button Group',
                onPressed: () => mainTapped = true,
                onTrailingPressed: () => chevronTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Button Group'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);

      await tester.tap(find.text('Button Group'));
      expect(mainTapped, isTrue);

      await tester.tap(find.byIcon(Icons.keyboard_arrow_up_rounded));
      expect(chevronTapped, isTrue);
    });

    testWidgets('Renders AppBadge pills', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Row(
              children: [
                AppBadge(label: 'Badge', variant: AppBadgeVariant.primary),
                AppBadge(label: 'Secondary', variant: AppBadgeVariant.secondary),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Badge'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
    });
  });
}
