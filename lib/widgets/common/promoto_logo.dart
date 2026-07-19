import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class PromoToLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool darkBackground;

  const PromoToLogo({
    super.key,
    this.size = 80,
    this.showText = true,
    this.darkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = darkBackground ? AppColors.white : AppColors.navy;
    final iconColor = darkBackground ? AppColors.navy : AppColors.white;
    final textColor = darkBackground ? AppColors.white : AppColors.navy;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(size * 0.24),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _LogoPainter(color: iconColor),
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.2),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Promo',
                  style: TextStyle(
                    fontSize: size * 0.35,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    fontFamily: 'Poppins',
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'to',
                  style: TextStyle(
                    fontSize: size * 0.35,
                    fontWeight: FontWeight.w800,
                    color: AppColors.orange,
                    fontFamily: 'Poppins',
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;

  _LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.28;

    // Outer ring (signal/broadcast icon)
    final arcRect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    canvas.drawArc(arcRect, -2.3, 1.5, false, strokePaint);
    canvas.drawArc(arcRect, 0.8, 1.5, false, strokePaint);

    // Inner ring
    final innerR = r * 0.65;
    final innerRect = Rect.fromCircle(center: Offset(cx, cy), radius: innerR);
    canvas.drawArc(innerRect, -2.0, 0.9, false, strokePaint);
    canvas.drawArc(innerRect, 1.1, 0.9, false, strokePaint);

    // Center dot
    canvas.drawCircle(Offset(cx, cy), size.width * 0.06, paint);

    // Upward arrow (growth indicator)
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final arrowBottom = cy + r * 0.7;
    final arrowTop = cy - r * 0.5;
    // Vertical line
    canvas.drawLine(
      Offset(cx, arrowBottom),
      Offset(cx, arrowTop),
      arrowPaint,
    );
    // Arrow head
    canvas.drawLine(
      Offset(cx - size.width * 0.08, arrowTop + size.width * 0.1),
      Offset(cx, arrowTop),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(cx + size.width * 0.08, arrowTop + size.width * 0.1),
      Offset(cx, arrowTop),
      arrowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
