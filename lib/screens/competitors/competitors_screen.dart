import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../providers/business_provider.dart';
import '../../providers/competitors_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/error_widget.dart';

class CompetitorsScreen extends ConsumerWidget {
  const CompetitorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final competitorsState = ref.watch(competitorsProvider);
    final businessState = ref.watch(businessProvider);
    final hasBusiness = businessState.currentBusiness != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Competitors'),
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
                  _buildAnalyzeSection(context, ref, competitorsState),
                  if (competitorsState.error != null) ...[
                    const SizedBox(height: 16),
                    AppErrorWidget(
                      message: competitorsState.error!,
                      onRetry: () {
                        ref
                            .read(competitorsProvider.notifier)
                            .analyzeCompetitors();
                      },
                    ),
                  ],
                  if (competitorsState.competitors.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildComparisonCard(context, businessState, competitorsState),
                    const SizedBox(height: 24),
                    Text(
                      'Nearby Competitors',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ...competitorsState.competitors.map(
                      (c) => _buildCompetitorCard(context, c),
                    ),
                  ],
                  if (competitorsState.competitors.isEmpty &&
                      !competitorsState.isLoading &&
                      competitorsState.error == null) ...[
                    const SizedBox(height: 48),
                    const EmptyWidget(
                      message:
                          'Analyze competitors near your business to understand the local market.',
                      icon: Icons.people_outline,
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildAnalyzeSection(
    BuildContext context,
    WidgetRef ref,
    CompetitorsState state,
  ) {
    final radiusKm = state.radius / 1000;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Competitor Analysis',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Find businesses similar to yours in the selected radius.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search Radius',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.navy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${radiusKm.toStringAsFixed(0)} km',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: radiusKm,
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: AppColors.navy,
              inactiveColor: AppColors.border,
              label: '${radiusKm.toStringAsFixed(0)} km',
              onChanged: (value) {
                ref
                    .read(competitorsProvider.notifier)
                    .setRadius((value * 1000).toInt());
              },
            ),
            const SizedBox(height: 8),
            AppButton(
              text:
                  state.isLoading ? 'Analyzing...' : 'Analyze Competitors',
              isLoading: state.isLoading,
              icon: Icons.search,
              width: double.infinity,
              onPressed: state.isLoading
                  ? null
                  : () {
                      ref
                          .read(competitorsProvider.notifier)
                          .analyzeCompetitors();
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard(
    BuildContext context,
    BusinessState businessState,
    CompetitorsState competitorsState,
  ) {
    final business = businessState.currentBusiness;
    if (business == null) return const SizedBox.shrink();

    final competitors = competitorsState.competitors;
    final avgRating = competitors.isNotEmpty
        ? competitors.map((c) => c.rating).reduce((a, b) => a + b) /
            competitors.length
        : 0.0;
    final avgReviews = competitors.isNotEmpty
        ? competitors.map((c) => c.reviewCount).reduce((a, b) => a + b) ~/
            competitors.length
        : 0;

    return Card(
      color: AppColors.navy.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Business vs Competitors',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildComparisonColumn(
                    context,
                    label: 'You',
                    name: business.name,
                    score: business.profileScore,
                    isYou: true,
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: AppColors.border,
                ),
                Expanded(
                  child: _buildComparisonColumn(
                    context,
                    label: 'Avg Competitor',
                    name: '${competitors.length} found',
                    score: avgRating * 20,
                    isYou: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Score: ${business.profileScore.toInt()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Avg Rating: ${avgRating.toStringAsFixed(1)} | Reviews: $avgReviews',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonColumn(
    BuildContext context, {
    required String label,
    required String name,
    required double score,
    required bool isYou,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isYou ? AppColors.navy : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            value: (score / 100).clamp(0.0, 1.0),
            strokeWidth: 5,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              isYou ? AppColors.navy : AppColors.orange,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompetitorCard(BuildContext context, CompetitorModel competitor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.store_outlined,
                color: AppColors.orange,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    competitor.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    competitor.category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildStarRating(competitor.rating),
                      const SizedBox(width: 6),
                      Text(
                        competitor.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${competitor.reviewCount} reviews)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.navy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${(competitor.distance / 1000).toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, size: 14, color: AppColors.orange);
        } else if (index < rating) {
          return const Icon(Icons.star_half, size: 14, color: AppColors.orange);
        } else {
          return Icon(
            Icons.star_border,
            size: 14,
            color: AppColors.orange.withValues(alpha: 0.4),
          );
        }
      }),
    );
  }
}
