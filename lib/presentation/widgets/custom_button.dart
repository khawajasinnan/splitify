import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Custom premium button with gradient background
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Gradient? gradient;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient ?? AppColors.tealGradient,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTeal.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing24,
                vertical: AppConstants.spacing16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (icon != null && !isLoading) ...[
                    Icon(
                      icon,
                      color: AppColors.textOnDark,
                      size: AppConstants.iconMedium,
                    ),
                    const SizedBox(width: AppConstants.spacing8),
                  ],
                  if (isLoading)
                    const SizedBox(
                      width: AppConstants.iconMedium,
                      height: AppConstants.iconMedium,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textOnDark,
                        ),
                      ),
                    )
                  else
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: AppConstants.fontLarge,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textOnDark,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
