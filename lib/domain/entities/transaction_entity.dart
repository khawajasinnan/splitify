import 'package:equatable/equatable.dart';

/// Transaction entity for audit logging
class TransactionEntity extends Equatable {
  final String transactionId;
  final String userId;
  final String type; // 'expense', 'settlement', 'payment'
  final double amount;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  const TransactionEntity({
    required this.transactionId,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.createdAt,
  });

  bool get isExpense => type == 'expense';
  bool get isSettlement => type == 'settlement';
  bool get isPayment => type == 'payment';

  @override
  List<Object?> get props => [
        transactionId,
        userId,
        type,
        amount,
        description,
        date,
        createdAt,
      ];

  TransactionEntity copyWith({
    String? transactionId,
    String? userId,
    String? type,
    double? amount,
    String? description,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return TransactionEntity(
      transactionId: transactionId ?? this.transactionId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
