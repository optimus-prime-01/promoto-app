import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../providers/whatsapp_provider.dart';
import '../../widgets/common/loading_widget.dart';

class WhatsappSchedulerScreen extends ConsumerStatefulWidget {
  const WhatsappSchedulerScreen({super.key});

  @override
  ConsumerState<WhatsappSchedulerScreen> createState() =>
      _WhatsappSchedulerScreenState();
}

class _WhatsappSchedulerScreenState
    extends ConsumerState<WhatsappSchedulerScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(whatsappProvider.notifier).fetchMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(whatsappProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WhatsApp',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.whatsappSettings),
            tooltip: 'WhatsApp Settings',
          ),
        ],
      ),
      body: state.isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(whatsappProvider.notifier).fetchMessages();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    Text(
                      'Upcoming Messages',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildMessagesList(context, state),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        _QuickActionCard(
          icon: Icons.campaign_outlined,
          title: 'Broadcast Message',
          subtitle: 'Send a message to all customers',
          color: const Color(0xFF25D366),
          onTap: () => _showBroadcastSheet(context),
        ),
        const SizedBox(height: 10),
        _QuickActionCard(
          icon: Icons.cake_outlined,
          title: 'Birthday Wishes',
          subtitle: 'Auto-wish customers on their birthday',
          color: AppColors.orange,
          onTap: () => context.push(AppRoutes.whatsappSettings),
        ),
        const SizedBox(height: 10),
        _QuickActionCard(
          icon: Icons.celebration_outlined,
          title: 'Festival / Offer',
          subtitle: 'Create a festival or offer message',
          color: AppColors.navy,
          onTap: () => _showOfferSheet(context),
        ),
      ],
    );
  }

  Widget _buildMessagesList(BuildContext context, WhatsappState state) {
    final scheduledMessages = state.messages
        .where((m) => m.status == 'scheduled')
        .toList();

    if (scheduledMessages.isEmpty && state.messages.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.chat_outlined,
                  size: 48,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                const SizedBox(height: 12),
                Text(
                  'No messages yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Schedule a broadcast or offer message to get started.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        return _MessageCard(
          message: message,
          onCancel: message.status == 'scheduled'
              ? () => _showCancelDialog(message)
              : null,
        );
      },
    );
  }

  void _showBroadcastSheet(BuildContext context) {
    final messageController = TextEditingController(
      text:
          'Hello! We have exciting news for you. Visit us today for special offers!',
    );
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Broadcast Message',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: messageController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Schedule Date & Time'),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy - hh:mm a')
                          .format(selectedDate),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null && context.mounted) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime:
                              TimeOfDay.fromDateTime(selectedDate),
                        );
                        if (time != null) {
                          setSheetState(() {
                            selectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final success = await ref
                            .read(whatsappProvider.notifier)
                            .createMessage(
                              type: 'broadcast',
                              message: messageController.text,
                              targetAudience: 'all_customers',
                              scheduledAt: selectedDate.toIso8601String(),
                            );
                        if (context.mounted) {
                          Navigator.pop(context);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Broadcast scheduled'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Schedule Broadcast'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showOfferSheet(BuildContext context) {
    final messageController = TextEditingController(
      text:
          'Special offer just for you! Get an exclusive discount on your next visit.',
    );
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Festival / Offer Message',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: messageController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Schedule Date & Time'),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy - hh:mm a')
                          .format(selectedDate),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null && context.mounted) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime:
                              TimeOfDay.fromDateTime(selectedDate),
                        );
                        if (time != null) {
                          setSheetState(() {
                            selectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final success = await ref
                            .read(whatsappProvider.notifier)
                            .createMessage(
                              type: 'offer',
                              message: messageController.text,
                              targetAudience: 'all_customers',
                              scheduledAt: selectedDate.toIso8601String(),
                            );
                        if (context.mounted) {
                          Navigator.pop(context);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Offer message scheduled'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Schedule Message'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCancelDialog(WhatsappMessage message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Message'),
          content: const Text(
            'Are you sure you want to cancel this scheduled message? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No, Keep It'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              onPressed: () async {
                final success = await ref
                    .read(whatsappProvider.notifier)
                    .cancelMessage(message.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Message cancelled')),
                    );
                  }
                }
              },
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final WhatsappMessage message;
  final VoidCallback? onCancel;

  const _MessageCard({
    required this.message,
    this.onCancel,
  });

  Color _statusColor() {
    switch (message.status) {
      case 'scheduled':
        return AppColors.navy;
      case 'sent':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      case 'cancelled':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _typeColor() {
    switch (message.type) {
      case 'broadcast':
        return const Color(0xFF25D366);
      case 'birthday':
        return AppColors.orange;
      case 'festival':
        return AppColors.navy;
      case 'offer':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _typeColor().withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.chat,
                color: _typeColor(),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _typeColor().withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          message.typeDisplay,
                          style: TextStyle(
                            fontSize: 11,
                            color: _typeColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor().withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          message.statusDisplay,
                          style: TextStyle(
                            fontSize: 11,
                            color: _statusColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy - hh:mm a')
                        .format(message.scheduledAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
            if (onCancel != null)
              IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 20,
                  color: AppColors.error,
                ),
                onPressed: onCancel,
                tooltip: 'Cancel',
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
