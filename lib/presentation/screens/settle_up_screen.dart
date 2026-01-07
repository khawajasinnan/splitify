import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/config/supabase_config.dart';
import '../../data/datasources/group_datasource.dart';
import '../../data/datasources/settlement_datasource.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

/// Screen to record a settlement between users
class SettleUpScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final double suggestedAmount;
  final String? groupId; // Optional, if settling within specific group
  final bool isReceivingPayment; // True when creditor is recording receiving payment

  const SettleUpScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.suggestedAmount,
    this.groupId,
    this.isReceivingPayment = false,
  });

  @override
  State<SettleUpScreen> createState() => _SettleUpScreenState();
}

class _SettleUpScreenState extends State<SettleUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _groupDataSource = GroupDataSource();
  final _settlementDataSource = SettlementDataSource();
  
  String? _selectedGroupId;
  List<dynamic> _groups = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.suggestedAmount.toStringAsFixed(2);
    _selectedGroupId = widget.groupId;
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final groups = await _groupDataSource.getUserGroups();
      setState(() {
        _groups = groups;
        // If no group was specified, select the first one
        if (_selectedGroupId == null && groups.isNotEmpty) {
          _selectedGroupId = groups.first.groupId;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading groups: $e')),
        );
      }
    }
  }

  Future<void> _handleSettlement() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a group')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final currentUserId = SupabaseConfig.currentUser?.id;
      if (currentUserId == null) throw Exception('User not authenticated');

      final amount = double.parse(_amountController.text);

      // When receiving payment, current user is receiver and other user is payer
      // When paying debt, current user is payer and other user is receiver
      final actualPayerId = widget.isReceivingPayment ? widget.receiverId : currentUserId;
      final actualReceiverId = widget.isReceivingPayment ? currentUserId : widget.receiverId;

      await _settlementDataSource.createSettlement(
        groupId: _selectedGroupId!,
        payerId: actualPayerId,
        receiverId: actualReceiverId,
        amount: amount,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        markAsCompleted: true,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settlement recorded successfully!'),
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
        title: const Text('Settle Up'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Settlement info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, color: AppColors.primaryTeal),
                          const SizedBox(width: AppConstants.spacing8),
                          const Text('You'),
                          const Spacer(),
                          const Icon(Icons.arrow_forward, color: AppColors.textSecondary),
                          const Spacer(),
                          const Icon(Icons.person_outline, color: AppColors.primaryTeal),
                          const SizedBox(width: AppConstants.spacing8),
                          Expanded(
                            child: Text(
                              widget.receiverName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacing16),
                      Text(
                        widget.isReceivingPayment 
                            ? 'Recording payment received from ${widget.receiverName}'
                            : 'Settling payment to ${widget.receiverName}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacing24),

              // Amount field
              CustomTextField(
                controller: _amountController,
                label: 'Amount',
                hint: 'Enter settlement amount',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                prefixIcon: Icons.attach_money,
              ),
              const SizedBox(height: AppConstants.spacing16),

              // Group selection
              DropdownButtonFormField<String>(
                value: _selectedGroupId,
                decoration: InputDecoration(
                  labelText: 'Group',
                  prefixIcon: const Icon(Icons.group),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                ),
                items: _groups.map<DropdownMenuItem<String>>((group) {
                  return DropdownMenuItem<String>(
                    value: group.groupId,
                    child: Text(group.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedGroupId = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a group';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacing16),

              // Notes field
              CustomTextField(
                controller: _notesController,
                label: 'Notes (Optional)',
                hint: 'Add a note about this payment',
                maxLines: 3,
                prefixIcon: Icons.note,
              ),
              const SizedBox(height: AppConstants.spacing24),

              // Submit button
              CustomButton(
                text: widget.isReceivingPayment ? 'Record Payment Received' : 'Record Payment',
                onPressed: _handleSettlement,
                isLoading: _isLoading,
                icon: widget.isReceivingPayment ? Icons.account_balance_wallet : Icons.check_circle,
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
    _notesController.dispose();
    super.dispose();
  }
}
