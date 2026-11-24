import 'package:flutter/material.dart';
import '../state/app_scope.dart';
import '../theme/app_colors.dart';

/// Top bar header component for Pamasahe.
/// 
/// On primary tabs (Home, Routes, Lines, History), displays the brand wordmark
/// on the left and the commuter profile avatar shortcut on the right.
/// 
/// On nested sub-pages such as Settings/Profile view, conditionally:
/// 1. Hides the redundant profile avatar from the top-right corner.
/// 2. Displays a standard, accessible back navigation element (`←` arrow + title)
///    in the top-left position that triggers back navigation with fallback.
class PamasaheTopBar extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  final bool isSettingsActive;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool showProfileAvatar;
  final String? title;

  const PamasaheTopBar({
    super.key,
    this.onSettingsTap,
    this.isSettingsActive = false,
    this.showBackButton = false,
    this.onBackPressed,
    this.showProfileAvatar = true,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final initials = state.userInitials;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTextPrimary : AppColors.deepGreen;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // --- 1. TOP-LEFT NAVIGATION / WORDMARK ---
        if (showBackButton)
          Semantics(
            button: true,
            label: 'Go back',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: const ValueKey('settings_back_button'),
                onTap: onBackPressed ?? () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                borderRadius: BorderRadius.circular(12),
                hoverColor: primaryColor.withValues(alpha: 0.06),
                splashColor: primaryColor.withValues(alpha: 0.12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_rounded,
                        color: primaryColor,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title ?? 'Back',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        else
          Text(
            title ?? 'Pamasahe',
            style: TextStyle(
              color: primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),

        // --- 2. TOP-RIGHT PROFILE AVATAR SHORTCUT ---
        // Conditionally hidden on Settings/Profile routes to prevent redundant shortcuts
        if (showProfileAvatar && !isSettingsActive)
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
                    color: isDark ? const Color(0xFF16191F) : const Color(0xFF133E37),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorderSubtle : Colors.white.withValues(alpha: 0.22),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : Colors.white,
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
          )
        else
          // Placeholder maintaining symmetric alignment height without rendering avatar
          const SizedBox(width: 38, height: 38),
      ],
    );
  }
}
