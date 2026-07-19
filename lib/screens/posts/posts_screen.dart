import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/app_theme.dart';
import '../../models/post_model.dart';
import '../../providers/business_provider.dart';
import '../../providers/posts_provider.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';

class PostsScreen extends ConsumerStatefulWidget {
  const PostsScreen({super.key});

  @override
  ConsumerState<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends ConsumerState<PostsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(postsProvider.notifier).fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postsProvider);
    final hasBusiness = ref.watch(businessProvider).currentBusiness != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      floatingActionButton: hasBusiness
          ? FloatingActionButton.extended(
              onPressed: () => _showCreatePostSheet(context),
              backgroundColor: AppColors.navy,
              icon: const Icon(Icons.add, color: AppColors.white),
              label: const Text('Create Post',
                  style: TextStyle(color: AppColors.white)),
            )
          : null,
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
                        ref.read(postsProvider.notifier).fetchPosts();
                      },
                    )
                  : state.posts.isEmpty
                      ? const EmptyWidget(
                          message:
                              'No posts yet. Create your first AI-generated post to boost your social presence.',
                          icon: Icons.edit_note,
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await ref.read(postsProvider.notifier).fetchPosts();
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.posts.length,
                            itemBuilder: (context, index) {
                              return _PostCard(post: state.posts[index]);
                            },
                          ),
                        ),
    );
  }

  void _showCreatePostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreatePostSheet(),
    );
  }
}

