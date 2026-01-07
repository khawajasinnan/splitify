import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/config/supabase_config.dart';
import '../../data/datasources/group_datasource.dart';
import '../../data/datasources/expense_datasource.dart';
import '../../data/datasources/settlement_datasource.dart';
import '../../data/models/group_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/settlement_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import 'add_expense_screen.dart';
import 'add_group_member_screen.dart';

/// Group detail screen showing members and expenses
class GroupDetailScreen extends StatefulWidget {
  final GroupModel group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> with SingleTickerProviderStateMixin {
  final _groupDataSource = GroupDataSource();
  final _expenseDataSource = ExpenseDataSource();
  final _settlementDataSource = SettlementDataSource();
  
  late TabController _tabController;
  List<ExpenseModel> _expenses = [];
  List<SettlementModel> _settlements = [];
  List<GroupMemberModel> _members = [];
  Map<String, String> _memberNames = {};
  bool _isLoading = true;
  bool _isCurrentUserAdmin = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final currentUserId = SupabaseConfig.currentUser?.id;
      final expenses = await _expenseDataSource.getGroupExpenses(widget.group.groupId);
      final members = await _groupDataSource.getGroupMembers(widget.group.groupId);
      final settlements = await _settlementDataSource.getGroupSettlements(widget.group.groupId);

      // Fetch member names
      Map<String, String> names = {};
      for (final member in members) {
        try {
          final userResponse = await SupabaseConfig.client
              .from('users')
              .select('name')
              .eq('user_id', member.userId)
              .single();
          names[member.userId] = userResponse['name'] as String;
        } catch (e) {
          names[member.userId] = 'Unknown User';
        }
      }

      // Check if current user is admin
      final currentUserMembership = members.firstWhere(
        (m) => m.userId == currentUserId,
        orElse: () => members.first,
      );

      setState(() {
        _expenses = expenses;
        _members = members;
        _settlements = settlements;
        _memberNames = names;
        _isCurrentUserAdmin = currentUserMembership.role == 'admin';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _deleteExpense(ExpenseModel expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _expenseDataSource.deleteExpense(expense.expenseId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting expense: $e')),
          );
        }
      }
    }
  }

