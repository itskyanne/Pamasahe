import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Available visual variants for [AppButton], matching modern minimalist pill design.
enum AppButtonVariant {
  /// Solid high-contrast fill (Light: #111827 black / Dark: #F3F4F6 off-white).
  primary,

  /// Subtle elevated neutral fill (Light: #F3F4F6 / Dark: #21252D).
  secondary,

  /// Transparent background with 1px subtle border (Light: #E5E7EB / Dark: #2A2F3A).
  outline,

  /// Transparent background, hover tint, matching text color.
  ghost,

  /// Red/coral accent for destructive confirmations or alerts.
  destructive,
}

/// Available sizing options for [AppButton].
enum AppButtonSize {
  /// Compact height (32px), padding horizontal 12, font size 12.
  sm,

  /// Standard height (42px), padding horizontal 20, font size 14.
  md,

  /// Large full-bleed or hero height (48px), padding horizontal 24, font size 15.
  lg,
}

/// Production-ready modern Button component engineered for both Light and Dark modes.
/// Replicates the pill/stadium geometry, typography, and interactive states from the design spec.
class AppButton extends StatefulWidget {
  final String? text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? icon;
  final Widget? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;
  final BorderRadius? borderRadius;
  final Widget? child;
  final FocusNode? focusNode;
  final String? semanticLabel;

  const AppButton({
    super.key,
    this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.borderRadius,
    this.child,
    this.focusNode,
    this.semanticLabel,
  }) : assert(text != null || child != null, 'Either text or child must be provided.');

  const AppButton.icon({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant = AppButtonVariant.secondary,
    this.size = AppButtonSize.md,
    this.borderRadius,
    this.focusNode,
    this.semanticLabel,
  })  : text = null,
        trailingIcon = null,
        isLoading = false,
        isFullWidth = false,
        child = null;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isFocused = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Resolve color styling tokens based on active Variant and Theme
    final style = _resolveButtonStyle(isDark);

    // Geometry & Dimensions
    final height = _resolveHeight();
    final padding = _resolvePadding();
    final textStyle = _resolveTextStyle(style.textColor);
    final radius = widget.borderRadius ?? BorderRadius.circular(999); // Full Pill / Stadium

    Widget content;
    if (widget.isLoading) {
      content = SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(style.textColor),
        ),
      );
    } else if (widget.child != null) {
      content = widget.child!;
    } else {
      content = Row(
        mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            IconTheme(
              data: IconThemeData(color: style.textColor, size: style.iconSize),
              child: widget.icon!,
            ),
            const SizedBox(width: 8),
          ],
          if (widget.text != null)
            Text(
              widget.text!,
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (widget.trailingIcon != null) ...[
            const SizedBox(width: 8),
            IconTheme(
              data: IconThemeData(color: style.textColor, size: style.iconSize),
              child: widget.trailingIcon!,
            ),
          ],
        ],
      );
    }

    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.semanticLabel ?? widget.text,
      child: FocusableActionDetector(
        focusNode: widget.focusNode,
        onShowFocusHighlight: (focused) => setState(() => _isFocused = focused),
        onShowHoverHighlight: (hovered) => setState(() => _isHovered = hovered),
        child: GestureDetector(
          onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
          onTapUp: _isEnabled ? (_) => setState(() => _isPressed = false) : null,
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: _isEnabled ? widget.onPressed : null,
          child: AnimatedScale(
            scale: _isPressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOutCubic,
              height: height,
              padding: padding,
              decoration: BoxDecoration(
                color: style.backgroundColor,
                borderRadius: radius,
                border: style.border,
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.22),
                          blurRadius: 0,
                          spreadRadius: 2.0,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                widthFactor: widget.isFullWidth ? null : 1.0,
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _resolveHeight() {
    switch (widget.size) {
      case AppButtonSize.sm:
        return 32.0;
      case AppButtonSize.md:
        return 42.0;
      case AppButtonSize.lg:
        return 48.0;
    }
  }

  EdgeInsetsGeometry _resolvePadding() {
    if (widget.text == null && widget.child == null && widget.icon != null) {
      // Square / round icon button padding
      final h = _resolveHeight();
      return EdgeInsets.symmetric(horizontal: (h - 20) / 2);
    }

    switch (widget.size) {
      case AppButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 14, vertical: 6);
      case AppButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
      case AppButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    }
  }

  TextStyle _resolveTextStyle(Color textColor) {
    double fontSize;
    FontWeight fontWeight = FontWeight.w700;

    switch (widget.size) {
      case AppButtonSize.sm:
        fontSize = 12.5;
        fontWeight = FontWeight.w600;
        break;
      case AppButtonSize.md:
        fontSize = 14.0;
        break;
      case AppButtonSize.lg:
        fontSize = 15.5;
        break;
    }

    return TextStyle(
      color: textColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontFamily: 'Inter',
      letterSpacing: -0.2,
      height: 1.2,
    );
  }

  _ResolvedButtonStyle _resolveButtonStyle(bool isDark) {
    if (!_isEnabled) {
      return _ResolvedButtonStyle(
        backgroundColor: isDark ? const Color(0xFF1E2128) : const Color(0xFFF3F4F6),
        textColor: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
        border: Border.all(color: Colors.transparent, width: 1),
        iconSize: widget.size == AppButtonSize.sm ? 15 : 18,
      );
    }

    switch (widget.variant) {
      case AppButtonVariant.primary:
        // Light Mode: Black background / White text
        // Dark Mode: Off-white background / Dark text
        Color bg = isDark ? const Color(0xFFF3F4F6) : const Color(0xFF111827);
        Color fg = isDark ? const Color(0xFF111827) : const Color(0xFFFFFFFF);

        if (_isHovered) {
          bg = isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1F2937);
        }
        if (_isPressed) {
          bg = isDark ? const Color(0xFFD1D5DB) : const Color(0xFF030712);
        }

        return _ResolvedButtonStyle(
          backgroundColor: bg,
          textColor: fg,
          border: null,
          iconSize: widget.size == AppButtonSize.sm ? 15 : 18,
        );

      case AppButtonVariant.secondary:
        // Light Mode: Soft gray #F3F4F6 / Dark text #111827
        // Dark Mode: Elevated dark gray #21252D / Light text #F3F4F6
        Color bg = isDark ? const Color(0xFF21252D) : const Color(0xFFF3F4F6);
        Color fg = isDark ? const Color(0xFFF3F4F6) : const Color(0xFF111827);

        if (_isHovered) {
          bg = isDark ? const Color(0xFF282D37) : const Color(0xFFE5E7EB);
        }
        if (_isPressed) {
          bg = isDark ? const Color(0xFF1D2128) : const Color(0xFFD1D5DB);
        }

        return _ResolvedButtonStyle(
          backgroundColor: bg,
          textColor: fg,
          border: null,
          iconSize: widget.size == AppButtonSize.sm ? 15 : 18,
        );

      case AppButtonVariant.outline:
        // Transparent with 1px border (#E5E7EB in light, #2A2F3A in dark)
        Color bg = Colors.transparent;
        Color borderC = isDark ? const Color(0xFF2A2F3A) : const Color(0xFFE5E7EB);
        Color fg = isDark ? const Color(0xFFF3F4F6) : const Color(0xFF111827);

        if (_isHovered) {
          bg = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04);
        }
        if (_isPressed) {
          bg = isDark ? Colors.white.withValues(alpha: 0.09) : Colors.black.withValues(alpha: 0.07);
        }

        return _ResolvedButtonStyle(
          backgroundColor: bg,
          textColor: fg,
          border: Border.all(color: borderC, width: 1.0),
          iconSize: widget.size == AppButtonSize.sm ? 15 : 18,
        );

      case AppButtonVariant.ghost:
        Color bg = Colors.transparent;
        Color fg = isDark ? const Color(0xFFF3F4F6) : const Color(0xFF111827);

        if (_isHovered) {
          bg = isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05);
        }
        if (_isPressed) {
          bg = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08);
        }

        return _ResolvedButtonStyle(
          backgroundColor: bg,
          textColor: fg,
          border: null,
          iconSize: widget.size == AppButtonSize.sm ? 15 : 18,
        );

      case AppButtonVariant.destructive:
        Color bg = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFEF4444);
        Color fg = Colors.white;

        if (_isHovered) {
          bg = isDark ? const Color(0xFF991B1B) : const Color(0xFFDC2626);
        }

        return _ResolvedButtonStyle(
          backgroundColor: bg,
          textColor: fg,
          border: null,
          iconSize: widget.size == AppButtonSize.sm ? 15 : 18,
        );
    }
  }
}

