import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/promoto_logo.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isLoggedIn) {
        context.go(AppRoutes.onboarding);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const PromoToLogo(size: 72),
              const SizedBox(height: 8),
              Text(
                'Create your account',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              if (authState.error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    authState.error!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your name',
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.navy,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.navy,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '9876543210',
                  prefixText: '+91 ',
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.navy,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Sign up with Google',
                icon: Icons.g_mobiledata,
                isLoading: authState.isLoading,
                width: double.infinity,
                onPressed: () {
                  ref.read(authProvider.notifier).signInWithGoogle();
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Sign up with Phone OTP',
                icon: Icons.phone,
                isOutlined: true,
                width: double.infinity,
                onPressed: () {
                  final phone = _phoneController.text.trim();
                  if (phone.length != 10) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Enter valid 10-digit phone number'),
                      ),
                    );
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const _PhoneOtpScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Divider(color: AppColors.border),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: AppColors.border),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Dev mode
              TextButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).devLogin();
                },
                child: const Text(
                  '[DEV] Skip Signup',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.login),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'By signing up, you agree to our\nTerms of Service and Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneOtpScreen extends ConsumerStatefulWidget {
  const _PhoneOtpScreen();

  @override
  ConsumerState<_PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends ConsumerState<_PhoneOtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isLoggedIn) {
        context.go(AppRoutes.onboarding);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.navy,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter verification code',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a 6-digit code to your phone',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 8,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: '------',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.navy,
                    width: 2,
                  ),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.error, fontSize: 14),
              ),
            ],
            const SizedBox(height: 24),
            AppButton(
              text: 'Verify and Sign Up',
              isLoading: _isLoading,
              width: double.infinity,
              onPressed: () async {
                final otp = _otpController.text.trim();
                if (otp.length != 6) {
                  setState(() => _error = 'Enter 6-digit OTP');
                  return;
                }
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                try {
                  await ref.read(authProvider.notifier).verifyPhoneOtp(otp);
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                    _error = 'Invalid OTP. Try again.';
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
