class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.thumbnail,
    required this.images,
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final String thumbnail;
  final List<String> images;

  double get discountPrice =>
      price - (price * discountPercentage / 100);

  bool get hasDiscount => discountPercentage > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    final imagesRaw = json['images'] as List<dynamic>? ?? const [];
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      discountPercentage: (json['discountPercentage'] as num? ?? 0).toDouble(),
      rating: (json['rating'] as num? ?? 0).toDouble(),
      stock: json['stock'] as int? ?? 0,
      brand: json['brand'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      images: imagesRaw.cast<String>(),
    );
  }
}
