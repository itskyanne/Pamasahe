import 'package:flutter/material.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';

class PamasaheTopBar extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  final bool isSettingsActive;

  const PamasaheTopBar({
    super.key,
    this.onSettingsTap,
    this.isSettingsActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final initials = state.userInitials;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Pamasahe',
          style: TextStyle(
            color: AppColors.deepGreen,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        Semantics(
          button: true,
          label: 'Account and Settings',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const ValueKey('nav_item_settings'),
              onTap: onSettingsTap,
              borderRadius: BorderRadius.circular(10),
              splashColor: Colors.white.withValues(alpha: 0.2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF133E37),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSettingsActive
                        ? AppColors.mainGreen
                        : Colors.white.withValues(alpha: 0.22),
                    width: isSettingsActive ? 2.0 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
