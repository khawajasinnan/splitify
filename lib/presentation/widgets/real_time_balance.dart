import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/config/supabase_config.dart';

/// Real-Time Balance Widget - Fetches from Database
class RealTimeBalanceStat extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isOwed; // true for owed to you, false for you owe

  const RealTimeBalanceStat({
    super.key,
    required this.label,
    required this.icon,
    required this.isOwed,
  });

  Future<double> _fetchBalance() async {
    try {
      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null) return 0.0;

      // Get balances from settlements table or calculate from expense_splits
      final result = await SupabaseConfig.client
          .from('expense_splits')
          .select('amount')
          .eq('user_id', userId);

      if (result == null || result.isEmpty) return 0.0;

      double total = 0.0;
      for (var split in result) {
        total += (split['amount'] as num).toDouble();
      }

      return isOwed ? total : 0.0; // Simplified - adjust based on your business logic
    } catch (e) {
      debugPrint('Error fetching balance: $e');
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: _fetchBalance(),
      builder: (context, snapshot) {
        final amount = snapshot.data ?? 0.0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              snapshot.connectionState == ConnectionState.waiting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      '₨${amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