  Future<void> _removeMember(GroupMemberModel member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Remove ${_memberNames[member.userId]} from this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _groupDataSource.removeMember(
          groupId: widget.group.groupId,
          userId: member.userId,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Member removed successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteGroup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to delete this group?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'This will permanently delete:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Text('All expenses', style: TextStyle(fontSize: 14)),
              ],
            ),
            const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Text('All settlements', style: TextStyle(fontSize: 14)),
              ],
            ),
            const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Text('All member data', style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'This action cannot be undone!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _groupDataSource.deleteGroup(widget.group.groupId);
        if (mounted) {
          Navigator.pop(context); // Go back to groups screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Group deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting group: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = SupabaseConfig.currentUser?.id;
    final totalExpenses = _expenses.fold(0.0, (sum, exp) => sum + exp.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          if (_isCurrentUserAdmin)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteGroup();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Group', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Expenses', icon: Icon(Icons.receipt)),
            Tab(text: 'Members', icon: Icon(Icons.people)),
            Tab(text: 'Settlements', icon: Icon(Icons.payments)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Group stats
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacing24),
                  decoration: BoxDecoration(
                    gradient: AppColors.tealGradient,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppConstants.radiusXLarge),
                      bottomRight: Radius.circular(AppConstants.radiusXLarge),
                    ),
                  ),
                  child: Column(
                    children: [
                      if (widget.group.description != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppConstants.spacing16),
                          child: Text(
                            widget.group.description!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textOnDark,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            'Members',
                            _members.length.toString(),
                            Icons.people,
                          ),
                          _buildStatCard(
                            'Expenses',
                            _expenses.length.toString(),
                            Icons.receipt,
                          ),
                          _buildStatCard(
                            'Total',
                            CurrencyFormatter.formatCompactWithCurrency(totalExpenses, widget.group.currency),
                            Icons.account_balance_wallet,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Tab views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Expenses tab
                      _expenses.isEmpty
                          ? _buildEmptyState(
                              Icons.receipt_long_outlined,
                              'No expenses yet',
                              'Add an expense to get started',
                            )
                          : RefreshIndicator(
                              onRefresh: _loadData,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(AppConstants.spacing16),
                                itemCount: _expenses.length,
                                itemBuilder: (context, index) {
                                  final expense = _expenses[index];
                                  final isPayer = expense.payerId == currentUserId;
                                  final payerName = _memberNames[expense.payerId] ?? 'Unknown';

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppColors.primaryTeal.withOpacity(0.1),
                                        child: const Icon(Icons.receipt, color: AppColors.primaryTeal),
                                      ),
                                      title: Text(expense.description),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(DateFormatter.formatDate(expense.date)),
                                          Text(
                                            'Paid by $payerName',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isPayer ? AppColors.primaryTeal : AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            CurrencyFormatter.formatWithCurrency(expense.amount, widget.group.currency),
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  color: AppColors.primaryTeal,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          if (isPayer) ...[
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _deleteExpense(expense),
                                              tooltip: 'Delete expense',
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                      
                      // Members tab
                      _members.isEmpty
                          ? _buildEmptyState(
                              Icons.people_outline,
                              'No members',
                              'Add members to share expenses',
                            )
                          : RefreshIndicator(
                              onRefresh: _loadData,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(AppConstants.spacing16),
                                itemCount: _members.length,
                                itemBuilder: (context, index) {
                                  final member = _members[index];
                                  final memberName = _memberNames[member.userId] ?? 'Unknown';
                                  final isCurrentUser = member.userId == currentUserId;
                                  final canRemove = _isCurrentUserAdmin && !isCurrentUser;

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: member.isAdmin 
                                            ? AppColors.primaryTeal.withOpacity(0.2)
                                            : AppColors.textSecondary.withOpacity(0.2),
                                        child: Icon(
                                          member.isAdmin ? Icons.admin_panel_settings : Icons.person,
                                          color: member.isAdmin ? AppColors.primaryTeal : AppColors.textSecondary,
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          Text(memberName),
                                          if (isCurrentUser) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryTeal.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Text(
                                                'You',
                                                style: TextStyle(fontSize: 10, color: AppColors.primaryTeal),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      subtitle: Text(
                                        member.isAdmin ? 'Admin' : 'Member',
                                        style: TextStyle(
                                          color: member.isAdmin ? AppColors.primaryTeal : AppColors.textSecondary,
                                        ),
                                      ),
                                      trailing: canRemove
                                          ? IconButton(
                                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                              onPressed: () => _removeMember(member),
                                              tooltip: 'Remove member',
                                            )
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                      
                      // Settlements tab
                      _settlements.isEmpty
                          ? _buildEmptyState(
                              Icons.payments_outlined,
                              'No settlements yet',
                              'Record payments to track who has paid whom',
                            )
                          : RefreshIndicator(
                              onRefresh: _loadData,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(AppConstants.spacing16),
                                itemCount: _settlements.length,
                                itemBuilder: (context, index) {
                                  final settlement = _settlements[index];
                                  final payerName = _memberNames[settlement.payerId] ?? 'Unknown';
                                  final receiverName = _memberNames[settlement.receiverId] ?? 'Unknown';
                                  final isCompleted = settlement.status == 'completed';

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: isCompleted
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.orange.withOpacity(0.1),
                                        child: Icon(
                                          isCompleted ? Icons.check_circle : Icons.pending,
                                          color: isCompleted ? Colors.green : Colors.orange,
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              payerName,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4),
                                            child: Icon(Icons.arrow_forward, size: 16),
                                          ),
                                          Flexible(
                                            child: Text(
                                              receiverName,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormatter.formatDate(settlement.settledAt ?? settlement.createdAt),
                                          ),
                                          if (settlement.notes != null && settlement.notes!.isNotEmpty)
                                            Text(
                                              settlement.notes!,
                                              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                            ),
                                        ],
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            CurrencyFormatter.formatWithCurrency(settlement.amount, widget.group.currency),
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          Text(
                                            isCompleted ? 'Completed' : 'Pending',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isCompleted ? Colors.green : Colors.orange,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            // Add expense
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddExpenseScreen(group: widget.group),
              ),
            ).then((_) => _loadData());
          } else {
            // Add member (only if admin)
            if (_isCurrentUserAdmin) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddGroupMemberScreen(group: widget.group),
                ),
              ).then((_) => _loadData());
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Only admins can add members')),
              );
            }
          }
        },
        icon: Icon(_tabController.index == 0 ? Icons.add : _tabController.index == 1 ? Icons.person_add : Icons.add),
        label: Text(_tabController.index == 0 ? 'Add Expense' : _tabController.index == 1 ? 'Add Member' : ''),
        backgroundColor: _tabController.index == 2 ? Colors.transparent : null,
        elevation: _tabController.index == 2 ? 0 : null,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textOnDark, size: 32),
        const SizedBox(height: AppConstants.spacing8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textOnDark,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textOnDark.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: AppColors.textSecondary),
          const SizedBox(height: AppConstants.spacing16),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
