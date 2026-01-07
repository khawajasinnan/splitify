import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Group card widget for displaying group info in a list
class GroupCard extends StatelessWidget {
  final String groupName;
  final String? groupEmoji;
  final String amount;
  final String currency;
  final bool youOwe;
  final VoidCallback? onTap;
  final VoidCallback? onMarkPaid;
  final String? subtitle;

  const GroupCard({
    super.key,
    required this.groupName,
    this.groupEmoji,
    required this.amount,
    this.currency = 'PKR',
    this.youOwe = false,
    this.onTap,
    this.onMarkPaid,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Group Icon/Emoji
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.darkNavyLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  groupEmoji ?? '👥',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacing12),
            
            // Group Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupName,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: AppConstants.fontLarge,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.8),
                        fontSize: AppConstants.fontSmall,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        youOwe ? 'You owe' : 'You are owed',
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.9),
                          fontSize: AppConstants.fontSmall,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$currency $amount',
                        style: TextStyle(
                          color: youOwe ? AppColors.accentOrange : AppColors.successGreen,
                          fontSize: AppConstants.fontMedium,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Mark Paid Button
            if (onMarkPaid != null)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.accentOrange,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onMarkPaid,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        'Mark Paid',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: AppConstants.fontSmall,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
