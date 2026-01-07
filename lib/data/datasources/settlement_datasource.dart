import '../../core/config/supabase_config.dart';
import '../../core/utils/balance_calculator.dart';
import '../models/settlement_model.dart';
import '../models/expense_model.dart';

/// Supabase data source for settlement operations
class SettlementDataSource {
  final _client = SupabaseConfig.client;

  /// Get settlements for a group
  Future<List<SettlementModel>> getGroupSettlements(String groupId) async {
    final response = await _client
        .from('settlements')
        .select()
        .eq('group_id', groupId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => SettlementModel.fromJson(json))
        .toList();
  }

  /// Get settlements for current user (where they are payer or receiver)
  Future<List<SettlementModel>> getUserSettlements() async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('settlements')
        .select()
        .or('payer_id.eq.$userId,receiver_id.eq.$userId')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => SettlementModel.fromJson(json))
        .toList();
  }

  /// Create a new settlement
  Future<SettlementModel> createSettlement({
    required String groupId,
    required String payerId,
    required String receiverId,
    required double amount,
    String? notes,
    bool markAsCompleted = true,
  }) async {
    final response = await _client
        .from('settlements')
        .insert({
          'group_id': groupId,
          'payer_id': payerId,
          'receiver_id': receiverId,
          'amount': amount,
          'status': markAsCompleted ? 'completed' : 'pending',
          'notes': notes,
          'settled_at': markAsCompleted ? DateTime.now().toIso8601String() : null,
        })
        .select()
        .single();

    return SettlementModel.fromJson(response);
  }

  /// Update settlement status
  Future<SettlementModel> updateSettlementStatus({
    required String settlementId,
    required String status,
  }) async {
    final response = await _client
        .from('settlements')
        .update({
          'status': status,
          'settled_at': status == 'completed' 
              ? DateTime.now().toIso8601String() 
              : null,
        })
        .eq('settlement_id', settlementId)
        .select()
        .single();

    return SettlementModel.fromJson(response);
  }

  /// Delete settlement
  Future<void> deleteSettlement(String settlementId) async {
    await _client.from('settlements').delete().eq('settlement_id', settlementId);
  }

  /// Get suggested settlements for a group (simplified balances)
  Future<List<SimplifiedBalance>> getSuggestedSettlements({
    required String groupId,
    required List<ExpenseModel> expenses,
    required List<ExpenseSplitModel> splits,
    required List<SettlementModel> settlements,
  }) async {
    // Convert models to entities for balance calculator
    final expenseEntities = expenses.map((e) => e.toEntity()).toList();
    final splitEntities = splits.map((s) => s.toEntity()).toList();
    final settlementEntities = settlements.map((s) => s.toEntity()).toList();

    // Calculate balances
    final balances = BalanceCalculator.calculateGroupBalances(
      expenses: expenseEntities,
      splits: splitEntities,
      settlements: settlementEntities,
    );

    // Simplify balances
    return BalanceCalculator.simplifyBalances(balances);
  }
}
