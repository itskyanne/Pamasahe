import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PhoneFrame extends StatelessWidget {
  final Widget child;

  const PhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If the screen is wider than typical mobile phones (e.g. tablet, desktop, web browser)
        if (constraints.maxWidth > 900) {
          final frameHeight = constraints.maxHeight.isFinite
              ? math.min(844.0, math.max(500.0, constraints.maxHeight - 32.0))
              : 844.0;

          return Scaffold(
            backgroundColor: const Color(0xFFE2EBE8),
            body: Center(
              child: Container(
                width: 390,
                height: frameHeight,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(35),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFCBD5D1),
                    width: 3,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: child,
              ),
            ),
          );
        }

        // On mobile screen, fill viewport with guaranteed solid background
        return ColoredBox(
          color: AppColors.background,
          child: child,
        );
      },
    );
  }
}
