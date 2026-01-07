import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Custom action button with support for gradients and solid colors
class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final Color? solidColor;
  final Color textColor;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final EdgeInsets? padding;

  const ActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient,
    this.solidColor,
    this.textColor = AppColors.textWhite,
    this.icon,
    this.isLoading = false,
    this.width,
    this.padding,
  });

  /// Teal gradient button (default primary action)
  factory ActionButton.teal({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
  }) {
    return ActionButton(
      text: text,
      onPressed: onPressed,
      gradient: AppColors.tealGradient,
      icon: icon,
      isLoading: isLoading,
    );
  }

  /// Orange solid button (accent actions)
  factory ActionButton.orange({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
  }) {
    return ActionButton(
      text: text,
      onPressed: onPressed,
      solidColor: AppColors.accentOrange,
      icon: icon,
      isLoading: isLoading,
    );
  }

  /// Green solid button (success actions)
  factory ActionButton.green({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
  }) {
    return ActionButton(
      text: text,
      onPressed: onPressed,
      solidColor: AppColors.successGreen,
      icon: icon,
      isLoading: isLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: gradient,
        color: solidColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing24,
                  vertical: AppConstants.spacing16,
                ),
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textWhite,
                        ),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: textColor, size: 20),
                        const SizedBox(width: AppConstants.spacing8),
                      ],
                      Text(
                        text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: AppConstants.fontLarge,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
