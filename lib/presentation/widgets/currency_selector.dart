import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Currency selector dropdown
class CurrencySelector extends StatelessWidget {
  final String selectedCurrency;
  final ValueChanged<String?> onChanged;

  const CurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCurrency,
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? AppColors.textSecondary : const Color(0xFF718096),
          ),
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : const Color(0xFF2D3748),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: isDark ? AppColors.surface : Colors.white,
          items: AppConstants.currencies.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Row(
                children: [
                  Text(
                    entry.value,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${entry.key} - ${AppConstants.currencyNames[entry.key]}',
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimary : const Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
