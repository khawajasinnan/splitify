import '../../domain/entities/settlement_entity.dart';

/// Settlement model for Supabase data mapping
class SettlementModel extends SettlementEntity {
  const SettlementModel({
    required super.settlementId,
    required super.groupId,
    required super.payerId,
    required super.receiverId,
    required super.amount,
    required super.status,
    super.notes,
    required super.createdAt,
    super.settledAt,
  });

  /// Create from JSON
  factory SettlementModel.fromJson(Map<String, dynamic> json) {
    return SettlementModel(
      settlementId: json['settlement_id'] as String,
      groupId: json['group_id'] as String,
      payerId: json['payer_id'] as String,
      receiverId: json['receiver_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      settledAt: json['settled_at'] != null 
          ? DateTime.parse(json['settled_at'] as String) 
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'settlement_id': settlementId,
      'group_id': groupId,
      'payer_id': payerId,
      'receiver_id': receiverId,
      'amount': amount,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'settled_at': settledAt?.toIso8601String(),
    };
  }

  /// Convert to entity
  SettlementEntity toEntity() {
    return SettlementEntity(
      settlementId: settlementId,
      groupId: groupId,
      payerId: payerId,
      receiverId: receiverId,
      amount: amount,
      status: status,
      notes: notes,
      createdAt: createdAt,
      settledAt: settledAt,
    );
  }

  /// Create from entity
  factory SettlementModel.fromEntity(SettlementEntity entity) {
    return SettlementModel(
      settlementId: entity.settlementId,
      groupId: entity.groupId,
      payerId: entity.payerId,
      receiverId: entity.receiverId,
      amount: entity.amount,
      status: entity.status,
      notes: entity.notes,
      createdAt: entity.createdAt,
      settledAt: entity.settledAt,
    );
  }
}
