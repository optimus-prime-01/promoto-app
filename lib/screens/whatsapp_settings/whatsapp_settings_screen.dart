import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../providers/whatsapp_provider.dart';
import '../../widgets/common/loading_widget.dart';

class WhatsappSettingsScreen extends ConsumerStatefulWidget {
  const WhatsappSettingsScreen({super.key});

  @override
  ConsumerState<WhatsappSettingsScreen> createState() =>
      _WhatsappSettingsScreenState();
}

class _WhatsappSettingsScreenState
    extends ConsumerState<WhatsappSettingsScreen> {
  bool _birthdayOfferEnabled = true;
  int _birthdayOfferPercent = 10;
  String _birthdayMessage =
      'Happy Birthday! Enjoy {percent}% off on your next visit at {business_name}';
  bool _festivalAutoPost = true;
  bool _broadcastEnabled = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(whatsappProvider.notifier).fetchSettings();
    });
  }

  void _initFromSettings(WhatsappSettings settings) {
    if (!_isInitialized) {
      _birthdayOfferEnabled = settings.birthdayOfferEnabled;
      _birthdayOfferPercent = settings.birthdayOfferPercent;
      _birthdayMessage = settings.birthdayMessage;
      _festivalAutoPost = settings.festivalAutoPost;
      _broadcastEnabled = settings.broadcastEnabled;
      _isInitialized = true;
    }
  }

  Future<void> _saveSettings() async {
    final success =
        await ref.read(whatsappProvider.notifier).updateSettings({
      'birthdayOfferEnabled': _birthdayOfferEnabled,
      'birthdayOfferPercent': _birthdayOfferPercent,
      'birthdayMessage': _birthdayMessage,
      'festivalAutoPost': _festivalAutoPost,
      'broadcastEnabled': _broadcastEnabled,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Settings saved' : 'Failed to save settings',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(whatsappProvider);

    if (state.settings != null) {
      _initFromSettings(state.settings!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WhatsApp Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('Save'),
          ),
        ],
      ),
      body: state.isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBirthdaySection(context),
                  const SizedBox(height: 24),
                  _buildFestivalSection(context),
                  const SizedBox(height: 24),
                  _buildBroadcastSection(context),
                ],
              ),
            ),
    );
  }

  Widget _buildBirthdaySection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.cake_outlined,
                    color: AppColors.orange,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Birthday Offers',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable Birthday Offers'),
              subtitle: const Text(
                'Automatically send birthday wishes with offers',
              ),
              value: _birthdayOfferEnabled,
              onChanged: (value) {
                setState(() => _birthdayOfferEnabled = value);
              },
            ),
            if (_birthdayOfferEnabled) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Discount: $_birthdayOfferPercent%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Slider(
                value: _birthdayOfferPercent.toDouble(),
                min: 5,
                max: 50,
                divisions: 9,
                label: '$_birthdayOfferPercent%',
                onChanged: (value) {
                  setState(() => _birthdayOfferPercent = value.toInt());
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: TextEditingController(text: _birthdayMessage),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Birthday Message Template',
                  border: OutlineInputBorder(),
                  helperText:
                      'Use {percent} for discount and {business_name} for your business name',
                  helperMaxLines: 2,
                ),
                onChanged: (value) {
                  _birthdayMessage = value;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFestivalSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.navy.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.celebration_outlined,
                    color: AppColors.navy,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Festival Posts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto Festival Posts'),
              subtitle: const Text(
                'Automatically schedule messages on festivals and holidays',
              ),
              value: _festivalAutoPost,
              onChanged: (value) {
                setState(() => _festivalAutoPost = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBroadcastSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.campaign_outlined,
                    color: Color(0xFF25D366),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Broadcast',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable Broadcast'),
              subtitle: const Text(
                'Allow sending broadcast messages to all customers',
              ),
              value: _broadcastEnabled,
              onChanged: (value) {
                setState(() => _broadcastEnabled = value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
