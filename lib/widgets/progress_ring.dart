import 'dart:math';
import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double percentage; // 0 a 100
  final double size;
  final double strokeWidth;

  const ProgressRing({
    super.key,
    required this.percentage,
    this.size = 120,
    this.strokeWidth = 10,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percentage.clamp(0, 100)),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _RingPainter(
                  percentage: value,
                  strokeWidth: strokeWidth,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                "${value.toInt()}%",
                style: TextStyle(
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w700,
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color color;

  _RingPainter({
    required this.percentage,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;

    final rect = Rect.fromCircle(
      center: Offset(center, center),
      radius: center - strokeWidth,
    );

    final backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(rect, 0, 2 * pi, false, backgroundPaint);

    if (percentage <= 0) return; // 🔥 PROTEÇÃO CRÍTICA

    final sweepAngle = (percentage / 100) * 2 * pi;

    final gradient = SweepGradient(
      startAngle: -pi / 2,
      endAngle: -pi / 2 + sweepAngle,
      colors: [
        Colors.greenAccent,
        Colors.green,
        color,
      ],
    );

    final foregroundPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -pi / 2,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}