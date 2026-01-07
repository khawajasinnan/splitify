import '../../domain/entities/expense_entity.dart';

/// Expense model for JSON serialization
class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.expenseId,
    required super.groupId,
    super.categoryId,
    required super.payerId,
    required super.amount,
    required super.description,
    required super.date,
    required super.splitType,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      expenseId: json['expense_id'] as String,
      groupId: json['group_id'] as String,
      categoryId: json['category_id'] as String?,
      payerId: json['payer_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      splitType: json['split_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expense_id': expenseId,
      'group_id': groupId,
      'category_id': categoryId,
      'payer_id': payerId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'split_type': splitType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to entity
  ExpenseEntity toEntity() {
    return ExpenseEntity(
      expenseId: expenseId,
      groupId: groupId,
      categoryId: categoryId,
      payerId: payerId,
      amount: amount,
      description: description,
      date: date,
      splitType: splitType,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

}

/// Expense split model
class ExpenseSplitModel extends ExpenseSplitEntity {
  const ExpenseSplitModel({
    required super.splitId,
    required super.expenseId,
    required super.userId,
    required super.amount,
    super.sharePercentage,
  });

  factory ExpenseSplitModel.fromJson(Map<String, dynamic> json) {
    return ExpenseSplitModel(
      splitId: json['split_id'] as String,
      expenseId: json['expense_id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      sharePercentage: json['share_percentage'] != null
          ? (json['share_percentage'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'split_id': splitId,
      'expense_id': expenseId,
      'user_id': userId,
      'amount': amount,
      'share_percentage': sharePercentage,
    };
  }

  /// Convert to entity
  ExpenseSplitEntity toEntity() {
    return ExpenseSplitEntity(
      splitId: splitId,
      expenseId: expenseId,
      userId: userId,
      amount: amount,
      sharePercentage: sharePercentage,
    );
  }

}
