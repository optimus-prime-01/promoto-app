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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: darkBackground ? AppColors.white : AppColors.white,
            borderRadius: BorderRadius.circular(size * 0.24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: EdgeInsets.all(size * 0.15),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.18),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Promo',
                  style: TextStyle(
                    fontSize: size * 0.3,
                    fontWeight: FontWeight.w800,
                    color: darkBackground
                        ? AppColors.white
                        : AppColors.navy,
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
