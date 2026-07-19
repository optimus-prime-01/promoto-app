import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../providers/business_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/common/promoto_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
    _navigate();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

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
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PromoToLogo(size: 100, darkBackground: true),
              const SizedBox(height: 8),
              Text(
                'Grow Your Local Business',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.white.withValues(alpha: 0.7),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 48),
              LoadingAnimationWidget.staggeredDotsWave(
                color: AppColors.orange,
                size: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
