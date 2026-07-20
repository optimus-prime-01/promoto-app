import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../providers/business_provider.dart';
import '../../providers/tab_provider.dart';
import '../../widgets/common/loading_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(businessProvider.notifier).fetchBusinesses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final businessState = ref.watch(businessProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          businessState.currentBusiness?.name ?? 'Dashboard',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: TextButton.icon(
              onPressed: () => context.push(AppRoutes.subscription),
              icon: const Icon(
                Icons.workspace_premium,
                size: 18,
                color: AppColors.orange,
              ),
              label: const Text(
                'Upgrade',
                style: TextStyle(
                  color: AppColors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.orange, width: 1),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
      body: businessState.isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(businessProvider.notifier).fetchBusinesses();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScoreCard(context, businessState),
                    const SizedBox(height: 16),
                    _buildConnectAccountsCard(context),
                    const SizedBox(height: 24),
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    Text(
                      'Scheduled Posts',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildScheduledPosts(context),
                    const SizedBox(height: 24),
                    _buildBusinessInfo(context, businessState),
                    const SizedBox(height: 24),
                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildRecentActivity(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildConnectAccountsCard(BuildContext context) {
    return Card(
      color: AppColors.orange.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: AppColors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: () => context.push(AppRoutes.socialAccounts),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.link,
                  color: AppColors.orange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connect Your Accounts',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Link Instagram, Facebook & WhatsApp to post automatically',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, BusinessState state) {
    final score = state.currentBusiness?.profileScore ?? 0;
    final normalizedScore = (score / 100).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: normalizedScore,
                    strokeWidth: 8,
                    backgroundColor: AppColors.border.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      score >= 70
                          ? AppColors.success
                          : score >= 40
                              ? AppColors.orange
                              : AppColors.error,
                    ),
                  ),
                  Center(
                    child: Text(
                      score.toInt().toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Business Score',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    score > 0
                        ? 'Your profile is ${score.toInt()}% optimized. Run an audit for detailed insights.'
                        : 'Run your first audit to get a business score.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          SizedBox(
            width: 85,
            child: _QuickActionCard(
              icon: Icons.analytics_outlined,
              label: 'Run Audit',
              color: AppColors.navy,
              onTap: () => context.push(AppRoutes.audit),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 85,
            child: _QuickActionCard(
              icon: Icons.edit_note,
              label: 'Create Post',
              color: AppColors.orange,
              onTap: () => ref.read(tabIndexProvider.notifier).state = 2,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 85,
            child: _QuickActionCard(
              icon: Icons.star_outline,
              label: 'Reviews',
              color: AppColors.success,
              onTap: () => ref.read(tabIndexProvider.notifier).state = 1,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 85,
            child: _QuickActionCard(
              icon: Icons.search,
              label: 'SEO Keywords',
              color: AppColors.navy,
              onTap: () => context.push(AppRoutes.keywords),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 85,
            child: _QuickActionCard(
              icon: Icons.people_outline,
              label: 'Competitors',
              color: AppColors.orange,
              onTap: () => context.push(AppRoutes.competitors),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 85,
            child: _QuickActionCard(
              icon: Icons.qr_code,
              label: 'QR Review',
              color: AppColors.success,
              onTap: () => context.push(AppRoutes.qrReview),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 85,
            child: _QuickActionCard(
              icon: Icons.chat_bubble_outline,
              label: 'Comments',
              color: AppColors.navy,
              onTap: () => context.push(AppRoutes.comments),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledPosts(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SchedulerCard(
            icon: Icons.chat,
            platformName: 'WhatsApp',
            color: const Color(0xFF25D366),
            onTap: () {
              context.push(AppRoutes.whatsappScheduler);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SchedulerCard(
            icon: Icons.camera_alt_outlined,
            platformName: 'Instagram',
            color: const Color(0xFFE1306C),
            onTap: () {
              context.push(AppRoutes.instagramScheduler);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SchedulerCard(
            icon: Icons.facebook,
            platformName: 'Facebook',
            color: const Color(0xFF1877F2),
            onTap: () {
              context.push(AppRoutes.facebookScheduler);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessInfo(BuildContext context, BusinessState state) {
    final business = state.currentBusiness;
    if (business == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Info',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (business.category != null)
              _buildInfoRow(Icons.category_outlined, business.category!),
            if (business.city != null)
              _buildInfoRow(Icons.location_city_outlined, business.city!),
            if (business.phone != null)
              _buildInfoRow(Icons.phone_outlined, business.phone!),
            if (business.address != null)
              _buildInfoRow(Icons.place_outlined, business.address!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).textTheme.bodyMedium?.color),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildActivityItem(
              context,
              icon: Icons.check_circle_outline,
              title: 'Account created',
              subtitle: 'Your Promoto journey has begun',
              time: 'Today',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        Text(
          time,
          style:
              Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SchedulerCard extends StatelessWidget {
  final IconData icon;
  final String platformName;
  final Color color;
  final VoidCallback onTap;

  const _SchedulerCard({
    required this.icon,
    required this.platformName,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                platformName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'No posts scheduled',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
