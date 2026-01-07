import 'package:equatable/equatable.dart';

/// User entity representing a user in the app
class UserEntity extends Equatable {
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        userId,
        name,
        email,
        phone,
        createdAt,
        updatedAt,
      ];

  /// Create a copy of the entity with updated fields
  UserEntity copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
