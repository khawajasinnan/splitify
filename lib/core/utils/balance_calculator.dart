import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/settlement_entity.dart';

/// Balance calculator for computing who owes whom
class BalanceCalculator {
  /// Calculate balances between users in a group
  /// Returns a map of userId -> balance (positive means they are owed, negative means they owe)
  static Map<String, double> calculateGroupBalances({
    required List<ExpenseEntity> expenses,
    required List<ExpenseSplitEntity> splits,
    required List<SettlementEntity> settlements,
  }) {
    final Map<String, double> balances = {};

    // Calculate balances from expenses
    for (final expense in expenses) {
      // Add amount to payer's balance
      balances[expense.payerId] = (balances[expense.payerId] ?? 0) + expense.amount;

      // Get splits for this expense
      final expenseSplits = splits.where((s) => s.expenseId == expense.expenseId);

      // Subtract each person's share from their balance
      for (final split in expenseSplits) {
        balances[split.userId] = (balances[split.userId] ?? 0) - split.amount;
      }
    }

    // Adjust balances with completed settlements
    for (final settlement in settlements) {
      if (settlement.isCompleted) {
        // Payer paid back, so reduce their debt (increase balance)
        balances[settlement.payerId] = (balances[settlement.payerId] ?? 0) + settlement.amount;
        // Receiver received money, so reduce what they're owed (decrease balance)
        balances[settlement.receiverId] = (balances[settlement.receiverId] ?? 0) - settlement.amount;
      }
    }

    return balances;
  }

  /// Simplify balances to get minimal transactions needed to settle
  /// Returns list of (from, to, amount) tuples
  static List<SimplifiedBalance> simplifyBalances(Map<String, double> balances) {
    final List<SimplifiedBalance> simplified = [];
    
    // Separate creditors (owed money) and debtors (owe money)
    final List<MapEntry<String, double>> creditors = [];
    final List<MapEntry<String, double>> debtors = [];

    for (final entry in balances.entries) {
      if (entry.value > 0.01) {
        // Owed money (with small tolerance for floating point)
        creditors.add(entry);
      } else if (entry.value < -0.01) {
        // Owes money
        debtors.add(MapEntry(entry.key, -entry.value));
      }
    }

    // Sort by amount to optimize settlements
    creditors.sort((a, b) => b.value.compareTo(a.value));
    debtors.sort((a, b) => b.value.compareTo(a.value));

    int creditorIndex = 0;
    int debtorIndex = 0;

    while (creditorIndex < creditors.length && debtorIndex < debtors.length) {
      final creditor = creditors[creditorIndex];
      final debtor = debtors[debtorIndex];

      final settleAmount = creditor.value < debtor.value 
          ? creditor.value 
          : debtor.value;

      if (settleAmount > 0.01) {
        simplified.add(SimplifiedBalance(
          from: debtor.key,
          to: creditor.key,
          amount: settleAmount,
        ));
      }

      // Update remaining amounts
      creditors[creditorIndex] = MapEntry(
        creditor.key, 
        creditor.value - settleAmount,
      );
      debtors[debtorIndex] = MapEntry(
        debtor.key, 
        debtor.value - settleAmount,
      );

      // Move to next creditor or debtor
      if (creditors[creditorIndex].value < 0.01) creditorIndex++;
      if (debtors[debtorIndex].value < 0.01) debtorIndex++;
    }

    return simplified;
  }
}

/// Simplified balance representation
class SimplifiedBalance {
  final String from; // User who owes
  final String to;   // User who is owed
  final double amount;

  SimplifiedBalance({
    required this.from,
    required this.to,
    required this.amount,
  });
}
