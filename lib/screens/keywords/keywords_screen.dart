import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../providers/business_provider.dart';
import '../../providers/keywords_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/error_widget.dart';

class KeywordsScreen extends ConsumerStatefulWidget {
  const KeywordsScreen({super.key});

  @override
  ConsumerState<KeywordsScreen> createState() => _KeywordsScreenState();
}

class _KeywordsScreenState extends ConsumerState<KeywordsScreen> {
  final _categoryController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final business = ref.read(businessProvider).currentBusiness;
    if (business != null) {
      _categoryController.text = business.category ?? '';
      _cityController.text = business.city ?? '';
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _generateKeywords() {
    ref.read(keywordsProvider.notifier).generateKeywords(
          category: _categoryController.text,
          city: _cityController.text,
        );
  }

  void _copyKeyword(String keyword) {
    Clipboard.setData(ClipboardData(text: keyword));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $keyword'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keywordsState = ref.watch(keywordsProvider);
    final hasBusiness = ref.watch(businessProvider).currentBusiness != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SEO Keywords'),
      ),
      body: !hasBusiness
          ? const EmptyWidget(
              message: 'Please set up your business first',
              icon: Icons.business_outlined,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGenerateSection(context, keywordsState),
                  if (keywordsState.error != null) ...[
                    const SizedBox(height: 16),
                    AppErrorWidget(
                      message: keywordsState.error!,
                      onRetry: _generateKeywords,
                    ),
                  ],
                  if (keywordsState.keywords.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildKeywordsSection(context, keywordsState.keywords),
                  ],
                  if (keywordsState.keywords.isEmpty &&
                      !keywordsState.isLoading &&
                      keywordsState.error == null) ...[
                    const SizedBox(height: 48),
                    const EmptyWidget(
                      message:
                          'Generate SEO keywords to optimize your Google Business Profile and improve local search rankings.',
                      icon: Icons.search,
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildTipsSection(context),
                ],
              ),
            ),
    );
  }

  Widget _buildGenerateSection(BuildContext context, KeywordsState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generate SEO Keywords',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'AI will generate location-specific keywords for your business.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Business Category',
                hintText: 'e.g. Restaurant, Salon, Clinic',
                prefixIcon: Icon(Icons.category_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                hintText: 'e.g. Mumbai, Delhi, Bangalore',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: state.isLoading ? 'Generating...' : 'Generate Keywords',
              isLoading: state.isLoading,
              icon: Icons.auto_awesome,
              width: double.infinity,
              onPressed: state.isLoading ? null : _generateKeywords,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeywordsSection(BuildContext context, List<String> keywords) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Generated Keywords',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '${keywords.length} keywords',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Tap any keyword to copy it',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: keywords.map((keyword) {
            return InkWell(
              onTap: () => _copyKeyword(keyword),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.navy.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      keyword,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.copy,
                      size: 14,
                      color: AppColors.navy.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTipsSection(BuildContext context) {
    return Card(
      color: AppColors.orange.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.orange,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              'Use these keywords in your Google Business Profile description',
            ),
            _buildTipItem(
              'Add relevant keywords to your business posts and updates',
            ),
            _buildTipItem(
              'Include location-specific terms to rank higher in local searches',
            ),
            _buildTipItem(
              'Update keywords periodically to stay relevant with search trends',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(
              Icons.circle,
              size: 6,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
