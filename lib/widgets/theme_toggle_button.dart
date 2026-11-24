import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A theme toggle button matching the custom contrast icon:
/// A circle split vertically with diagonal hatched stripes on the right half,
/// flanked by subtle vertical divider lines on both sides.
class ThemeToggleButton extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggle;
  final double iconSize;
  final double dividerHeight;
  final bool showDividers;

  const ThemeToggleButton({
    super.key,
    required this.themeMode,
    required this.onToggle,
    this.iconSize = 24.0,
    this.dividerHeight = 22.0,
    this.showDividers = true,
  });

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0.0);
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark ||
        (widget.themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    final iconColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final dividerColor = isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle;
    final tooltipMessage = isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode';

    return Semantics(
      button: true,
      label: tooltipMessage,
      child: Tooltip(
        message: tooltipMessage,
        child: InkWell(
          key: const ValueKey('theme_mode_toggle_button'),
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(10),
          hoverColor: iconColor.withValues(alpha: 0.06),
          splashColor: iconColor.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.showDividers) ...[
                  Container(
                    width: 1.2,
                    height: widget.dividerHeight,
                    color: dividerColor,
                  ),
                  const SizedBox(width: 10),
                ],
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: CustomPaint(
                    size: Size(widget.iconSize, widget.iconSize),
                    painter: ContrastHatchedPainter(
                      color: iconColor,
                      strokeWidth: 1.8,
                    ),
                  ),
                ),
                if (widget.showDividers) ...[
                  const SizedBox(width: 10),
                  Container(
                    width: 1.2,
                    height: widget.dividerHeight,
                    color: dividerColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter that draws a circle split vertically down the middle,
/// with the right half filled with diagonal parallel hatched lines.
class ContrastHatchedPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const ContrastHatchedPainter({
    required this.color,
    this.strokeWidth = 1.8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - (strokeWidth / 2);

    final outlinePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // 1. Draw outer circle
    canvas.drawCircle(center, radius, outlinePaint);

    // 2. Draw vertical dividing line
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      outlinePaint,
    );

    // 3. Clip to right semicircle to draw diagonal hatching lines
    canvas.save();
    final rightHalfPath = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi,
        false,
      )
      ..close();

    canvas.clipPath(rightHalfPath);

    // 4. Draw parallel diagonal lines slanting bottom-left to top-right (/ / / /)
    final hatchPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    // Step spacing between diagonal stripes
    final spacing = radius * 0.38;
    final totalSpan = radius * 2.5;

    for (double offset = -totalSpan; offset <= totalSpan; offset += spacing) {
      // Lines slanting from bottom-left to top-right (dx increases, dy decreases)
      canvas.drawLine(
        Offset(center.dx + offset, center.dy + radius + 4),
        Offset(center.dx + offset + radius * 2, center.dy - radius - 4),
        hatchPaint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ContrastHatchedPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
