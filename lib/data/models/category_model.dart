import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String? id;
  final String name;
  final String? parentCategoryId;
  final String? parentCategoryName;
  final String? description;
  final double? profitMarginTarget;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final bool isActive;
  final int productCount;
  final String? colorCode;
  final String? icon;

  const Category({
    this.id,
    required this.name,
    this.parentCategoryId,
    this.parentCategoryName,
    this.description,
    this.profitMarginTarget,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.isActive = true,
    this.productCount = 0,
    this.colorCode,
    this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? json['_id'],
      name: json['name'] ?? '',
      parentCategoryId: json['parentCategoryId'],
      parentCategoryName: json['parentCategoryName'],
      description: json['description'],
      profitMarginTarget: (json['profitMarginTarget'] as num?)?.toDouble(),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      createdBy: json['createdBy']?.toString() ?? 'unknown',
      isActive: json['isActive'] ?? true,
      productCount: (json['productCount'] as num?)?.toInt() ?? 0,
      colorCode: json['colorCode'],
      icon: json['icon'],
    );
  }

  // Factory for creating new category (used locally)
  factory Category.create({
    required String name,
    required String createdBy,
    String? parentCategoryId,
    String? parentCategoryName,
    String? description,
    double? profitMarginTarget,
    String? colorCode,
    String? icon,
  }) {
    final now = DateTime.now();
    return Category(
      name: name,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
      parentCategoryId: parentCategoryId,
      parentCategoryName: parentCategoryName,
      description: description,
      profitMarginTarget: profitMarginTarget,
      colorCode: colorCode,
      icon: icon,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'parentCategoryId': parentCategoryId,
    'description': description,
    'profitMarginTarget': profitMarginTarget,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'createdBy': createdBy,
    'isActive': isActive,
    'productCount': productCount,
    'colorCode': colorCode,
    'icon': icon,
  };

  Category copyWith({
    String? id,
    String? name,
    String? parentCategoryId,
    String? parentCategoryName,
    String? description,
    double? profitMarginTarget,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    bool? isActive,
    int? productCount,
    String? colorCode,
    String? icon,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      parentCategoryName: parentCategoryName ?? this.parentCategoryName,
      description: description ?? this.description,
      profitMarginTarget: profitMarginTarget ?? this.profitMarginTarget,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
      productCount: productCount ?? this.productCount,
      colorCode: colorCode ?? this.colorCode,
      icon: icon ?? this.icon,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    parentCategoryId,
    description,
    profitMarginTarget,
    createdAt,
    updatedAt,
    createdBy,
    isActive,
    productCount,
    colorCode,
    icon,
  ];
}
