import '../../core/config/supabase_config.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';

/// Supabase data source for expense operations
class ExpenseDataSource {
  final _client = SupabaseConfig.client;

  /// Get expenses for a group
  Future<List<ExpenseModel>> getGroupExpenses(String groupId) async {
    final response = await _client
        .from('expenses')
        .select()
        .eq('group_id', groupId)
        .order('date', ascending: false);

    return (response as List)
        .map((json) => ExpenseModel.fromJson(json))
        .toList();
  }

  /// Create a new expense
  Future<ExpenseModel> createExpense({
    required String groupId,
    String? categoryId,
    required double amount,
    required String description,
    required DateTime date,
    required String splitType,
    required List<Map<String, dynamic>> splits,
  }) async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Create expense
    final expenseResponse = await _client
        .from('expenses')
        .insert({
          'group_id': groupId,
          'category_id': categoryId,
          'payer_id': userId,
          'amount': amount,
          'description': description,
          'date': date.toIso8601String(),
          'split_type': splitType,
        })
        .select()
        .single();

    final expense = ExpenseModel.fromJson(expenseResponse);

    // Create splits
    final splitsData = splits.map((split) {
      return {
        'expense_id': expense.expenseId,
        'user_id': split['user_id'],
        'amount': split['amount'],
        'share_percentage': split['share_percentage'],
      };
    }).toList();

    await _client.from('expense_splits').insert(splitsData);

    return expense;
  }

  /// Get expense splits
  Future<List<ExpenseSplitModel>> getExpenseSplits(String expenseId) async {
    final response = await _client
        .from('expense_splits')
        .select()
        .eq('expense_id', expenseId);

    return (response as List)
        .map((json) => ExpenseSplitModel.fromJson(json))
        .toList();
  }

  /// Delete expense (only if current user is the payer)
  Future<void> deleteExpense(String expenseId) async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // First check if current user is the payer
    final expense = await _client
        .from('expenses')
        .select('payer_id')
        .eq('expense_id', expenseId)
        .single();

    if (expense['payer_id'] != userId) {
      throw Exception('Only the payer can delete this expense');
    }

    // Delete expense (cascade will handle expense_splits)
    await _client.from('expenses').delete().eq('expense_id', expenseId);
  }

  /// Get all categories
  Future<List<CategoryModel>> getCategories() async {
    final response = await _client.from('categories').select();

    return (response as List)
        .map((json) => CategoryModel.fromJson(json))
        .toList();
  }
}
