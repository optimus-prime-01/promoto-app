import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../providers/business_provider.dart';
import '../../services/storage_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Logo rotation (spin in)
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _rotateAnimation = Tween<double>(begin: -2 * pi, end: 0).animate(
      CurvedAnimation(
        parent: _rotateController,
        curve: Curves.easeOutBack,
      ),
    );

    // Logo scale (bounce in)
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    // Text fade in
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start animations in sequence
    _scaleController.forward();
    _rotateController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _fadeController.forward();
    });

    _navigate();
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    try {
      final storage = StorageService();
      final token = await storage.getToken();

      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        await ref.read(businessProvider.notifier).fetchBusinesses();

        if (!mounted) return;

        final businessState = ref.read(businessProvider);
        if (businessState.currentBusiness != null) {
          context.go(AppRoutes.home);
        } else {
          context.go(AppRoutes.onboarding);
        }
      } else {
        context.go(AppRoutes.login);
      }
    } catch (_) {
      if (!mounted) return;
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated logo
            AnimatedBuilder(
              animation: Listenable.merge([
                _rotateController,
                _scaleController,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: const ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    AppColors.navy,
                    BlendMode.srcIn,
                  ),
                  child: Image(
                    image: AssetImage('assets/images/logo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Animated text
            FadeTransition(
              opacity: _fadeAnimation,
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Promo',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        fontFamily: 'Poppins',
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextSpan(
                      text: 'to',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppColors.orange,
                        fontFamily: 'Poppins',
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _textFadeAnimation,
              child: Text(
                'Grow Your Local Business',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.white.withValues(alpha: 0.7),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 48),
            FadeTransition(
              opacity: _textFadeAnimation,
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: AppColors.orange,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
