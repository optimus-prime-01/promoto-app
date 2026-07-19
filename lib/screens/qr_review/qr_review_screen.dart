import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/app_theme.dart';
import '../../providers/business_provider.dart';
import '../../widgets/common/empty_widget.dart';

class QrReviewScreen extends ConsumerWidget {
  const QrReviewScreen({super.key});

  String _getGoogleReviewUrl(String? placeId, String businessName) {
    if (placeId != null && placeId.isNotEmpty) {
      return 'https://search.google.com/local/writereview?placeid=$placeId';
    }
    // Fallback: search URL using business name
    final encodedName = Uri.encodeComponent(businessName);
    return 'https://www.google.com/search?q=$encodedName+reviews';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessState = ref.watch(businessProvider);
    final business = businessState.currentBusiness;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review QR Code'),
      ),
      body: business == null
          ? const EmptyWidget(
              message: 'Please set up your business first',
              icon: Icons.business_outlined,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildQrCodeSection(context, business.name,
                      _getGoogleReviewUrl(null, business.name)),
                  const SizedBox(height: 24),
                  _buildActionButtons(context, business.name,
                      _getGoogleReviewUrl(null, business.name)),
                  const SizedBox(height: 24),
                  _buildInstructions(context),
                  const SizedBox(height: 24),
                  _buildHowItWorks(context),
                ],
              ),
            ),
    );
  }

  Widget _buildQrCodeSection(
      BuildContext context, String businessName, String reviewUrl) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              businessName,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Scan to leave a Google review',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: QrImageView(
                data: reviewUrl,
                version: QrVersions.auto,
                size: 220,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.navy,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.navy,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SelectableText(
              reviewUrl,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, String businessName, String reviewUrl) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Share.share(
                'Leave a review for $businessName: $reviewUrl',
              );
            },
            icon: const Icon(Icons.share, size: 20),
            label: const Text('Share QR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Take a screenshot to save the QR code as an image'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.download, size: 20),
            label: const Text('Save QR'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.navy,
              side: const BorderSide(color: AppColors.navy),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return Card(
      color: AppColors.orange.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.print_outlined,
                  color: AppColors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Print & Display',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.orange,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Print this QR code and place it at your shop counter, billing desk, or waiting area. Customers can scan it with their phone camera to leave a Google review instantly.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorks(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How It Works',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildStep(
              context,
              number: '1',
              title: 'Customers scan the QR code',
              subtitle: 'Using their phone camera or QR scanner app',
            ),
            _buildStep(
              context,
              number: '2',
              title: 'They leave a Google review',
              subtitle: 'Taken directly to your Google review page',
            ),
            _buildStep(
              context,
              number: '3',
              title: 'Your rating improves',
              subtitle: 'More reviews help your business rank higher locally',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String number,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
