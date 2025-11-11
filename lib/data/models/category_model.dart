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

  // Convert from JSON (API response)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? json['_id'],
      name: json['name'] ?? '',
      parentCategoryId: json['parentCategoryId'],
      parentCategoryName: json['parentCategoryName'],
      description: json['description'],
      profitMarginTarget: (json['profitMarginTarget'] ?? 0).toDouble(),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      createdBy: json['createdBy'] ?? '',
      isActive: json['isActive'] ?? true,
      productCount: json['productCount'] ?? 0,
      colorCode: json['colorCode'],
      icon: json['icon'],
    );
  }

  // Convert to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      if (id != null && id!.isNotEmpty) 'id': id,
      'name': name,
      'parentCategoryId': parentCategoryId,
      'parentCategoryName': parentCategoryName,
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
  }

  // Factory for creating new categories
  factory Category.create({
    required String name,
    String? parentCategoryId,
    String? parentCategoryName,
    String? description,
    double? profitMarginTarget,
    required String createdBy,
    String? colorCode,
    String? icon,
  }) {
    final now = DateTime.now();
    return Category(
      name: name,
      parentCategoryId: parentCategoryId,
      parentCategoryName: parentCategoryName,
      description: description,
      profitMarginTarget: profitMarginTarget,
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy,
      isActive: true,
      productCount: 0,
      colorCode: colorCode,
      icon: icon,
    );
  }

  // Convert to JSON for creating new category
  Map<String, dynamic> toCreateJson() {
    final now = DateTime.now();
    return {
      'name': name,
      'parentCategoryId': parentCategoryId,
      'parentCategoryName': parentCategoryName,
      'description': description,
      'profitMarginTarget': profitMarginTarget,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'createdBy': createdBy,
      'isActive': isActive,
      'colorCode': colorCode,
      'icon': icon,
    };
  }

  // Convert to JSON for updating category
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'parentCategoryId': parentCategoryId,
      'parentCategoryName': parentCategoryName,
      'description': description,
      'profitMarginTarget': profitMarginTarget,
      'updatedAt': DateTime.now().toIso8601String(),
      'isActive': isActive,
      'colorCode': colorCode,
      'icon': icon,
    };
  }

  // For partial updates (PATCH requests)
  Map<String, dynamic> toPartialUpdateJson() {
    final jsonMap = <String, dynamic>{};

    if (name.isNotEmpty) jsonMap['name'] = name;
    if (parentCategoryId != null)
      jsonMap['parentCategoryId'] = parentCategoryId;
    if (parentCategoryName != null)
      jsonMap['parentCategoryName'] = parentCategoryName;
    if (description != null) jsonMap['description'] = description;
    if (profitMarginTarget != null)
      jsonMap['profitMarginTarget'] = profitMarginTarget;

    jsonMap['updatedAt'] = DateTime.now().toIso8601String();
    jsonMap['isActive'] = isActive;

    if (colorCode != null) jsonMap['colorCode'] = colorCode;
    if (icon != null) jsonMap['icon'] = icon;

    return jsonMap;
  }

  // For updating product count only
  Map<String, dynamic> toProductCountUpdateJson() {
    return {
      'productCount': productCount,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // For updating status only
  Map<String, dynamic> toStatusUpdateJson() {
    return {
      'isActive': isActive,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Business logic methods
  bool get isRootCategory =>
      parentCategoryId == null || parentCategoryId!.isEmpty;

  bool get hasParent =>
      parentCategoryId != null && parentCategoryId!.isNotEmpty;

  bool get hasProducts => productCount > 0;

  bool get canBeDeleted =>
      productCount == 0; // Only categories without products can be deleted

  bool get hasProfitMarginTarget =>
      profitMarginTarget != null && profitMarginTarget! > 0;

  // Validation methods
  bool get isValidForCreation {
    return name.isNotEmpty && createdBy.isNotEmpty;
  }

  bool get isValidForUpdate {
    return id != null && id!.isNotEmpty && name.isNotEmpty;
  }

  // Update methods
  Category incrementProductCount() {
    return copyWith(productCount: productCount + 1, updatedAt: DateTime.now());
  }

  Category decrementProductCount() {
    final newCount = productCount - 1;
    return copyWith(
      productCount: newCount >= 0 ? newCount : 0,
      updatedAt: DateTime.now(),
    );
  }

  Category updateProductCount(int count) {
    return copyWith(
      productCount: count >= 0 ? count : 0,
      updatedAt: DateTime.now(),
    );
  }

  Category updateProfitMarginTarget(double? target) {
    return copyWith(profitMarginTarget: target, updatedAt: DateTime.now());
  }

  Category deactivate() {
    return copyWith(isActive: false, updatedAt: DateTime.now());
  }

  Category activate() {
    return copyWith(isActive: true, updatedAt: DateTime.now());
  }

  Category moveToParent(String? newParentId, String? newParentName) {
    return copyWith(
      parentCategoryId: newParentId,
      parentCategoryName: newParentName,
      updatedAt: DateTime.now(),
    );
  }

  Category makeRoot() {
    return copyWith(
      parentCategoryId: null,
      parentCategoryName: null,
      updatedAt: DateTime.now(),
    );
  }

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
    parentCategoryName,
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
