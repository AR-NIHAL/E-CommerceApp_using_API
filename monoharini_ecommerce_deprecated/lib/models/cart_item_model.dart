class CartItemModel {
  final int id;
  final String title;
  final double price;
  final String thumbnail;
  final int quantity;

  CartItemModel({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnail,
    required this.quantity,
  });

  CartItemModel copyWith({
    int? id,
    String? title,
    double? price,
    String? thumbnail,
    int? quantity,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      thumbnail: thumbnail ?? this.thumbnail,
      quantity: quantity ?? this.quantity,
    );
  }
}
