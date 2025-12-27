import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A circular progress ring that displays percentage completion.
/// Used to show how much of an interval has elapsed.
class ProgressRing extends StatelessWidget {
  /// The percentage completed (0.0 to 100.0+)
  final double percentage;

  /// The color of the progress arc
  final Color progressColor;

  /// The background color of the ring
  final Color backgroundColor;

  /// The size of the ring (width and height)
  final double size;

  /// The thickness of the ring stroke
  final double strokeWidth;

  /// Child widget to display in the center of the ring
  final Widget? child;

  const ProgressRing({
    super.key,
    required this.percentage,
    required this.progressColor,
    this.backgroundColor = const Color(0xFF2C2C2C),
    this.size = 120,
    this.strokeWidth = 8,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress ring
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressRingPainter(
              percentage: percentage,
              progressColor: progressColor,
              backgroundColor: backgroundColor,
              strokeWidth: strokeWidth,
            ),
          ),
          // Center content
          if (child != null) child!,
        ],
      ),
    );
  }
}

/// Custom painter for the progress ring
class _ProgressRingPainter extends CustomPainter {
  final double percentage;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.percentage,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle paint
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Progress arc paint
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background circle
    canvas.drawCircle(center, radius, backgroundPaint);

    // Calculate sweep angle (capped at 100% for visual, but can show overflow)
    // Start from top (-90 degrees or -pi/2)
    const startAngle = -math.pi / 2;

    // Cap visual at 100% but allow the color to indicate overdue
    final clampedPercentage = percentage.clamp(0.0, 100.0);
    final sweepAngle = (clampedPercentage / 100) * 2 * math.pi;

    // Draw progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // If overdue (>100%), add a subtle glow effect
    if (percentage > 100) {
      final glowPaint = Paint()
        ..color = progressColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        2 * math.pi, // Full circle glow for overdue
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
