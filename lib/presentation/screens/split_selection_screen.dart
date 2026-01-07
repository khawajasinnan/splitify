import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/group_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

/// Screen for selecting how to split an expense
class SplitSelectionScreen extends StatefulWidget {
  final List<GroupMemberModel> members;
  final Map<String, String> memberNames;
  final double totalAmount;
  final String currency;
  final String? initialSplitType;
  final Map<String, double>? initialSplits;
  final Set<String>? initialSelectedMembers;

  const SplitSelectionScreen({
    super.key,
    required this.members,
    required this.memberNames,
    required this.totalAmount,
    this.currency = 'PKR',
    this.initialSplitType,
    this.initialSplits,
    this.initialSelectedMembers,
  });

  @override
  State<SplitSelectionScreen> createState() => _SplitSelectionScreenState();
}

class _SplitSelectionScreenState extends State<SplitSelectionScreen> {
  String _splitType = 'equal';
  Map<String, TextEditingController> _amountControllers = {};
  Map<String, double> _customAmounts = {};
  Set<String> _selectedMembers = {};

  @override
  void initState() {
    super.initState();
    _splitType = widget.initialSplitType ?? 'equal';
    
    // Initialize selected members (all selected by default)
    _selectedMembers = widget.initialSelectedMembers?.toSet() ?? 
                      widget.members.map((m) => m.userId).toSet();
    
    // Initialize controllers for custom split
    for (final member in widget.members) {
      final initialAmount = widget.initialSplits?[member.userId] ?? 
                           (widget.totalAmount / _selectedMembers.length);
      _amountControllers[member.userId] = TextEditingController(
        text: initialAmount.toStringAsFixed(2),
      );
      _customAmounts[member.userId] = initialAmount;
    }
  }

