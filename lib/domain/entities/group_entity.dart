import 'package:equatable/equatable.dart';

/// Group entity representing an expense sharing group
class GroupEntity extends Equatable {
  final String groupId;
  final String name;
  final String? description;
  final String currency;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GroupEntity({
    required this.groupId,
    required this.name,
    this.description,
    this.currency = 'PKR',
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        groupId,
        name,
        description,
        currency,
        createdBy,
        createdAt,
        updatedAt,
      ];

  GroupEntity copyWith({
    String? groupId,
    String? name,
    String? description,
    String? currency,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroupEntity(
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      description: description ?? this.description,
      currency: currency ?? this.currency,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Group member entity
class GroupMemberEntity extends Equatable {
  final String id;
  final String groupId;
  final String userId;
  final String role; // 'admin' or 'member'
  final DateTime joinedAt;

  const GroupMemberEntity({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    required this.joinedAt,
  });

  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [id, groupId, userId, role, joinedAt];

  GroupMemberEntity copyWith({
    String? id,
    String? groupId,
    String? userId,
    String? role,
    DateTime? joinedAt,
  }) {
    return GroupMemberEntity(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
