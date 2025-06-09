import 'package:json_annotation/json_annotation.dart';

part 'shopping_item_model.g.dart';

@JsonSerializable()
class ShoppingItem {
  final int? id;
  @JsonKey(name: 'item_id')
  final String itemId;
  final String name;
  final String? description;
  final double price;
  final String category;
  final String? brand;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final double? rating;
  @JsonKey(name: 'review_count')
  final int? reviewCount;
  @JsonKey(name: 'stock_quantity')
  final int? stockQuantity;
  @JsonKey(name: 'is_available')
  final bool isAvailable;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  ShoppingItem({
    this.id,
    required this.itemId,
    required this.name,
    this.description,
    required this.price,
    required this.category,
    this.brand,
    this.imageUrl,
    this.rating,
    this.reviewCount,
    this.stockQuantity,
    this.isAvailable = true,
    this.isFeatured = false,
    this.createdAt,
    this.updatedAt,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) =>
      _$ShoppingItemFromJson(json);
  Map<String, dynamic> toJson() => _$ShoppingItemToJson(this);

  ShoppingItem copyWith({
    int? id,
    String? itemId,
    String? name,
    String? description,
    double? price,
    String? category,
    String? brand,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    int? stockQuantity,
    bool? isAvailable,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 가격을 포맷팅된 문자열로 반환
  String get formattedPrice {
    return '₩${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    )}';
  }

  // 재고 상태 확인
  bool get isInStock => stockQuantity != null && stockQuantity! > 0;

  // 재고 부족 여부 확인 (10개 이하)
  bool get isLowStock => stockQuantity != null && stockQuantity! <= 10 && stockQuantity! > 0;

  // 품절 여부 확인
  bool get isOutOfStock => stockQuantity == null || stockQuantity! <= 0;

  @override
  String toString() {
    return 'ShoppingItem(id: $id, itemId: $itemId, name: $name, price: $price, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShoppingItem && other.itemId == itemId;
  }

  @override
  int get hashCode => itemId.hashCode;
}

// 쇼핑 아이템 생성을 위한 요청 모델 (관리자용)
@JsonSerializable()
class CreateShoppingItemRequest {
  final String name;
  final String? description;
  final double price;
  final String category;
  final String? brand;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final double? rating;
  @JsonKey(name: 'review_count')
  final int? reviewCount;
  @JsonKey(name: 'stock_quantity')
  final int? stockQuantity;
  @JsonKey(name: 'is_available')
  final bool? isAvailable;
  @JsonKey(name: 'is_featured')
  final bool? isFeatured;

  CreateShoppingItemRequest({
    required this.name,
    this.description,
    required this.price,
    required this.category,
    this.brand,
    this.imageUrl,
    this.rating,
    this.reviewCount,
    this.stockQuantity,
    this.isAvailable,
    this.isFeatured,
  });

  factory CreateShoppingItemRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateShoppingItemRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateShoppingItemRequestToJson(this);
}

// 쇼핑 아이템 업데이트를 위한 요청 모델 (관리자용)
@JsonSerializable()
class UpdateShoppingItemRequest {
  final String? name;
  final String? description;
  final double? price;
  final String? category;
  final String? brand;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final double? rating;
  @JsonKey(name: 'review_count')
  final int? reviewCount;
  @JsonKey(name: 'stock_quantity')
  final int? stockQuantity;
  @JsonKey(name: 'is_available')
  final bool? isAvailable;
  @JsonKey(name: 'is_featured')
  final bool? isFeatured;

  UpdateShoppingItemRequest({
    this.name,
    this.description,
    this.price,
    this.category,
    this.brand,
    this.imageUrl,
    this.rating,
    this.reviewCount,
    this.stockQuantity,
    this.isAvailable,
    this.isFeatured,
  });

  factory UpdateShoppingItemRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateShoppingItemRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateShoppingItemRequestToJson(this);
}

// 쇼핑 아이템 필터링을 위한 요청 모델
class ShoppingItemFilter {
  final String? category;
  final String? brand;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final bool? isAvailable;
  final bool? isFeatured;
  final String? searchKeyword;
  final String? sortBy; // price, rating, name, created_at
  final String? sortOrder; // asc, desc

  ShoppingItemFilter({
    this.category,
    this.brand,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.isAvailable,
    this.isFeatured,
    this.searchKeyword,
    this.sortBy,
    this.sortOrder,
  });

  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {};

    if (category != null) params['category'] = category;
    if (brand != null) params['brand'] = brand;
    if (minPrice != null) params['minPrice'] = minPrice.toString();
    if (maxPrice != null) params['maxPrice'] = maxPrice.toString();
    if (minRating != null) params['minRating'] = minRating.toString();
    if (isAvailable != null) params['isAvailable'] = isAvailable.toString();
    if (isFeatured != null) params['isFeatured'] = isFeatured.toString();
    if (searchKeyword != null && searchKeyword!.isNotEmpty) {
      params['search'] = searchKeyword;
    }
    if (sortBy != null) params['sortBy'] = sortBy;
    if (sortOrder != null) params['sortOrder'] = sortOrder;

    return params;
  }
}
