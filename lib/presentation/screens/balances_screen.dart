import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/config/supabase_config.dart';
import '../../core/utils/balance_calculator.dart';
import '../../data/datasources/group_datasource.dart';
import '../../data/datasources/expense_datasource.dart';
import '../../data/datasources/settlement_datasource.dart';
import '../../data/models/group_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/expense_model.dart';
import 'settle_up_screen.dart';

/// Enhanced balances screen showing who owes whom
class BalancesScreen extends StatefulWidget {
  const BalancesScreen({super.key});

  @override
  State<BalancesScreen> createState() => _BalancesScreenState();
}

class _BalancesScreenState extends State<BalancesScreen> {
  final _groupDataSource = GroupDataSource();
  final _expenseDataSource = ExpenseDataSource();
  final _settlementDataSource = SettlementDataSource();
  
  bool _isLoading = true;
  Map<String, double> _totalBalances = {};
  Map<String, List<BalanceDetail>> _youOwe = {};
  Map<String, List<BalanceDetail>> _owesYou = {};
  Map<String,String> _userNames = {};

  @override
  void initState() {
    super.initState();
    _loadBalances();
  }

  Future<void> _loadBalances() async {
    setState(() => _isLoading = true);
    try {
      final currentUserId = SupabaseConfig.currentUser?.id;
      if (currentUserId == null) return;

      final groups = await _groupDataSource.getUserGroups();
      
      Map<String, double> youOweTotal = {};
      Map<String, double> owesYouTotal = {};
      Map<String, List<BalanceDetail>> youOweDetails = {};
      Map<String, List<BalanceDetail>> owesYouDetails = {};
      Map<String, String> userNameMap = {};

      for (final group in groups) {
        final expenses = await _expenseDataSource.getGroupExpenses(group.groupId);
        final members = await _groupDataSource.getGroupMembers(group.groupId);
        final settlements = await _settlementDataSource.getGroupSettlements(group.groupId);

        // Get all expense splits
        final List<ExpenseSplitModel> allSplits = [];
        for (final expense in expenses) {
          final splits = await _expenseDataSource.getExpenseSplits(expense.expenseId);
          allSplits.addAll(splits);
        }

        // Calculate balances
        final balances = BalanceCalculator.calculateGroupBalances(
          expenses: expenses.map((e) => e.toEntity()).toList(),
          splits: allSplits.map((s) => s.toEntity()).toList(),
          settlements: settlements.map((s) => s.toEntity()).toList(),
        );

        // Get simplified settlements
        final simplified = BalanceCalculator.simplifyBalances(balances);

        // Fetch user names for display
        for (final member in members) {
          if (!userNameMap.containsKey(member.userId)) {
            try {
              final userResponse = await SupabaseConfig.client
                  .from('users')
                  .select('name')
                  .eq('user_id', member.userId)
                  .single();
              userNameMap[member.userId] = userResponse['name'] as String;
            } catch (e) {
              userNameMap[member.userId] = 'Unknown User';
            }
          }
        }

        // Process simplified balances
        for (final settlement in simplified) {
          if (settlement.from == currentUserId) {
            // Current user owes someone
            youOweTotal[settlement.to] = 
                (youOweTotal[settlement.to] ?? 0) + settlement.amount;
            
            youOweDetails.putIfAbsent(settlement.to, () => []);
            youOweDetails[settlement.to]!.add(BalanceDetail(
              groupName: group.name,
              amount: settlement.amount,
              userId: settlement.to,
            ));
          } else if (settlement.to == currentUserId) {
            // Someone owes current user
            owesYouTotal[settlement.from] = 
                (owesYouTotal[settlement.from] ?? 0) + settlement.amount;
            
            owesYouDetails.putIfAbsent(settlement.from, () => []);
            owesYouDetails[settlement.from]!.add(BalanceDetail(
              groupName: group.name,
              amount: settlement.amount,
              userId: settlement.from,
            ));
          }
        }
      }

      setState(() {
        _totalBalances = {...youOweTotal, ...owesYouTotal};
        _youOwe = youOweDetails;
        _owesYou = owesYouDetails;
        _userNames = userNameMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading balances: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balances'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBalances,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _youOwe.isEmpty && _owesYou.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadBalances,
                  child: ListView(
                    padding: const EdgeInsets.all(AppConstants.spacing16),
                    children: [
                      if (_youOwe.isNotEmpty) ...[
                        _buildSectionHeader('You Owe', Colors.red),
                        const SizedBox(height: AppConstants.spacing12),
                        ..._youOwe.entries.map((entry) => _buildBalanceCard(
                              userName: _userNames[entry.key] ?? 'Unknown',
                              userId: entry.key,
                              amount: entry.value.fold(
                                0.0, (sum, detail) => sum + detail.amount),
                              details: entry.value,
                              isDebt: true,
                            )),
                        const SizedBox(height: AppConstants.spacing24),
                      ],
                      if (_owesYou.isNotEmpty) ...[
                        _buildSectionHeader('Owes You', Colors.green),
                        const SizedBox(height: AppConstants.spacing12),
                        ..._owesYou.entries.map((entry) => _buildBalanceCard(
                              userName: _userNames[entry.key] ?? 'Unknown',
                              userId: entry.key,
                              amount: entry.value.fold(
                                0.0, (sum, detail) => sum + detail.amount),
                              details: entry.value,
                              isDebt: false,
                            )),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              'All Settled Up!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'You have no outstanding balances',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppConstants.spacing8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard({
    required String userName,
    required String userId,
    required double amount,
    required List<BalanceDetail> details,
    required bool isDebt,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isDebt 
              ? Colors.red.withOpacity(0.1) 
              : Colors.green.withOpacity(0.1),
          child: Icon(
            isDebt ? Icons.arrow_upward : Icons.arrow_downward,
            color: isDebt ? Colors.red : Colors.green,
          ),
        ),
        title: Text(userName),
        subtitle: Text(
          isDebt ? 'You owe' : 'Owes you',
          style: TextStyle(
            color: isDebt ? Colors.red : Colors.green,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(amount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDebt ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        children: [
          ...details.map((detail) => ListTile(
                dense: true,
                leading: const Icon(Icons.group, size: 16),
                title: Text(detail.groupName),
                trailing: Text(
                  CurrencyFormatter.format(detail.amount),
                  style: TextStyle(
                    color: isDebt ? Colors.red : Colors.green,
                  ),
                ),
              )),
          if (isDebt)
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing12),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettleUpScreen(
                        receiverId: userId,
                        receiverName: userName,
                        suggestedAmount: amount,
                      ),
                    ),
                  );
                  _loadBalances();
                },
                icon: const Icon(Icons.payment),
                label: const Text('Pay Up'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          if (!isDebt)
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing12),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettleUpScreen(
                        receiverId: userId,
                        receiverName: userName,
                        suggestedAmount: amount,
                        isReceivingPayment: true, // Flag to indicate receiving payment
                      ),
                    ),
                  );
                  _loadBalances();
                },
                icon: const Icon(Icons.account_balance_wallet),
                label: const Text('Record Payment Received'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Helper class to store balance details
class BalanceDetail {
  final String groupName;
  final double amount;
  final String userId;

  BalanceDetail({
    required this.groupName,
    required this.amount,
    required this.userId,
  });
}
