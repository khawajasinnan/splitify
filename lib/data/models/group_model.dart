import '../../domain/entities/group_entity.dart';

/// Group model for JSON serialization
class GroupModel extends GroupEntity {
  const GroupModel({
    required super.groupId,
    required super.name,
    super.description,
    super.currency = 'PKR',
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      groupId: json['group_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      currency: json['currency'] as String? ?? 'PKR',
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'name': name,
      'description': description,
      'currency': currency,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Group member model
class GroupMemberModel extends GroupMemberEntity {
  const GroupMemberModel({
    required super.id,
    required super.groupId,
    required super.userId,
    required super.role,
    required super.joinedAt,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}
