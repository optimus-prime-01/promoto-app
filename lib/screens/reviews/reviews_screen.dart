import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../models/review_model.dart';
import '../../providers/business_provider.dart';
import '../../providers/reviews_provider.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';

class ReviewsScreen extends ConsumerStatefulWidget {
  const ReviewsScreen({super.key});

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(reviewsProvider.notifier).fetchReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewsProvider);
    final hasBusiness = ref.watch(businessProvider).currentBusiness != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
      ),
      body: !hasBusiness
          ? const EmptyWidget(
              message: 'Please set up your business first',
              icon: Icons.business_outlined,
            )
          : state.isLoading
              ? const LoadingWidget()
              : state.error != null
                  ? AppErrorWidget(
                      message: state.error!,
                      onRetry: () {
                        ref.read(reviewsProvider.notifier).fetchReviews();
                      },
                    )
                  : state.reviews.isEmpty
                      ? const EmptyWidget(
                          message:
                              'No reviews yet. Reviews from your Google Business Profile will appear here.',
                          icon: Icons.star_outline,
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await ref
                                .read(reviewsProvider.notifier)
                                .fetchReviews();
                          },
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              _buildStats(context, state),
                              const SizedBox(height: 16),
                              ...state.reviews
                                  .map((r) => _ReviewCard(review: r)),
                            ],
                          ),
                        ),
    );
  }

  Widget _buildStats(BuildContext context, ReviewsState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                label: 'Avg Rating',
                value: state.averageRating.toStringAsFixed(1),
                icon: Icons.star,
                iconColor: AppColors.orange,
              ),
            ),
            Container(width: 1, height: 40, color: Theme.of(context).dividerColor),
            Expanded(
              child: _StatItem(
                label: 'Total',
                value: state.totalReviews.toString(),
                icon: Icons.reviews_outlined,
                iconColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            Container(width: 1, height: 40, color: Theme.of(context).dividerColor),
            Expanded(
              child: _StatItem(
                label: 'Replied',
                value: '${state.responseRate.toInt()}%',
                icon: Icons.reply_outlined,
                iconColor: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
      ],
    );
  }
}

class _ReviewCard extends ConsumerStatefulWidget {
  final ReviewModel review;

  const _ReviewCard({required this.review});

  @override
  ConsumerState<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends ConsumerState<_ReviewCard> {
  final _replyController = TextEditingController();
  bool _showReplyField = false;
  bool _isPostingReply = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final isGenerating =
        ref.watch(reviewsProvider).generatingReplyForId == review.id;

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
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  child: Text(
                    review.reviewerName.isNotEmpty
                        ? review.reviewerName[0].toUpperCase()
                        : 'A',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.reviewerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatDate(review.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStars(review.rating),
              ],
            ),
            if (review.text != null && review.text!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.text!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ],
            if (review.hasReply) ...[
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
                    const Row(
                      children: [
                        Icon(Icons.reply, size: 14, color: AppColors.success),
                        SizedBox(width: 4),
                        Text(
                          'Your Reply',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      review.replyText!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (!review.hasReply) ...[
              const SizedBox(height: 12),
              if (_showReplyField) ...[
                TextField(
                  controller: _replyController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Write your reply...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _showReplyField = false);
                          _replyController.clear();
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isPostingReply ? null : _postReply,
                        child: _isPostingReply
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.white),
                                ),
                              )
                            : const Text('Post Reply'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            isGenerating ? null : () => _generateAiReply(),
                        icon: isGenerating
                            ? const SizedBox(
                                height: 14,
                                width: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.auto_awesome, size: 16),
                        label: Text(
                          isGenerating ? 'Generating...' : 'AI Reply',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _showReplyField = true);
                        },
                        icon: const Icon(Icons.reply, size: 16),
                        label: const Text('Reply'),
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

  Future<void> _generateAiReply() async {
    final reply = await ref
        .read(reviewsProvider.notifier)
        .generateAiReply(widget.review.id);
    if (reply != null && mounted) {
      setState(() {
        _showReplyField = true;
        _replyController.text = reply;
      });
    }
  }

  Future<void> _postReply() async {
    if (_replyController.text.trim().isEmpty) return;

    setState(() => _isPostingReply = true);
    final success = await ref
        .read(reviewsProvider.notifier)
        .postReply(widget.review.id, _replyController.text.trim());

    if (mounted) {
      setState(() => _isPostingReply = false);
      if (success) {
        setState(() => _showReplyField = false);
        _replyController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reply posted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to post reply')),
        );
      }
    }
  }

  Widget _buildStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 16,
          color: AppColors.orange,
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
