import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PhoneFrame extends StatelessWidget {
  final Widget child;

  const PhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        // If the screen is wider than typical mobile phones (e.g. tablet, desktop, web browser)
        if (constraints.maxWidth > 500) {
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF070B0A) : const Color(0xFFE2EBE8),
            body: Center(
              child: Container(
                width: 390,
                height: 844,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : AppColors.background,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 80 : 35),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E2F2B) : const Color(0xFFCBD5D1),
                    width: 3,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: child,
              ),
            ),
          );
        }

        // On mobile screen, fill viewport
        return child;
      },
    );
  }
}
