import 'package:json_annotation/json_annotation.dart';

part 'favorite_model.g.dart';

@JsonSerializable()
class Favorite {
  final int? id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'item_id')
  final String itemId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  Favorite({
    this.id,
    required this.userId,
    required this.itemId,
    this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) =>
      _$FavoriteFromJson(json);
  Map<String, dynamic> toJson() => _$FavoriteToJson(this);

  Favorite copyWith({
    int? id,
    String? userId,
    String? itemId,
    DateTime? createdAt,
  }) {
    return Favorite(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Favorite(id: $id, userId: $userId, itemId: $itemId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Favorite &&
        other.userId == userId &&
        other.itemId == itemId;
  }

  @override
  int get hashCode => Object.hash(userId, itemId);
}

// 즐겨찾기 추가를 위한 요청 모델
@JsonSerializable()
class CreateFavoriteRequest {
  @JsonKey(name: 'item_id')
  final String itemId;

  CreateFavoriteRequest({
    required this.itemId,
  });

  factory CreateFavoriteRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateFavoriteRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateFavoriteRequestToJson(this);
}

// 즐겨찾기 상품과 함께 반환되는 모델 (ShoppingItem 정보 포함)
@JsonSerializable()
class FavoriteWithItem {
  final int? id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'item_id')
  final String itemId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'shopping_item')
  final Map<String, dynamic>? shoppingItem;

  FavoriteWithItem({
    this.id,
    required this.userId,
    required this.itemId,
    this.createdAt,
    this.shoppingItem,
  });

  factory FavoriteWithItem.fromJson(Map<String, dynamic> json) =>
      _$FavoriteWithItemFromJson(json);
  Map<String, dynamic> toJson() => _$FavoriteWithItemToJson(this);

  // ShoppingItem 정보 파싱
  Map<String, dynamic>? get itemDetails => shoppingItem;

  String? get itemName => shoppingItem?['name'];
  String? get itemImageUrl => shoppingItem?['image_url'];
  double? get itemPrice => shoppingItem?['price']?.toDouble();
  String? get itemCategory => shoppingItem?['category'];
  double? get itemRating => shoppingItem?['rating']?.toDouble();
  bool get itemIsAvailable => shoppingItem?['is_available'] ?? false;

  @override
  String toString() {
    return 'FavoriteWithItem(id: $id, userId: $userId, itemId: $itemId, itemName: $itemName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteWithItem &&
        other.userId == userId &&
        other.itemId == itemId;
  }

  @override
  int get hashCode => Object.hash(userId, itemId);
}
