import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DoseProgressRing extends StatelessWidget {
  final int taken;
  final int total;
  final double size;

  const DoseProgressRing({
    super.key,
    required this.taken,
    required this.total,
    this.size = 110,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(taken: taken, total: total),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$taken/$total',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                  height: 1.1,
                ),
              ),
              const Text(
                'doses',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final int taken;
  final int total;

  const _RingPainter({required this.taken, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;
    const strokeWidth = 10.0;

    final bgPaint = Paint()
      ..color = const Color(0xFFE8D5F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (total <= 0 || taken <= 0) return;

    final progress = (taken / total).clamp(0.0, 1.0);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: const [AppColors.gradientStart, AppColors.gradientEnd],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.taken != taken || old.total != total;
}
