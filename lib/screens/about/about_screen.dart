import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_theme.dart';
import '../../widgets/common/promoto_logo.dart' show PromoToLogo;

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@promoto.app',
      query: 'subject=Promoto App Support',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAppInfo(context),
          const SizedBox(height: 24),
          _buildHowItWorks(context),
          const SizedBox(height: 24),
          _buildFaq(context),
          const SizedBox(height: 24),
          _buildLinks(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const PromoToLogo(size: 60),
            const SizedBox(height: 12),
            Text(
              'Promoto',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'AI Marketing for Local Businesses',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.navy,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How It Works',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        _buildStepCard(
          context,
          number: '1',
          title: 'Set Up Your Business',
          description:
              'Add your business details and connect your Google Business Profile.',
        ),
        _buildStepCard(
          context,
          number: '2',
          title: 'Run a Google Score Audit',
          description:
              'Get an AI-powered analysis of your online presence with actionable suggestions.',
        ),
        _buildStepCard(
          context,
          number: '3',
          title: 'Optimize & Grow',
          description:
              'Use AI review replies, SEO keywords, social posts, and competitor insights to grow your business.',
        ),
        _buildStepCard(
          context,
          number: '4',
          title: 'Track Progress',
          description:
              'Monitor your score improvements and customer engagement over time.',
        ),
      ],
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required String number,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
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

  Widget _buildFaq(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _buildFaqTile(
                question: 'How does AI review reply work?',
                answer:
                    'When a customer leaves a review on your Google Business Profile, our AI analyzes the review content, sentiment, and context to generate a professional, personalized reply. You can edit the reply before posting or enable auto-reply to respond automatically.',
              ),
              const Divider(height: 1),
              _buildFaqTile(
                question: 'What is Google Score Audit?',
                answer:
                    'Google Score Audit analyzes your Google Business Profile across 5 categories: profile completeness, reviews, posts, response rate, and SEO keywords. It gives you an overall score out of 100 and AI-generated suggestions to improve your ranking.',
              ),
              const Divider(height: 1),
              _buildFaqTile(
                question: 'How to upgrade my plan?',
                answer:
                    'Go to Profile > Subscription to see available plans. You can upgrade from Free to Starter, Growth, or Agency plan. Payments are processed securely through Razorpay. You can cancel anytime.',
              ),
              const Divider(height: 1),
              _buildFaqTile(
                question: 'How to contact support?',
                answer:
                    'You can reach our support team by email at support@promoto.app. We typically respond within 24 hours on business days.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFaqTile({
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          answer,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legal & Support',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        _buildLinkTile(
          icon: Icons.email_outlined,
          title: 'Contact Support',
          subtitle: 'support@promoto.app',
          onTap: _launchEmail,
        ),
        _buildLinkTile(
          icon: Icons.description_outlined,
          title: 'Terms of Service',
          subtitle: 'Read our terms and conditions',
          onTap: () => _launchUrl('https://promoto.app/terms'),
        ),
        _buildLinkTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          subtitle: 'How we handle your data',
          onTap: () => _launchUrl('https://promoto.app/privacy'),
        ),
      ],
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.navy),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
