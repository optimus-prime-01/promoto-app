import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../config/app_theme.dart';
import '../../models/comment_model.dart';
import '../../providers/comments_provider.dart';
import '../../widgets/common/loading_widget.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({super.key});

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(commentsProvider.notifier).fetchComments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Comments',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: state.isLoading
          ? const LoadingWidget()
          : state.comments.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(commentsProvider.notifier)
                        .fetchComments();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.comments.length,
                    itemBuilder: (context, index) {
                      return _CommentCard(
                        comment: state.comments[index],
                        onGenerateReply: () =>
                            _handleGenerateReply(state.comments[index]),
                        onPostReply: (text) =>
                            _handlePostReply(state.comments[index], text),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          const SizedBox(height: 16),
          Text(
            'No comments yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Comments on your posts will appear here.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Future<void> _handleGenerateReply(CommentModel comment) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating AI reply...')),
    );
    final reply =
        await ref.read(commentsProvider.notifier).generateReply(comment.id);
    if (mounted) {
      if (reply != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI reply generated')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate reply')),
        );
      }
    }
  }

  Future<void> _handlePostReply(CommentModel comment, String text) async {
    final success =
        await ref.read(commentsProvider.notifier).postReply(comment.id, text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Reply posted' : 'Failed to post reply'),
        ),
      );
    }
  }
}

class _CommentCard extends StatefulWidget {
  final CommentModel comment;
  final VoidCallback onGenerateReply;
  final void Function(String text) onPostReply;

  const _CommentCard({
    required this.comment,
    required this.onGenerateReply,
    required this.onPostReply,
  });

  @override
  State<_CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<_CommentCard> {
  late TextEditingController _replyController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _replyController = TextEditingController(
      text: widget.comment.replyText ?? widget.comment.aiSuggestedReply ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant _CommentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.comment.aiSuggestedReply !=
        widget.comment.aiSuggestedReply) {
      _replyController.text =
          widget.comment.aiSuggestedReply ?? _replyController.text;
      _isEditing = true;
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    final hasReply = comment.replyText != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      AppColors.navy.withValues(alpha: 0.15),
                  child: Text(
                    comment.authorName.isNotEmpty
                        ? comment.authorName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(comment.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasReply)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Replied',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              comment.text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (hasReply) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Reply',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.replyText!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
            if (!hasReply) ...[
              const SizedBox(height: 12),
              if (_isEditing) ...[
                TextField(
                  controller: _replyController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Reply',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          _replyController.clear();
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        if (_replyController.text.trim().isNotEmpty) {
                          widget.onPostReply(_replyController.text.trim());
                        }
                      },
                      child: const Text('Post Reply'),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: widget.onGenerateReply,
                      icon: const Icon(Icons.auto_awesome_outlined, size: 16),
                      label: const Text('AI Reply'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _isEditing = true);
                      },
                      icon: const Icon(Icons.reply_outlined, size: 16),
                      label: const Text('Reply'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
