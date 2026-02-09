import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool isDark;

  const AppLogo({super.key, this.size = 120, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Shield/Circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                  const Color(0xFF0D47A1), // Darker Blue
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: size * 0.2,
                  offset: Offset(0, size * 0.1),
                ),
              ],
            ),
          ),

          // Outer Ring
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: size * 0.02,
              ),
            ),
          ),

          // Building / Shelter Icon
          Positioned(
            top: size * 0.22,
            child: Icon(
              Icons.shield_outlined,
              size: size * 0.55,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),

          // Main Icon Composition
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.apartment_rounded,
                size: size * 0.45,
                color: Colors.white,
              ),
              SizedBox(height: size * 0.02),
              Container(
                width: size * 0.3,
                height: size * 0.04,
                decoration: BoxDecoration(
                  color: Colors.amber, // Gold accent
                  borderRadius: BorderRadius.circular(size * 0.1),
                ),
              ),
            ],
          ),

          // Checkmark Badge
          Positioned(
            right: size * 0.05,
            bottom: size * 0.05,
            child: Container(
              padding: EdgeInsets.all(size * 0.06),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.check_circle,
                size: size * 0.2,
                color: const Color(0xFF4CAF50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
