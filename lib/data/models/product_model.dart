import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String? id;
  final String name;
  final String? barcode;
  final String categoryId;
  final String categoryName;
  final double buyingPrice;
  final double sellingPrice;
  final int currentStock;
  final int minStockLevel;
  final String? supplierId;
  final String? supplierName;
  final DateTime createdAt;
  final String createdBy;
  final DateTime updatedAt;
  final bool isActive;

  const Product({
    this.id,
    required this.name,
    this.barcode,
    required this.categoryId,
    this.categoryName = '',
    required this.buyingPrice,
    required this.sellingPrice,
    required this.currentStock,
    this.minStockLevel = 10,
    this.supplierId,
    this.supplierName,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    this.isActive = true,
  });

  double get profitPerUnit => sellingPrice - buyingPrice;
  double get profitMargin =>
      sellingPrice > 0 ? (profitPerUnit / sellingPrice) * 100 : 0.0;
  bool get isLowStock => currentStock <= minStockLevel;
  bool get isOutOfStock => currentStock <= 0;
  double get totalValue => currentStock * buyingPrice;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? json['_id'],
      name: json['name'] ?? '',
      barcode: json['barcode'],
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      buyingPrice: (json['buyingPrice'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      currentStock: (json['currentStock'] as num?)?.toInt() ?? 0,
      minStockLevel: (json['minStockLevel'] as num?)?.toInt() ?? 10,
      supplierId: json['supplierId'],
      supplierName: json['supplierName'],
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      createdBy: json['createdBy']?.toString() ?? 'unknown',
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      isActive: json['isActive'] ?? true,
    );
  }

  factory Product.create({
    required String name,
    required String categoryId,
    required double buyingPrice,
    required double sellingPrice,
    required String createdBy,
    String? barcode,
    String categoryName = '',
    int currentStock = 0,
    int minStockLevel = 10,
    String? supplierId,
    String? supplierName,
  }) {
    final now = DateTime.now();
    return Product(
      name: name,
      categoryId: categoryId,
      categoryName: categoryName,
      buyingPrice: buyingPrice,
      sellingPrice: sellingPrice,
      currentStock: currentStock,
      minStockLevel: minStockLevel,
      barcode: barcode,
      supplierId: supplierId,
      supplierName: supplierName,
      createdAt: now,
      createdBy: createdBy,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'barcode': barcode,
    'categoryId': categoryId,
    'categoryName': categoryName,
    'buyingPrice': buyingPrice,
    'sellingPrice': sellingPrice,
    'currentStock': currentStock,
    'minStockLevel': minStockLevel,
    'supplierId': supplierId,
    'supplierName': supplierName,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'createdBy': createdBy,
    'isActive': isActive,
  };

  Product copyWith({
    String? id,
    String? name,
    String? barcode,
    String? categoryId,
    String? categoryName,
    double? buyingPrice,
    double? sellingPrice,
    int? currentStock,
    int? minStockLevel,
    String? supplierId,
    String? supplierName,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      buyingPrice: buyingPrice ?? this.buyingPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      currentStock: currentStock ?? this.currentStock,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    barcode,
    categoryId,
    categoryName,
    buyingPrice,
    sellingPrice,
    currentStock,
    minStockLevel,
    supplierId,
    supplierName,
    createdAt,
    createdBy,
    updatedAt,
    isActive,
  ];
}
