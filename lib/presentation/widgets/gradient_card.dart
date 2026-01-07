import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Gradient card widget for displaying balance with teal gradient
class GradientCard extends StatelessWidget {
  final String amount;
  final String currency;
  final String emoji;
  final String? subtitle;
  final Gradient gradient;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.amount,
    this.currency = 'PKR',
    this.emoji = '😊',
    this.subtitle,
    this.gradient = AppColors.tealGradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.spacing24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  color: AppColors.textWhite.withOpacity(0.9),
                  fontSize: AppConstants.fontMedium,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (subtitle != null) const SizedBox(height: AppConstants.spacing8),
            Row(
              children: [
                Text(
                  currency,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: AppConstants.fontLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing8),
                Text(
                  amount,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
