// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Favorite _$FavoriteFromJson(Map<String, dynamic> json) => Favorite(
  id: (json['id'] as num?)?.toInt(),
  userId: json['user_id'] as String,
  itemId: json['item_id'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$FavoriteToJson(Favorite instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'item_id': instance.itemId,
  'created_at': instance.createdAt?.toIso8601String(),
};

CreateFavoriteRequest _$CreateFavoriteRequestFromJson(
    Map<String, dynamic> json) =>
    CreateFavoriteRequest(
      itemId: json['item_id'] as String,
    );

Map<String, dynamic> _$CreateFavoriteRequestToJson(
    CreateFavoriteRequest instance) =>
    <String, dynamic>{
      'item_id': instance.itemId,
    };

FavoriteWithItem _$FavoriteWithItemFromJson(Map<String, dynamic> json) =>
    FavoriteWithItem(
      id: (json['id'] as num?)?.toInt(),
      userId: json['user_id'] as String,
      itemId: json['item_id'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      shoppingItem: json['shopping_item'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$FavoriteWithItemToJson(FavoriteWithItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'item_id': instance.itemId,
      'created_at': instance.createdAt?.toIso8601String(),
      'shopping_item': instance.shoppingItem,
    };
