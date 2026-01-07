import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../core/config/supabase_config.dart';
import '../../data/datasources/expense_datasource.dart';
import '../../data/datasources/group_datasource.dart';
import '../../data/models/group_model.dart';
import '../../data/models/category_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'split_selection_screen.dart';

/// Add expense screen
class AddExpenseScreen extends StatefulWidget {
  final GroupModel group;

  const AddExpenseScreen({super.key, required this.group});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _expenseDataSource = ExpenseDataSource();
  final _groupDataSource = GroupDataSource();
  
  List<CategoryModel> _categories = [];
  List<dynamic> _members = [];
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  String _splitType = 'equal';
  Map<String, double> _customSplits = {};
  Set<String> _selectedMemberIds = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final categories = await _expenseDataSource.getCategories();
    final members = await _groupDataSource.getGroupMembers(widget.group.groupId);
    setState(() {
      _categories = categories;
      _members = members;
      // Initialize with all members selected
      _selectedMemberIds = members.map((m) => m.userId as String).toSet();
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final amount = double.parse(_amountController.text);

      List<Map<String, dynamic>> splits;
      if (_splitType == 'custom') {
        // Use custom splits (only for selected members)
        splits = _customSplits.entries.map((entry) {
          return {
            'user_id': entry.key,
            'amount': entry.value,
            'share_percentage': (entry.value / amount) * 100,
          };
        }).toList();
      } else {
        // Equal split (only for selected members)
        final splitAmount = amount / _selectedMemberIds.length;
        final selectedMembers = _members.where((m) => _selectedMemberIds.contains(m.userId));
        splits = selectedMembers.map((member) {
          return {
            'user_id': member.userId,
            'amount': splitAmount,
            'share_percentage': 100.0 / _selectedMemberIds.length,
          };
        }).toList();
      }

      await _expenseDataSource.createExpense(
        groupId: widget.group.groupId,
        categoryId: _selectedCategory?.categoryId,
        amount: amount,
        description: _descriptionController.text,
        date: _selectedDate,
        splitType: _splitType,
        splits: splits,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _amountController,
                label: 'Amount',
                hint: 'Enter amount',
                keyboardType: TextInputType.number,
                validator: Validators.validateAmount,
                prefixIcon: Icons.attach_money,
              ),
              const SizedBox(height: AppConstants.spacing16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'What was this for?',
                validator: Validators.validateDescription,
                prefixIcon: Icons.description,
              ),
              const SizedBox(height: AppConstants.spacing16),
              DropdownButtonFormField<CategoryModel>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category (Optional)',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text('${cat.icon} ${cat.name}'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              const SizedBox(height: AppConstants.spacing16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(_selectedDate.toString().split(' ')[0]),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
              ),
              const SizedBox(height: AppConstants.spacing16),
              
              // Split method selector
              InkWell(
                onTap: () async {
                  if (_amountController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter amount first'),
                      ),
                    );
                    return;
                  }

                  final amount = double.tryParse(_amountController.text);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid amount'),
                      ),
                    );
                    return;
                  }

                  // Fetch member names for display
                  Map<String, String> memberNames = {};
                  for (final member in _members) {
                    try {
                      final userResponse = await SupabaseConfig.client
                          .from('users')
                          .select('name')
                          .eq('user_id', member.userId)
                          .single();
                      memberNames[member.userId] = userResponse['name'] as String;
                    } catch (e) {
                      memberNames[member.userId] = 'Unknown User';
                    }
                  }

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SplitSelectionScreen(
                        members: _members.cast<GroupMemberModel>(),
                        memberNames: memberNames,
                        totalAmount: amount,
                        currency: widget.group.currency,
                        initialSplitType: _splitType,
                        initialSplits: _customSplits,
                        initialSelectedMembers: _selectedMemberIds,
                      ),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      _splitType = result['splitType'];
                      _customSplits = Map<String, double>.from(result['splits']);
                      if (result['selectedMembers'] != null) {
                        _selectedMemberIds = Set<String>.from(result['selectedMembers']);
                      }
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.textSecondary),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.splitscreen, color: AppColors.primaryTeal),
                      const SizedBox(width: AppConstants.spacing12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Split Method',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _splitType == 'equal'
                                  ? 'Split equally among ${_selectedMemberIds.length} of ${_members.length} member(s)'
                                  : 'Custom split - ${_selectedMemberIds.length} of ${_members.length} member(s)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacing24),

              CustomButton(
                text: 'Add Expense',
                onPressed: _handleSubmit,
                isLoading: _isLoading,
                icon: Icons.add,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
