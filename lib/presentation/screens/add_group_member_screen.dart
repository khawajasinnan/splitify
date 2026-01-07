import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../data/datasources/group_datasource.dart';
import '../../data/models/group_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

/// Screen for adding a member to a group
class AddGroupMemberScreen extends StatefulWidget {
  final GroupModel group;

  const AddGroupMemberScreen({super.key, required this.group});

  @override
  State<AddGroupMemberScreen> createState() => _AddGroupMemberScreenState();
}

class _AddGroupMemberScreenState extends State<AddGroupMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _groupDataSource = GroupDataSource();
  bool _isLoading = false;

  Future<void> _handleAddMember() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _groupDataSource.addMember(
        groupId: widget.group.groupId,
        userEmail: _emailController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Member added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception:', '').trim()}'),
            backgroundColor: AppColors.error,
          ),
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
        title: const Text('Add Member'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Group info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.group.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (widget.group.description != null) ...[
                        const SizedBox(height: AppConstants.spacing8),
                        Text(
                          widget.group.description!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacing24),

              // Instructions
              Container(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primaryTeal),
                    const SizedBox(width: AppConstants.spacing12),
                    Expanded(
                      child: Text(
                        'Enter the email address of the user you want to add. They must have an account.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primaryTeal,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacing24),

              // Email field
              CustomTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'user@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: AppConstants.spacing24),

              // Add button
              CustomButton(
                text: 'Add Member',
                onPressed: _handleAddMember,
                isLoading: _isLoading,
                icon: Icons.person_add,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
