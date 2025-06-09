// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************


ShoppingItem _$ShoppingItemFromJson(Map<String, dynamic> json) => ShoppingItem(
  id: (json['id'] as num?)?.toInt(),
  itemId: json['item_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  price: (json['price'] as num).toDouble(),
  category: json['category'] as String,
  brand: json['brand'] as String?,
  imageUrl: json['image_url'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  reviewCount: (json['review_count'] as num?)?.toInt(),
  stockQuantity: (json['stock_quantity'] as num?)?.toInt(),
  isAvailable: json['is_available'] as bool? ?? true,
  isFeatured: json['is_featured'] as bool? ?? false,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ShoppingItemToJson(ShoppingItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_id': instance.itemId,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'category': instance.category,
      'brand': instance.brand,
      'image_url': instance.imageUrl,
      'rating': instance.rating,
      'review_count': instance.reviewCount,
      'stock_quantity': instance.stockQuantity,
      'is_available': instance.isAvailable,
      'is_featured': instance.isFeatured,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

CreateShoppingItemRequest _$CreateShoppingItemRequestFromJson(
    Map<String, dynamic> json) =>
    CreateShoppingItemRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      brand: json['brand'] as String?,
      imageUrl: json['image_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: (json['review_count'] as num?)?.toInt(),
      stockQuantity: (json['stock_quantity'] as num?)?.toInt(),
      isAvailable: json['is_available'] as bool?,
      isFeatured: json['is_featured'] as bool?,
    );

Map<String, dynamic> _$CreateShoppingItemRequestToJson(
    CreateShoppingItemRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'category': instance.category,
      'brand': instance.brand,
      'image_url': instance.imageUrl,
      'rating': instance.rating,
      'review_count': instance.reviewCount,
      'stock_quantity': instance.stockQuantity,
      'is_available': instance.isAvailable,
      'is_featured': instance.isFeatured,
    };

UpdateShoppingItemRequest _$UpdateShoppingItemRequestFromJson(
    Map<String, dynamic> json) =>
    UpdateShoppingItemRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      category: json['category'] as String?,
      brand: json['brand'] as String?,
      imageUrl: json['image_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: (json['review_count'] as num?)?.toInt(),
      stockQuantity: (json['stock_quantity'] as num?)?.toInt(),
      isAvailable: json['is_available'] as bool?,
      isFeatured: json['is_featured'] as bool?,
    );

Map<String, dynamic> _$UpdateShoppingItemRequestToJson(
    UpdateShoppingItemRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'category': instance.category,
      'brand': instance.brand,
      'image_url': instance.imageUrl,
      'rating': instance.rating,
      'review_count': instance.reviewCount,
      'stock_quantity': instance.stockQuantity,
      'is_available': instance.isAvailable,
      'is_featured': instance.isFeatured,
    };
