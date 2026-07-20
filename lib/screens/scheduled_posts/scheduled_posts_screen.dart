import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../config/app_theme.dart';
import '../../models/post_model.dart';
import '../../providers/scheduled_posts_provider.dart';
import '../../widgets/common/loading_widget.dart';

class ScheduledPostsScreen extends ConsumerStatefulWidget {
  final String? platformFilter;

  const ScheduledPostsScreen({super.key, this.platformFilter});

  @override
  ConsumerState<ScheduledPostsScreen> createState() =>
      _ScheduledPostsScreenState();
}

class _ScheduledPostsScreenState extends ConsumerState<ScheduledPostsScreen> {
  String _selectedPlatform = 'all';

  @override
  void initState() {
    super.initState();
    _selectedPlatform = widget.platformFilter ?? 'all';
    Future.microtask(() {
      ref.read(scheduledPostsProvider.notifier).fetchScheduledPosts();
    });
  }

  List<PostModel> _filterPosts(List<PostModel> posts) {
    if (_selectedPlatform == 'all') return posts;
    return posts.where((p) => p.platform == _selectedPlatform).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduledPostsProvider);
    final filteredPosts = _filterPosts(state.posts);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scheduled Posts',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          _buildPlatformFilter(),
          Expanded(
            child: state.isLoading
                ? const LoadingWidget()
                : filteredPosts.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await ref
                              .read(scheduledPostsProvider.notifier)
                              .fetchScheduledPosts();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredPosts.length,
                          itemBuilder: (context, index) {
                            return _PostCard(
                              post: filteredPosts[index],
                              onEdit: () =>
                                  _showEditDialog(filteredPosts[index]),
                              onCancel: () =>
                                  _showCancelDialog(filteredPosts[index]),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: _selectedPlatform == 'all',
            onTap: () => setState(() => _selectedPlatform = 'all'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Instagram',
            isSelected: _selectedPlatform == 'instagram',
            onTap: () => setState(() => _selectedPlatform = 'instagram'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Facebook',
            isSelected: _selectedPlatform == 'facebook',
            onTap: () => setState(() => _selectedPlatform = 'facebook'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Both',
            isSelected: _selectedPlatform == 'both',
            onTap: () => setState(() => _selectedPlatform = 'both'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 64,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          const SizedBox(height: 16),
          Text(
            'No scheduled posts',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Create a post and schedule it to see it here.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showEditDialog(PostModel post) {
    final captionController = TextEditingController(text: post.caption);
    DateTime? selectedDate = post.scheduledAt;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Post'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: captionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Caption',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Scheduled Date'),
                      subtitle: Text(
                        selectedDate != null
                            ? DateFormat('MMM dd, yyyy - hh:mm a')
                                .format(selectedDate!)
                            : 'Not set',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null && context.mounted) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                              selectedDate ?? DateTime.now(),
                            ),
                          );
                          if (time != null) {
                            setDialogState(() {
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
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final success = await ref
                        .read(scheduledPostsProvider.notifier)
                        .updatePost(
                          post.id,
                          caption: captionController.text,
                          scheduledAt: selectedDate?.toIso8601String(),
                        );
                    if (context.mounted) {
                      Navigator.pop(context);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Post updated')),
                        );
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCancelDialog(PostModel post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Post'),
          content: const Text(
            'Are you sure you want to cancel this scheduled post? This action cannot be undone.',
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
                    .read(scheduledPostsProvider.notifier)
                    .cancelPost(post.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post cancelled')),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  const _PostCard({
    required this.post,
    required this.onEdit,
    required this.onCancel,
  });

  IconData get _platformIcon {
    switch (post.platform) {
      case 'instagram':
        return Icons.camera_alt_outlined;
      case 'facebook':
        return Icons.facebook;
      case 'both':
        return Icons.public;
      default:
        return Icons.public;
    }
  }

  Color get _platformColor {
    switch (post.platform) {
      case 'instagram':
        return const Color(0xFFE1306C);
      case 'facebook':
        return const Color(0xFF1877F2);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _statusColor(BuildContext context) {
    switch (post.status) {
      case 'scheduled':
        return AppColors.navy;
      case 'draft':
        return AppColors.orange;
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
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.imageUrl!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.border.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image_outlined, size: 28),
                  ),
                ),
              )
            else
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.border.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image_outlined, size: 28),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(_platformIcon, size: 16, color: _platformColor),
                      const SizedBox(width: 4),
                      Text(
                        post.platformDisplay,
                        style: TextStyle(
                          fontSize: 12,
                          color: _platformColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _statusColor(context).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          post.statusDisplay,
                          style: TextStyle(
                            fontSize: 11,
                            color: _statusColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (post.scheduledAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy - hh:mm a')
                          .format(post.scheduledAt!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
                IconButton(
                  icon: Icon(
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
          ],
        ),
      ),
    );
  }
}
