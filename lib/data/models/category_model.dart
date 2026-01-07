import '../../domain/entities/category_entity.dart';

/// Category model for JSON serialization
class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.categoryId,
    required super.name,
    required super.type,
    super.icon,
    required super.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'name': name,
      'type': type,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
