import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../providers/social_accounts_provider.dart';
import '../../widgets/common/loading_widget.dart';

class SocialAccountsScreen extends ConsumerStatefulWidget {
  const SocialAccountsScreen({super.key});

  @override
  ConsumerState<SocialAccountsScreen> createState() =>
      _SocialAccountsScreenState();
}

class _SocialAccountsScreenState extends ConsumerState<SocialAccountsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(socialAccountsProvider.notifier).fetchAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(socialAccountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connected Accounts'),
      ),
      body: state.isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(socialAccountsProvider.notifier)
                    .fetchAccounts();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        state.error!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),

                  // Instagram section
                  _buildPlatformSection(
                    context,
                    platformName: 'Instagram',
                    icon: Icons.camera_alt_outlined,
                    color: const Color(0xFFE1306C),
                    connectedAccount: state.getInstagramAccount(),
                    onConnect: () async {
                      await ref
                          .read(socialAccountsProvider.notifier)
                          .connectInstagram();
                    },
                    onDisconnect: (id) async {
                      final confirmed = await _showDisconnectDialog(context);
                      if (confirmed == true) {
                        await ref
                            .read(socialAccountsProvider.notifier)
                            .disconnectAccount(id);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Facebook section
                  _buildPlatformSection(
                    context,
                    platformName: 'Facebook',
                    icon: Icons.facebook,
                    color: const Color(0xFF1877F2),
                    connectedAccount: state.getFacebookAccount(),
                    onConnect: () async {
                      await ref
                          .read(socialAccountsProvider.notifier)
                          .connectFacebook();
                    },
                    onDisconnect: (id) async {
                      final confirmed = await _showDisconnectDialog(context);
                      if (confirmed == true) {
                        await ref
                            .read(socialAccountsProvider.notifier)
                            .disconnectAccount(id);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // WhatsApp section
                  _buildWhatsappSection(context),

                  const SizedBox(height: 24),

                  // Info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Connect your social media accounts to publish posts directly from Promoto. Your account credentials are stored securely.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPlatformSection(
    BuildContext context, {
    required String platformName,
    required IconData icon,
    required Color color,
    required dynamic connectedAccount,
    required VoidCallback onConnect,
    required Function(String) onDisconnect,
  }) {
    final isConnected = connectedAccount != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        platformName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      if (isConnected)
                        Text(
                          '@${connectedAccount.platformUsername ?? connectedAccount.platformUserId}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color,
                          ),
                        )
                      else
                        Text(
                          'Not connected',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isConnected)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Connected',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.success,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (isConnected)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => onDisconnect(connectedAccount.id as String),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  child: const Text('Disconnect'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onConnect,
                  icon: Icon(icon, size: 18),
                  label: Text('Connect $platformName'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsappSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat_outlined,
                    color: Color(0xFF25D366),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WhatsApp',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Requires Business Verification',
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF25D366).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Color(0xFF25D366),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'WhatsApp Business API requires business verification through Meta. Contact support for setup assistance.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDisconnectDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disconnect Account'),
        content: const Text(
          'Are you sure you want to disconnect this account? You will need to reconnect to publish posts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}
