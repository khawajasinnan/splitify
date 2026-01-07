import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/config/supabase_config.dart';
import '../../data/datasources/group_datasource.dart';
import '../../data/models/group_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/currency_selector.dart';
import 'group_detail_screen.dart';

/// Groups list screen
class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final _groupDataSource = GroupDataSource();
  List<GroupModel> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() => _isLoading = true);
    try {
      final groups = await _groupDataSource.getUserGroups();
      setState(() {
        _groups = groups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading groups: $e')),
        );
      }
    }
  }

  void _showCreateGroupDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String selectedCurrency = AppConstants.defaultCurrency;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Group'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: nameController,
                  label: 'Group Name',
                  hint: 'Enter group name',
                ),
                const SizedBox(height: AppConstants.spacing16),
                CustomTextField(
                  controller: descController,
                  label: 'Description (Optional)',
                  hint: 'Enter description',
                  maxLines: 3,
                ),
                const SizedBox(height: AppConstants.spacing16),
                // Currency Selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Currency',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.textSecondary
                            : const Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CurrencySelector(
                      selectedCurrency: selectedCurrency,
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCurrency = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  try {
                    await _groupDataSource.createGroup(
                      name: nameController.text,
                      description: descController.text.isNotEmpty ? descController.text : null,
                      currency: selectedCurrency,
                    );
                    if (mounted) {
                      Navigator.pop(context);
                      _loadGroups();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.groups_outlined,
                        size: 80,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: AppConstants.spacing16),
                      Text(
                        'No groups yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppConstants.spacing8),
                      Text(
                        'Create your first group to start tracking expenses',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  itemCount: _groups.length,
                  itemBuilder: (context, index) {
                    final group = _groups[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.tealGradient,
                            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          ),
                          child: const Icon(
                            Icons.groups,
                            color: AppColors.textOnDark,
                          ),
                        ),
                        title: Text(group.name),
                        subtitle: group.description != null
                            ? Text(
                                group.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupDetailScreen(group: group),
                            ),
                          ).then((_) => _loadGroups());
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateGroupDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Group'),
      ),
    );
  }
}
