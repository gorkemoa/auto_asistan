import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class CircularScoreIndicator extends StatelessWidget {
  final double score; // 0.0 to 1.0
  final String label;
  final String subtitle;
  final Color baseColor;
  final List<Color> gradientColors;

  const CircularScoreIndicator({
    super.key,
    required this.score,
    required this.label,
    required this.subtitle,
    this.baseColor = const Color(0xFFF0F2F5),
    this.gradientColors = const [Color(0xFF4A90D9), Color(0xFF00B4D8)],
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft glow
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withValues(alpha: 0.08),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          
          // Custom Painter for the progress and segments
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: score),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutQuart,
            builder: (context, value, _) {
              return CustomPaint(
                size: const Size(200, 200),
                painter: _ScorePainter(
                  progress: value,
                  baseColor: baseColor,
                  gradientColors: gradientColors,
                ),
              );
            },
          ),
          
          // Inner Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                (score * 100).toInt().toString(),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -2,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: gradientColors.first,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScorePainter extends CustomPainter {
  final double progress;
  final Color baseColor;
  final List<Color> gradientColors;

  _ScorePainter({
    required this.progress,
    required this.baseColor,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const padding = 20.0;
    final innerRadius = radius - padding;

    // 1. Draw base track (segments)
    final trackPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const segmentCount = 60;
    const segmentGap = 0.04;
    final segmentLength = (2 * pi / segmentCount) - segmentGap;

    for (var i = 0; i < segmentCount; i++) {
      final angle = i * (2 * pi / segmentCount) - pi / 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        angle,
        segmentLength,
        false,
        trackPaint,
      );
    }

    // 2. Draw progress track
    final progressPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(center.dx, center.dy - innerRadius),
        Offset(center.dx, center.dy + innerRadius),
        gradientColors,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );

    // 3. Draw mini dash indicators (like the image)
    final dashPaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var i = 0; i < 100; i += 2) {
      final angle = (i / 100) * 2 * pi - pi / 2;
      final start = Offset(
        center.dx + (innerRadius - 15) * cos(angle),
        center.dy + (innerRadius - 15) * sin(angle),
      );
      final end = Offset(
        center.dx + (innerRadius - 22) * cos(angle),
        center.dy + (innerRadius - 22) * sin(angle),
      );
      
      dashPaint.color = (i / 100 <= progress) 
        ? gradientColors.first.withValues(alpha: 0.5)
        : const Color(0xFFD1D5DB).withValues(alpha: 0.3);
      
      canvas.drawLine(start, end, dashPaint);
    }
    
    // 4. Zero and hundred labels
    const textStyle = TextStyle(color: Color(0xFF9CA3AF), fontSize: 10, fontWeight: FontWeight.w600);
    _drawText(canvas, "0", center.dx - 15, center.dy + innerRadius - 5, textStyle);
    _drawText(canvas, "100", center.dx + 15, center.dy + innerRadius - 5, textStyle);
  }

  void _drawText(Canvas canvas, String text, double x, double y, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _ScorePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
