import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/audit/audit_screen.dart';
import '../screens/subscription/subscription_screen.dart';
import '../screens/keywords/keywords_screen.dart';
import '../screens/competitors/competitors_screen.dart';
import '../screens/qr_review/qr_review_screen.dart';
import '../screens/about/about_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/business/edit_business_screen.dart';
import '../screens/social_accounts/social_accounts_screen.dart';
import '../screens/scheduled_posts/scheduled_posts_screen.dart';
import '../screens/comments/comments_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String audit = '/audit';
  static const String subscription = '/subscription';
  static const String keywords = '/keywords';
  static const String competitors = '/competitors';
  static const String qrReview = '/qr-review';
  static const String about = '/about';
  static const String notifications = '/notifications';
  static const String editBusiness = '/edit-business';
  static const String socialAccounts = '/social-accounts';
  static const String scheduledPosts = '/scheduled-posts';
  static const String comments = '/comments';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authState.isLoggedIn;
      final isOnSplash = state.matchedLocation == AppRoutes.splash;
      final isOnLogin = state.matchedLocation == AppRoutes.login;
      final isOnSignup = state.matchedLocation == AppRoutes.signup;
      final isOnOnboarding = state.matchedLocation == AppRoutes.onboarding;

      // Let splash handle its own logic
      if (isOnSplash) return null;

      // If not logged in, redirect to login (allow signup page)
      if (!isLoggedIn && !isOnLogin && !isOnSignup) {
        return AppRoutes.login;
      }

      // If logged in and on login/signup page, go to home
      if (isLoggedIn && (isOnLogin || isOnSignup)) {
        return AppRoutes.home;
      }

      // Allow onboarding access when logged in
      if (isLoggedIn && isOnOnboarding) {
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.audit,
        builder: (context, state) => const AuditScreen(),
      ),
      GoRoute(
        path: AppRoutes.subscription,
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: AppRoutes.keywords,
        builder: (context, state) => const KeywordsScreen(),
      ),
      GoRoute(
        path: AppRoutes.competitors,
        builder: (context, state) => const CompetitorsScreen(),
      ),
      GoRoute(
        path: AppRoutes.qrReview,
        builder: (context, state) => const QrReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.editBusiness,
        builder: (context, state) => const EditBusinessScreen(),
      ),
      GoRoute(
        path: AppRoutes.socialAccounts,
        builder: (context, state) => const SocialAccountsScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledPosts,
        builder: (context, state) {
          final platform =
              state.uri.queryParameters['platform'];
          return ScheduledPostsScreen(platformFilter: platform);
        },
      ),
      GoRoute(
        path: AppRoutes.comments,
        builder: (context, state) => const CommentsScreen(),
      ),
    ],
  );
});
