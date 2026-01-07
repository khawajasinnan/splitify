import 'package:equatable/equatable.dart';

/// Settlement entity representing a payment settlement
class SettlementEntity extends Equatable {
  final String settlementId;
  final String groupId;
  final String payerId;
  final String receiverId;
  final double amount;
  final String status; // 'pending', 'completed', 'cancelled'
  final String? notes;
  final DateTime createdAt;
  final DateTime? settledAt;

  const SettlementEntity({
    required this.settlementId,
    required this.groupId,
    required this.payerId,
    required this.receiverId,
    required this.amount,
    required this.status,
    this.notes,
    required this.createdAt,
    this.settledAt,
  });

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  @override
  List<Object?> get props => [
        settlementId,
        groupId,
        payerId,
        receiverId,
        amount,
        status,
        notes,
        createdAt,
        settledAt,
      ];

  SettlementEntity copyWith({
    String? settlementId,
    String? groupId,
    String? payerId,
    String? receiverId,
    double? amount,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? settledAt,
  }) {
    return SettlementEntity(
      settlementId: settlementId ?? this.settlementId,
      groupId: groupId ?? this.groupId,
      payerId: payerId ?? this.payerId,
      receiverId: receiverId ?? this.receiverId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      settledAt: settledAt ?? this.settledAt,
    );
  }
}
