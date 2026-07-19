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
    final isDark = darkBackground ||
        Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isDark ? AppColors.white : AppColors.navy,
            borderRadius: BorderRadius.circular(size * 0.24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.all(size * 0.15),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              isDark ? AppColors.navy : AppColors.white,
              BlendMode.srcIn,
            ),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
            ),
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
                    fontSize: size * 0.3,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.white : AppColors.navy,
                    fontFamily: 'Poppins',
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'to',
                  style: TextStyle(
                    fontSize: size * 0.3,
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
