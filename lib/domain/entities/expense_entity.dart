import 'package:equatable/equatable.dart';

/// Expense entity representing a shared expense
class ExpenseEntity extends Equatable {
  final String expenseId;
  final String groupId;
  final String? categoryId;
  final String payerId;
  final double amount;
  final String description;
  final DateTime date;
  final String splitType; // 'equal', 'percentage', 'custom'
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseEntity({
    required this.expenseId,
    required this.groupId,
    this.categoryId,
    required this.payerId,
    required this.amount,
    required this.description,
    required this.date,
    required this.splitType,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isEqualSplit => splitType == 'equal';
  bool get isPercentageSplit => splitType == 'percentage';
  bool get isCustomSplit => splitType == 'custom';

  @override
  List<Object?> get props => [
        expenseId,
        groupId,
        categoryId,
        payerId,
        amount,
        description,
        date,
        splitType,
        createdAt,
        updatedAt,
      ];

  ExpenseEntity copyWith({
    String? expenseId,
    String? groupId,
    String? categoryId,
    String? payerId,
    double? amount,
    String? description,
    DateTime? date,
    String? splitType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseEntity(
      expenseId: expenseId ?? this.expenseId,
      groupId: groupId ?? this.groupId,
      categoryId: categoryId ?? this.categoryId,
      payerId: payerId ?? this.payerId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      splitType: splitType ?? this.splitType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Expense split entity representing how an expense is divided
class ExpenseSplitEntity extends Equatable {
  final String splitId;
  final String expenseId;
  final String userId;
  final double amount;
  final double? sharePercentage;

  const ExpenseSplitEntity({
    required this.splitId,
    required this.expenseId,
    required this.userId,
    required this.amount,
    this.sharePercentage,
  });

  @override
  List<Object?> get props => [
        splitId,
        expenseId,
        userId,
        amount,
        sharePercentage,
      ];

  ExpenseSplitEntity copyWith({
    String? splitId,
    String? expenseId,
    String? userId,
    double? amount,
    double? sharePercentage,
  }) {
    return ExpenseSplitEntity(
      splitId: splitId ?? this.splitId,
      expenseId: expenseId ?? this.expenseId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      sharePercentage: sharePercentage ?? this.sharePercentage,
    );
  }
}
