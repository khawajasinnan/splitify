import 'package:equatable/equatable.dart';

/// Category entity for expense categorization
class CategoryEntity extends Equatable {
  final String categoryId;
  final String name;
  final String type;
  final String? icon;
  final DateTime createdAt;

  const CategoryEntity({
    required this.categoryId,
    required this.name,
    required this.type,
    this.icon,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [categoryId, name, type, icon, createdAt];

  CategoryEntity copyWith({
    String? categoryId,
    String? name,
    String? type,
    String? icon,
    DateTime? createdAt,
  }) {
    return CategoryEntity(
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
