import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Currency formatting utilities
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: AppConstants.defaultCurrencySymbol,
    decimalDigits: 2,
  );

  static final NumberFormat _compactFormat = NumberFormat.compact();

  /// Get currency symbol for a given currency code
  static String getCurrencySymbol(String currencyCode) {
    return AppConstants.currencies[currencyCode] ?? AppConstants.defaultCurrencySymbol;
  }

  /// Format amount with specific currency: "$ 1,234.56"
  static String formatWithCurrency(double amount, String currencyCode) {
    final symbol = getCurrencySymbol(currencyCode);
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Format amount as "Rs 1,234.56" (using default currency)
  static String format(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Format amount as "Rs 1.2K" for large numbers
  static String formatCompact(double amount) {
    return '${AppConstants.defaultCurrencySymbol} ${_compactFormat.format(amount)}';
  }

  /// Format amount with compact notation and specific currency
  static String formatCompactWithCurrency(double amount, String currencyCode) {
    final symbol = getCurrencySymbol(currencyCode);
    return '$symbol ${_compactFormat.format(amount)}';
  }

  /// Format amount with sign (+ for positive, - for negative)
  static String formatWithSign(double amount, [String? currencyCode]) {
    final formatted = currencyCode != null 
        ? formatWithCurrency(amount.abs(), currencyCode)
        : format(amount.abs());
    if (amount > 0) {
      return '+$formatted';
    } else if (amount < 0) {
      return '-$formatted';
    }
    return formatted;
  }

  /// Parse currency string to double
  static double? parse(String value) {
    try {
      // Remove all currency symbols and whitespace
      var cleaned = value.trim();
      for (final symbol in AppConstants.currencies.values) {
        cleaned = cleaned.replaceAll(symbol, '');
      }
      cleaned = cleaned.replaceAll(',', '').trim();
      return double.tryParse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// Check if amount is valid (greater than 0)
  static bool isValidAmount(double amount) {
    return amount > 0;
  }
}
