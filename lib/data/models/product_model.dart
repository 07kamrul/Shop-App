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

  // Calculated properties
  double get profitPerUnit => sellingPrice - buyingPrice;
  double get profitMargin =>
      sellingPrice > 0 ? (profitPerUnit / sellingPrice) * 100 : 0.0;
  bool get isLowStock => currentStock <= minStockLevel;
  bool get isOutOfStock => currentStock <= 0;
  double get totalValue => currentStock * buyingPrice;

  // Convert from JSON (API response)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? json['_id'],
      name: json['name'] ?? '',
      barcode: json['barcode'],
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      buyingPrice: (json['buyingPrice'] ?? 0).toDouble(),
      sellingPrice: (json['sellingPrice'] ?? 0).toDouble(),
      currentStock: json['currentStock'] ?? 0,
      minStockLevel: json['minStockLevel'] ?? 10,
      supplierId: json['supplierId'],
      supplierName: json['supplierName'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      createdBy: json['createdBy'] ?? '',
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      isActive: json['isActive'] ?? true,
    );
  }

  // Convert to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      if (id != null && id!.isNotEmpty) 'id': id,
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
      'createdBy': createdBy,
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Factory for creating new products
  factory Product.create({
    required String name,
    String? barcode,
    required String categoryId,
    String categoryName = '',
    required double buyingPrice,
    required double sellingPrice,
    int currentStock = 0,
    int minStockLevel = 10,
    String? supplierId,
    String? supplierName,
    required String createdBy,
  }) {
    final now = DateTime.now();
    return Product(
      name: name,
      barcode: barcode,
      categoryId: categoryId,
      categoryName: categoryName,
      buyingPrice: buyingPrice,
      sellingPrice: sellingPrice,
      currentStock: currentStock,
      minStockLevel: minStockLevel,
      supplierId: supplierId,
      supplierName: supplierName,
      createdAt: now,
      createdBy: createdBy,
      updatedAt: now,
      isActive: true,
    );
  }

  // Convert to JSON for creating new product
  Map<String, dynamic> toCreateJson() {
    final now = DateTime.now();
    return {
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
      'createdAt': now.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': now.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Convert to JSON for updating product
  Map<String, dynamic> toUpdateJson() {
    return {
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
      'createdBy': createdBy,
      'updatedAt': DateTime.now().toIso8601String(),
      'isActive': isActive,
    };
  }

  // For partial updates (PATCH requests)
  Map<String, dynamic> toPartialUpdateJson() {
    final jsonMap = <String, dynamic>{};

    if (name.isNotEmpty) jsonMap['name'] = name;
    if (barcode != null) jsonMap['barcode'] = barcode;
    if (categoryId.isNotEmpty) jsonMap['categoryId'] = categoryId;
    if (categoryName.isNotEmpty) jsonMap['categoryName'] = categoryName;

    jsonMap['buyingPrice'] = buyingPrice;
    jsonMap['sellingPrice'] = sellingPrice;
    jsonMap['currentStock'] = currentStock;
    jsonMap['minStockLevel'] = minStockLevel;

    if (supplierId != null) jsonMap['supplierId'] = supplierId;
    if (supplierName != null) jsonMap['supplierName'] = supplierName;

    jsonMap['createdBy'] = createdBy;
    jsonMap['updatedAt'] = DateTime.now().toIso8601String();
    jsonMap['isActive'] = isActive;

    return jsonMap;
  }

  // For stock updates only
  Map<String, dynamic> toStockUpdateJson() {
    return {
      'currentStock': currentStock,
      'createdBy': createdBy,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // For price updates only
  Map<String, dynamic> toPriceUpdateJson() {
    return {
      'buyingPrice': buyingPrice,
      'sellingPrice': sellingPrice,
      'createdBy': createdBy,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Validation methods
  bool get isValidForCreation {
    return name.isNotEmpty &&
        categoryId.isNotEmpty &&
        buyingPrice >= 0 &&
        sellingPrice >= buyingPrice &&
        createdBy.isNotEmpty;
  }

  bool get isValidForUpdate {
    return id != null && id!.isNotEmpty && isValidForCreation;
  }

  // Stock management methods
  Product increaseStock(int quantity) {
    return copyWith(currentStock: currentStock + quantity);
  }

  Product decreaseStock(int quantity) {
    final newStock = currentStock - quantity;
    return copyWith(currentStock: newStock >= 0 ? newStock : 0);
  }

  Product updateStock(int newStock) {
    return copyWith(currentStock: newStock >= 0 ? newStock : 0);
  }

  Product updatePrices({
    required double newBuyingPrice,
    required double newSellingPrice,
  }) {
    return copyWith(buyingPrice: newBuyingPrice, sellingPrice: newSellingPrice);
  }

  Product deactivate() {
    return copyWith(isActive: false);
  }

  Product activate() {
    return copyWith(isActive: true);
  }

  Product updateCategory(String newCategoryId, String newCategoryName) {
    return copyWith(
      categoryId: newCategoryId,
      categoryName: newCategoryName,
    );
  }

  Product updateSupplier(String? newSupplierId, String? newSupplierName) {
    return copyWith(
      supplierId: newSupplierId,
      supplierName: newSupplierName,
    );
  }

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