  @override
  void dispose() {
    for (final controller in _amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<GroupMemberModel> get _selectedMembersList {
    return widget.members.where((m) => _selectedMembers.contains(m.userId)).toList();
  }

  double get _totalAllocated {
    if (_splitType == 'equal') {
      return widget.totalAmount;
    }
    return _customAmounts.entries
        .where((e) => _selectedMembers.contains(e.key))
        .fold(0.0, (sum, entry) => sum + entry.value);
  }

  double get _remaining {
    return widget.totalAmount - _totalAllocated;
  }

  bool get _isValid {
    return (_remaining.abs() < 0.01); // Allow small floating point differences
  }

  void _updateCustomAmount(String userId, String value) {
    final amount = double.tryParse(value) ?? 0.0;
    setState(() {
      _customAmounts[userId] = amount;
    });
  }

  void _saveSplit() {
    // Validate at least one member is selected
    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one member'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isValid && _splitType == 'custom') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Split amounts must equal ${CurrencyFormatter.formatWithCurrency(widget.totalAmount, widget.currency)}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Map<String, double> splits;
    if (_splitType == 'equal') {
      final equalAmount = widget.totalAmount / _selectedMembers.length;
      splits = {
        for (final member in _selectedMembersList)
          member.userId: equalAmount,
      };
    } else {
      // Only include selected members in splits
      splits = Map.fromEntries(
        _customAmounts.entries.where((e) => _selectedMembers.contains(e.key)),
      );
    }

    Navigator.pop(context, {
      'splitType': _splitType,
      'splits': splits,
      'selectedMembers': _selectedMembers.toList(),
    });
  }

  void _toggleMemberSelection(String userId) {
    setState(() {
      if (_selectedMembers.contains(userId)) {
        _selectedMembers.remove(userId);
      } else {
        _selectedMembers.add(userId);
      }
      
      // Recalculate equal split amounts if in equal mode
      if (_splitType == 'equal' && _selectedMembers.isNotEmpty) {
        final equalAmount = widget.totalAmount / _selectedMembers.length;
        for (final member in widget.members) {
          if (_selectedMembers.contains(member.userId)) {
            _amountControllers[member.userId]!.text = equalAmount.toStringAsFixed(2);
            _customAmounts[member.userId] = equalAmount;
          }
        }
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedMembers = widget.members.map((m) => m.userId).toSet();
      if (_splitType == 'equal') {
        final equalAmount = widget.totalAmount / _selectedMembers.length;
        for (final member in widget.members) {
          _amountControllers[member.userId]!.text = equalAmount.toStringAsFixed(2);
          _customAmounts[member.userId] = equalAmount;
        }
      }
    });
  }

  void _selectNone() {
    setState(() {
      _selectedMembers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Total amount display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Column(
                  children: [
                    Text(
                      'Total Amount',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacing8),
                    Text(
                      CurrencyFormatter.formatWithCurrency(widget.totalAmount, widget.currency),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacing24),

            // Split type selector
            Text(
              'Split Method',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacing12),
            
            Row(
              children: [
                Expanded(
                  child: _buildSplitTypeCard(
                    'Equal',
                    'Split equally among ${_selectedMembers.length} selected',
                    Icons.people,
                    'equal',
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: _buildSplitTypeCard(
                    'Custom',
                    'Enter custom amounts',
                    Icons.edit,
                    'custom',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing24),

            // Member selection controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Members (${_selectedMembers.length}/${widget.members.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _selectAll,
                      icon: const Icon(Icons.check_box, size: 18),
                      label: const Text('All'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryTeal,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _selectNone,
                      icon: const Icon(Icons.check_box_outline_blank, size: 18),
                      label: const Text('None'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing12),

            ...widget.members.map((member) {
              final name = widget.memberNames[member.userId] ?? 'Unknown';
              final isSelected = _selectedMembers.contains(member.userId);
              final amount = _splitType == 'equal'
                  ? (_selectedMembers.isNotEmpty ? widget.totalAmount / _selectedMembers.length : 0.0)
                  : _customAmounts[member.userId] ?? 0.0;

              return Card(
                margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
                color: isSelected ? null : Colors.grey.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacing12),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        onChanged: (value) => _toggleMemberSelection(member.userId),
                        activeColor: AppColors.primaryTeal,
                      ),
                      CircleAvatar(
                        backgroundColor: isSelected
                            ? AppColors.primaryTeal.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        child: Text(
                          name[0].toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? AppColors.primaryTeal : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacing12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: isSelected ? AppColors.textPrimary : Colors.grey,
                              ),
                            ),
                            if (member.isAdmin)
                              Text(
                                'Admin',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? AppColors.primaryTeal : Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacing8),
                      if (_splitType == 'equal')
                        Text(
                          isSelected ? CurrencyFormatter.formatWithCurrency(amount, widget.currency) : CurrencyFormatter.formatWithCurrency(0, widget.currency),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: isSelected ? AppColors.primaryTeal : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                        )
                      else
                        SizedBox(
                          width: 120,
                          child: CustomTextField(
                            controller: _amountControllers[member.userId]!,
                            label: 'Amount',
                            hint: '0.00',
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.attach_money,
                            onChanged: (value) => _updateCustomAmount(member.userId, value),
                            enabled: isSelected,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),

            // Summary for custom split
            if (_splitType == 'custom') ...[
              const SizedBox(height: AppConstants.spacing16),
              Card(
                color: _isValid 
                    ? Colors.green.withOpacity(0.1) 
                    : Colors.red.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Allocated:'),
                          Text(
                            CurrencyFormatter.formatWithCurrency(_totalAllocated, widget.currency),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isValid ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Remaining:'),
                          Text(
                            CurrencyFormatter.formatWithCurrency(_remaining.abs(), widget.currency),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isValid ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      if (!_isValid) ...[
                        const SizedBox(height: AppConstants.spacing8),
                        Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _remaining > 0 
                                    ? 'Add ${CurrencyFormatter.formatWithCurrency(_remaining, widget.currency)} more'
                                    : 'Reduce by ${CurrencyFormatter.formatWithCurrency(_remaining.abs(), widget.currency)}',
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppConstants.spacing24),
            CustomButton(
              text: 'Save Split',
              onPressed: _saveSplit,
              icon: Icons.check,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitTypeCard(
    String title,
    String subtitle,
    IconData icon,
    String value,
  ) {
    final isSelected = _splitType == value;
    return InkWell(
      onTap: () => setState(() => _splitType = value),
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryTeal.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primaryTeal : AppColors.textSecondary,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryTeal : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primaryTeal : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacing4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