class _PostCard extends StatelessWidget {
  final PostModel post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: post.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 180,
                  color: AppColors.border,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: AppColors.border,
                  child: const Icon(Icons.image_not_supported_outlined,
                      size: 40, color: AppColors.textSecondary),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildPlatformChip(post.platform),
                    const SizedBox(width: 8),
                    _buildStatusChip(post.status),
                    const Spacer(),
                    Text(
                      _formatDate(post.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post.caption,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformChip(String platform) {
    IconData icon;
    switch (platform) {
      case 'facebook':
        icon = Icons.facebook;
        break;
      case 'instagram':
        icon = Icons.camera_alt_outlined;
        break;
      default:
        icon = Icons.public;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.navy),
          const SizedBox(width: 4),
          Text(
            PostModel(
              id: '',
              businessId: '',
              caption: '',
              platform: platform,
              status: '',
              createdAt: DateTime.now(),
            ).platformDisplay,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'published':
        color = AppColors.success;
        break;
      case 'scheduled':
        color = AppColors.orange;
        break;
      case 'failed':
        color = AppColors.error;
        break;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        PostModel(
          id: '',
          businessId: '',
          caption: '',
          platform: '',
          status: status,
          createdAt: DateTime.now(),
        ).statusDisplay,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
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

class _CreatePostSheet extends ConsumerStatefulWidget {
  const _CreatePostSheet();

  @override
  ConsumerState<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<_CreatePostSheet> {
  final _topicController = TextEditingController();
  final _captionController = TextEditingController();
  final _imagePicker = ImagePicker();
  String _selectedPlatform = 'both';
  String? _generatedImageUrl;
  File? _pickedImageFile;
  bool _isSaving = false;
  bool _isGeneratingCaption = false;

  @override
  void dispose() {
    _topicController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        _pickedImageFile = File(picked.path);
        _generatedImageUrl = null;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _pickedImageFile = null;
      _generatedImageUrl = null;
    });
  }

  Future<void> _generateAiCaption() async {
    final business = ref.read(businessProvider).currentBusiness;
    if (business == null) return;

    final topic = '${business.name} ${business.category ?? ''}'.trim();

    setState(() => _isGeneratingCaption = true);

    await ref.read(postsProvider.notifier).generatePost(topic);

    if (mounted) {
      final postsState = ref.read(postsProvider);
      if (postsState.generatedCaption != null) {
        _captionController.text = postsState.generatedCaption!;
      }
      setState(() => _isGeneratingCaption = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsProvider);

    // Update caption and image from AI-generated content
    if (postsState.generatedCaption != null &&
        _captionController.text.isEmpty &&
        !_isGeneratingCaption) {
      _captionController.text = postsState.generatedCaption!;
      if (postsState.generatedImageUrl != null && _pickedImageFile == null) {
        _generatedImageUrl = postsState.generatedImageUrl;
      }
    }

    final bool hasUserImage = _pickedImageFile != null;
    final bool hasAnyImage = hasUserImage || _generatedImageUrl != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Create Post',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),

                // Image Section
                Text('Image', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (hasAnyImage)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: hasUserImage
                            ? Image.file(
                                _pickedImageFile!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                imageUrl: _generatedImageUrl!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: 200,
                                  color: AppColors.border,
                                  child: const Center(
                                      child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 200,
                                  color: AppColors.border,
                                  child: const Icon(Icons.broken_image,
                                      color: AppColors.textSecondary),
                                ),
                              ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _removeImage,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.navy,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                size: 18, color: AppColors.white),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.navy,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Replace',
                              style: TextStyle(
                                  color: AppColors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: _pickImage,
                    child: SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _DottedBorderPainter(color: AppColors.border),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  size: 40, color: AppColors.textSecondary),
                              SizedBox(height: 8),
                              Text(
                                'Tap to upload image',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // Topic field with AI button
                Text('Topic', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _topicController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Weekend sale, New menu item...',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: postsState.isGenerating
                          ? null
                          : () {
                              if (_topicController.text.trim().isNotEmpty) {
                                ref.read(postsProvider.notifier).clearGenerated();
                                _captionController.clear();
                                ref
                                    .read(postsProvider.notifier)
                                    .generatePost(_topicController.text.trim());
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      child: postsState.isGenerating && !_isGeneratingCaption
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white),
                              ),
                            )
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome,
                                    size: 16, color: AppColors.white),
                                SizedBox(width: 4),
                                Text('AI',
                                    style: TextStyle(color: AppColors.white)),
                              ],
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Caption field
                Text('Caption',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _captionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Write your post caption...',
                  ),
                ),
                if (hasUserImage) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed:
                          _isGeneratingCaption ? null : _generateAiCaption,
                      icon: _isGeneratingCaption
                          ? const SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome, size: 16),
                      label: Text(
                        _isGeneratingCaption
                            ? 'Generating...'
                            : 'AI Caption',
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Platform selector
                Text('Platform',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PlatformOption(
                      label: 'All',
                      icon: Icons.public,
                      isSelected: _selectedPlatform == 'both',
                      onTap: () =>
                          setState(() => _selectedPlatform = 'both'),
                    ),
                    _PlatformOption(
                      label: 'Facebook',
                      icon: Icons.facebook,
                      isSelected: _selectedPlatform == 'facebook',
                      onTap: () =>
                          setState(() => _selectedPlatform = 'facebook'),
                    ),
                    _PlatformOption(
                      label: 'Instagram',
                      icon: Icons.camera_alt_outlined,
                      isSelected: _selectedPlatform == 'instagram',
                      onTap: () =>
                          setState(() => _selectedPlatform = 'instagram'),
                    ),
                    _PlatformOption(
                      label: 'WhatsApp',
                      icon: Icons.chat,
                      isSelected: _selectedPlatform == 'whatsapp',
                      onTap: () =>
                          setState(() => _selectedPlatform = 'whatsapp'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Save Draft / Publish buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () => _savePost('draft'),
                        child: const Text('Save Draft'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () => _savePost('published'),
                        child: _isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.white),
                                ),
                              )
                            : const Text('Publish Now'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _savePost(String status) async {
    if (_captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a caption')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final success = await ref.read(postsProvider.notifier).createPost(
          caption: _captionController.text.trim(),
          imageUrl: _generatedImageUrl,
          platform: _selectedPlatform,
          status: status,
        );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ref.read(postsProvider.notifier).clearGenerated();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'draft'
                ? 'Post saved as draft'
                : 'Post published successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save post')),
        );
      }
    }
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;

  _DottedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );

    final path = Path()..addRRect(rRect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, end.clamp(0, metric.length)),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlatformOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlatformOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          width: (MediaQuery.of(context).size.width - 64) / 4 - 6,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.navy.withValues(alpha: 0.1)
                : AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.navy : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20,
                  color: isSelected ? AppColors.navy : AppColors.textSecondary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.navy : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
    );
  }
}

