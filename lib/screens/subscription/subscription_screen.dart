import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_theme.dart';
import '../../providers/subscription_provider.dart';

class _PlanFeature {
  final String label;
  final String? value;
  final bool available;

  const _PlanFeature({
    required this.label,
    this.value,
    this.available = true,
  });
}

class _PlanData {
  final String id;
  final String name;
  final int pricePerMonth;
  final List<_PlanFeature> features;
  final bool isPopular;

  const _PlanData({
    required this.id,
    required this.name,
    required this.pricePerMonth,
    required this.features,
    this.isPopular = false,
  });
}

const List<_PlanData> _plans = [
  _PlanData(
    id: 'free',
    name: 'Free',
    pricePerMonth: 0,
    features: [
      _PlanFeature(label: 'Manual posts per month', value: '5'),
      _PlanFeature(label: 'AI images per month', value: '3'),
      _PlanFeature(label: 'AI review replies', value: '10'),
      _PlanFeature(label: 'Audits per month', value: '1'),
      _PlanFeature(label: 'Customer database limit', value: '10'),
      _PlanFeature(label: 'Competitor analysis', available: false),
      _PlanFeature(label: 'Auto reply', available: false),
      _PlanFeature(label: 'Auto social posting', available: false),
      _PlanFeature(label: 'WhatsApp messages', available: false),
      _PlanFeature(label: 'Festival auto-posts', available: false),
      _PlanFeature(label: 'Review requests per day', available: false),
    ],
  ),
  _PlanData(
    id: 'starter',
    name: 'Starter',
    pricePerMonth: 399,
    features: [
      _PlanFeature(label: 'Manual posts per month', value: '20'),
      _PlanFeature(label: 'AI images per month', value: '15'),
      _PlanFeature(label: 'AI review replies', value: '25'),
      _PlanFeature(label: 'Audits per month', value: '5'),
      _PlanFeature(label: 'Customer database limit', value: '100'),
      _PlanFeature(label: 'Competitor analysis', value: 'Yes'),
      _PlanFeature(label: 'Auto reply', available: false),
      _PlanFeature(label: 'Auto social posting', available: false),
      _PlanFeature(label: 'WhatsApp messages', available: false),
      _PlanFeature(label: 'Festival auto-posts', available: false),
      _PlanFeature(label: 'Review requests per day', available: false),
    ],
  ),
  _PlanData(
    id: 'growth',
    name: 'Growth',
    pricePerMonth: 799,
    isPopular: true,
    features: [
      _PlanFeature(label: 'Manual posts per month', value: 'Unlimited'),
      _PlanFeature(label: 'AI images per month', value: 'Unlimited'),
      _PlanFeature(label: 'AI review replies', value: 'Unlimited'),
      _PlanFeature(label: 'Audits per month', value: 'Unlimited'),
      _PlanFeature(label: 'Customer database limit', value: '500'),
      _PlanFeature(label: 'Competitor analysis', value: 'Yes'),
      _PlanFeature(label: 'Auto reply', value: 'Yes'),
      _PlanFeature(label: 'Auto social posting', value: 'Yes'),
      _PlanFeature(label: 'WhatsApp messages', value: '100/mo'),
      _PlanFeature(label: 'Festival auto-posts', value: 'Yes'),
      _PlanFeature(label: 'Review requests per day', value: '10'),
    ],
  ),
  _PlanData(
    id: 'agency',
    name: 'Agency',
    pricePerMonth: 1499,
    features: [
      _PlanFeature(label: 'Manual posts per month', value: 'Unlimited'),
      _PlanFeature(label: 'AI images per month', value: 'Unlimited'),
      _PlanFeature(label: 'AI review replies', value: 'Unlimited'),
      _PlanFeature(label: 'Audits per month', value: 'Unlimited'),
      _PlanFeature(label: 'Customer database limit', value: 'Unlimited'),
      _PlanFeature(label: 'Competitor analysis', value: 'Yes'),
      _PlanFeature(label: 'Auto reply', value: 'Yes'),
      _PlanFeature(label: 'Auto social posting', value: 'Yes'),
      _PlanFeature(label: 'WhatsApp messages', value: '500/mo'),
      _PlanFeature(label: 'Festival auto-posts', value: 'Yes'),
      _PlanFeature(label: 'Review requests per day', value: 'Unlimited'),
      _PlanFeature(label: 'Businesses supported', value: '15'),
    ],
  ),
];

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(subscriptionProvider.notifier).fetchCurrentSubscription();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleUpgrade(String planId) async {
    final result = await ref
        .read(subscriptionProvider.notifier)
        .createSubscription(planId);

    if (result != null && mounted) {
      final paymentUrl = result['paymentUrl'] as String?;
      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        final uri = Uri.parse(paymentUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else if (mounted) {
      final error = ref.read(subscriptionProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to process subscription'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(subscriptionProvider);
    final currentPlan = subState.currentPlan ?? 'free';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'Scale your business with the right plan',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          // Page indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_plans.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.navy
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Plan cards
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _plans.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final plan = _plans[index];
                final isCurrent = currentPlan == plan.id;
                return _PlanCard(
                  plan: plan,
                  isCurrent: isCurrent,
                  isUpgrading: subState.isUpgrading,
                  onUpgrade: () => _handleUpgrade(plan.id),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final _PlanData plan;
  final bool isCurrent;
  final bool isUpgrading;
  final VoidCallback onUpgrade;

  const _PlanCard({
    required this.plan,
    required this.isCurrent,
    required this.isUpgrading,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCurrent
                    ? AppColors.orange
                    : plan.isPopular
                        ? AppColors.navy
                        : AppColors.border,
                width: isCurrent || plan.isPopular ? 2.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.orange.withValues(alpha: 0.06)
                        : plan.isPopular
                            ? AppColors.navy.withValues(alpha: 0.04)
                            : Colors.transparent,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Rs ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: plan.pricePerMonth.toString(),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (plan.pricePerMonth > 0)
                              const TextSpan(
                                text: '/mo',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Features
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: plan.features.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final feature = plan.features[index];
                      return _FeatureRow(feature: feature);
                    },
                  ),
                ),
                // Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: isCurrent
                        ? OutlinedButton(
                            onPressed: null,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Current Plan',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: isUpgrading ? null : onUpgrade,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: plan.isPopular
                                  ? AppColors.orange
                                  : AppColors.navy,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isUpgrading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : Text(
                                    plan.pricePerMonth == 0
                                        ? 'Get Started'
                                        : 'Upgrade',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          // Popular badge
          if (plan.isPopular)
            Positioned(
              top: -12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.orange.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Most Popular',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final _PlanFeature feature;

  const _FeatureRow({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          feature.available ? Icons.check_circle : Icons.cancel,
          size: 18,
          color: feature.available ? AppColors.success : AppColors.border,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            feature.label,
            style: TextStyle(
              fontSize: 13,
              color: feature.available
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ),
        if (feature.value != null && feature.available)
          Text(
            feature.value!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.navy,
            ),
          ),
      ],
    );
  }
}
