import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/automation_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/loading_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(automationProvider.notifier).fetchSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final automationState = ref.watch(automationProvider);
    final businessState = ref.watch(businessProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                    child: Text(
                      authState.user?.name.isNotEmpty == true
                          ? authState.user!.name[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.user?.name ?? 'User',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          authState.user?.email ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (authState.user?.phone != null &&
                            authState.user!.phone!.isNotEmpty)
                          Text(
                            authState.user!.phone!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Business info
          if (businessState.currentBusiness != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      businessState.currentBusiness!.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (businessState.currentBusiness!.category != null)
                      Text(
                        businessState.currentBusiness!.category!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
            ),
          ],

          // Automation settings
          const SizedBox(height: 24),
          Text(
            'Automation Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          if (automationState.isLoading)
            const LoadingWidget(itemCount: 2)
          else ...[
            Card(
              child: Column(
                children: [
                  _buildToggle(
                    context,
                    title: 'Auto Reply Reviews',
                    subtitle: 'Automatically reply to new reviews with AI',
                    value: automationState.settings.autoReplyReviews,
                    onChanged: (val) {
                      ref
                          .read(automationProvider.notifier)
                          .updateSetting('autoReplyReviews', val);
                    },
                  ),
                  const Divider(height: 1),
                  _buildToggle(
                    context,
                    title: 'Auto Post Social',
                    subtitle: 'Automatically generate and post content',
                    value: automationState.settings.autoPostSocial,
                    onChanged: (val) {
                      ref
                          .read(automationProvider.notifier)
                          .updateSetting('autoPostSocial', val);
                    },
                  ),
                  const Divider(height: 1),
                  _buildToggle(
                    context,
                    title: 'Auto Birthday Wishes',
                    subtitle: 'Send birthday greetings to customers',
                    value: automationState.settings.autoBirthdayWishes,
                    onChanged: (val) {
                      ref
                          .read(automationProvider.notifier)
                          .updateSetting('autoBirthdayWishes', val);
                    },
                  ),
                  const Divider(height: 1),
                  _buildToggle(
                    context,
                    title: 'Auto Weekly Report',
                    subtitle: 'Receive weekly performance reports',
                    value: automationState.settings.autoWeeklyReport,
                    onChanged: (val) {
                      ref
                          .read(automationProvider.notifier)
                          .updateSetting('autoWeeklyReport', val);
                    },
                  ),
                  const Divider(height: 1),
                  _buildToggle(
                    context,
                    title: 'Auto Festival Posts',
                    subtitle: 'Post greetings on festivals automatically',
                    value: automationState.settings.autoFestivalPosts,
                    onChanged: (val) {
                      ref
                          .read(automationProvider.notifier)
                          .updateSetting('autoFestivalPosts', val);
                    },
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Other options
          _buildMenuItem(
            context,
            icon: Icons.link,
            title: 'Connected Accounts',
            onTap: () => context.push(AppRoutes.socialAccounts),
          ),
          _buildMenuItem(
            context,
            icon: Icons.edit_outlined,
            title: 'Edit Business',
            onTap: () => context.push(AppRoutes.editBusiness),
          ),
          _buildMenuItem(
            context,
            icon: Icons.share_outlined,
            title: 'Share Promoto',
            onTap: () {
              Share.share(
                'Try Promoto - AI Marketing for your local business. Download now: https://promoto.com',
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.credit_card_outlined,
            title: 'Subscription',
            onTap: () => context.push(AppRoutes.subscription),
          ),
          _buildMenuItem(
            context,
            icon: Icons.qr_code,
            title: 'Review QR Code',
            onTap: () => context.push(AppRoutes.qrReview),
          ),
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () => context.push(AppRoutes.about),
          ),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: 'About',
            onTap: () => context.push(AppRoutes.about),
          ),

          const SizedBox(height: 16),

          // Theme
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildThemeOption(
                    context,
                    ref,
                    'Light',
                    Icons.light_mode,
                    ThemeMode.light,
                  ),
                  _buildThemeOption(
                    context,
                    ref,
                    'Dark',
                    Icons.dark_mode,
                    ThemeMode.dark,
                  ),
                  _buildThemeOption(
                    context,
                    ref,
                    'System',
                    Icons.settings_brightness,
                    ThemeMode.system,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Delete Account
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.error),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () => _showDeleteAccountDialog(context, ref),
          ),

          // Sign out
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure? This will permanently delete your account and all data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final apiService = ref.read(apiServiceProvider);
        await apiService.delete('/users/me');
        await ref.read(authProvider.notifier).signOut();
        if (context.mounted) {
          context.go(AppRoutes.login);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete account')),
          );
        }
      }
    }
  }

  Widget _buildToggle(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
      ),
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppColors.orange.withValues(alpha: 0.5),
      activeThumbColor: AppColors.orange,
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: Icon(Icons.chevron_right, color: Theme.of(context).textTheme.bodyMedium?.color),
      onTap: onTap,
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    ThemeMode mode,
  ) {
    final currentMode = ref.watch(themeProvider);
    final isSelected = currentMode == mode;

    return RadioListTile<ThemeMode>(
      value: mode,
      groupValue: currentMode,
      onChanged: (value) {
        if (value != null) {
          ref.read(themeProvider.notifier).setTheme(value);
        }
      },
      title: Text(label, style: const TextStyle(fontSize: 14)),
      secondary: Icon(
        icon,
        color: isSelected ? AppColors.orange : AppColors.textSecondary,
        size: 20,
      ),
      activeColor: AppColors.orange,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
