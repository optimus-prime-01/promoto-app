import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../models/audit_model.dart';
import '../../providers/audit_provider.dart';
import '../../providers/business_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';

class AuditScreen extends ConsumerStatefulWidget {
  const AuditScreen({super.key});

  @override
  ConsumerState<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends ConsumerState<AuditScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(auditProvider.notifier).fetchAudits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auditState = ref.watch(auditProvider);
    final hasBusiness = ref.watch(businessProvider).currentBusiness != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Audit'),
      ),
      body: !hasBusiness
          ? const EmptyWidget(
              message: 'Please set up your business first',
              icon: Icons.business_outlined,
            )
          : auditState.isLoading
              ? const LoadingWidget()
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(auditProvider.notifier).fetchAudits();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRunAuditSection(context, auditState),
                        if (auditState.error != null) ...[
                          const SizedBox(height: 16),
                          AppErrorWidget(
                            message: auditState.error!,
                            onRetry: () {
                              ref.read(auditProvider.notifier).fetchAudits();
                            },
                          ),
                        ],
                        if (auditState.latestAudit != null) ...[
                          const SizedBox(height: 24),
                          _buildScoreOverview(
                              context, auditState.latestAudit!),
                          const SizedBox(height: 24),
                          _buildCategoryScores(
                              context, auditState.latestAudit!),
                          const SizedBox(height: 24),
                          _buildSuggestions(
                              context, auditState.latestAudit!),
                        ],
                        if (auditState.auditHistory.length > 1) ...[
                          const SizedBox(height: 24),
                          _buildAuditHistory(context, auditState),
                        ],
                        if (auditState.latestAudit == null &&
                            auditState.error == null &&
                            !auditState.isRunning) ...[
                          const SizedBox(height: 48),
                          const EmptyWidget(
                            message:
                                'No audits yet. Run your first audit to see how your business is performing online.',
                            icon: Icons.analytics_outlined,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildRunAuditSection(BuildContext context, AuditState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 12),
            Text(
              'Google Business Profile Audit',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Analyze your online presence and get AI-powered suggestions to improve.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AppButton(
              text: state.isRunning ? 'Running Audit...' : 'Run Audit',
              isLoading: state.isRunning,
              icon: Icons.play_arrow,
              width: double.infinity,
              onPressed: state.isRunning
                  ? null
                  : () {
                      ref.read(auditProvider.notifier).runAudit();
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreOverview(BuildContext context, AuditModel audit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Overall Score',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: (audit.overallScore / 100).clamp(0.0, 1.0),
                    strokeWidth: 10,
                    backgroundColor: Theme.of(context).dividerColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getScoreColor(audit.overallScore),
                    ),
                  ),
                  Center(
                    child: Text(
                      audit.overallScore.toInt().toString(),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getScoreLabel(audit.overallScore),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _getScoreColor(audit.overallScore),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryScores(BuildContext context, AuditModel audit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildScoreBar(context, 'Profile Completeness',
                audit.completenessScore),
            _buildScoreBar(context, 'Reviews', audit.reviewScore),
            _buildScoreBar(context, 'Posts & Activity', audit.postScore),
            _buildScoreBar(
                context, 'Response Rate', audit.responseScore),
            _buildScoreBar(context, 'Keywords & SEO', audit.keywordScore),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBar(BuildContext context, String label, double score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                '${score.toInt()}/100',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _getScoreColor(score),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (score / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Theme.of(context).dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getScoreColor(score),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context, AuditModel audit) {
    if (audit.suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Suggestions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...audit.suggestions.map(
          (s) => _SuggestionCard(suggestion: s),
        ),
      ],
    );
  }

  Widget _buildAuditHistory(BuildContext context, AuditState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audit History',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...state.auditHistory.skip(1).take(5).map(
              (audit) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getScoreColor(audit.overallScore)
                        .withValues(alpha: 0.15),
                    child: Text(
                      audit.overallScore.toInt().toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _getScoreColor(audit.overallScore),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  title: Text(
                    'Score: ${audit.overallScore.toInt()}/100',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    _formatDate(audit.createdAt),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 70) return AppColors.success;
    if (score >= 40) return AppColors.orange;
    return AppColors.error;
  }

  String _getScoreLabel(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Needs Improvement';
    return 'Poor';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SuggestionCard extends StatefulWidget {
  final AuditSuggestion suggestion;

  const _SuggestionCard({required this.suggestion});

  @override
  State<_SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<_SuggestionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.suggestion.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.orange,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 12),
                Text(
                  widget.suggestion.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
