import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/expense_datasource.dart';
import '../../data/models/expense_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';

/// All expenses screen
class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 80,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppConstants.spacing16),
              Text(
                'View Expenses by Group',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppConstants.spacing8),
              Text(
                'Go to Groups tab to see expenses for each group',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