class _ResolvedButtonStyle {
  final Color backgroundColor;
  final Color textColor;
  final BoxBorder? border;
  final double iconSize;

  const _ResolvedButtonStyle({
    required this.backgroundColor,
    required this.textColor,
    this.border,
    required this.iconSize,
  });
}

/// A split button group component matching the "Button Group | ^" element in the design spec.
class AppSplitButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final VoidCallback onTrailingPressed;
  final IconData trailingIcon;
  final AppButtonSize size;

  const AppSplitButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.onTrailingPressed,
    this.trailingIcon = Icons.keyboard_arrow_up_rounded,
    this.size = AppButtonSize.md,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF2A2F3A) : const Color(0xFFE5E7EB);
    final textColor = isDark ? const Color(0xFFF3F4F6) : const Color(0xFF111827);
    final dividerColor = borderColor;

    return Container(
      height: size == AppButtonSize.sm ? 32 : (size == AppButtonSize.lg ? 48 : 42),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main text action
          InkWell(
            onTap: onPressed,
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(999)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
          // Vertical 1px subtle divider
          Container(
            width: 1.0,
            height: double.infinity,
            color: dividerColor,
          ),
          // Trailing action
          InkWell(
            onTap: onTrailingPressed,
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(999)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Icon(
                  trailingIcon,
                  size: 18,
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill Badge component matching the "Badge" / "Secondary" pills in the design spec.
enum AppBadgeVariant { primary, secondary, outline }

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    BoxBorder? border;

    switch (variant) {
      case AppBadgeVariant.primary:
        bg = isDark ? const Color(0xFFF3F4F6) : const Color(0xFF111827);
        fg = isDark ? const Color(0xFF111827) : const Color(0xFFFFFFFF);
        break;
      case AppBadgeVariant.secondary:
        bg = isDark ? const Color(0xFF21252D) : const Color(0xFFF3F4F6);
        fg = isDark ? const Color(0xFFF3F4F6) : const Color(0xFF111827);
        break;
      case AppBadgeVariant.outline:
        bg = Colors.transparent;
        fg = isDark ? const Color(0xFFF3F4F6) : const Color(0xFF111827);
        border = Border.all(
          color: isDark ? const Color(0xFF2A2F3A) : const Color(0xFFE5E7EB),
          width: 1.0,
        );
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
