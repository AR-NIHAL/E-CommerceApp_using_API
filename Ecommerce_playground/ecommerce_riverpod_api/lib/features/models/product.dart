class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String image;
  final String category;

  final double rating;
  final int ratingCount;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.image,
    required this.category,
    required this.rating,
    required this.ratingCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final ratingObj = (json['rating'] is Map<String, dynamic>)
        ? (json['rating'] as Map<String, dynamic>)
        : <String, dynamic>{};

    return Product(
      id: (json['id'] as num).toInt(),
      title: json['title'] ?? '',
      price: (json['price'] as num).toDouble(),
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      category: json['category'] ?? '',
      rating: ratingObj['rate'] == null
          ? 0.0
          : (ratingObj['rate'] as num).toDouble(),
      ratingCount: ratingObj['count'] == null
          ? 0
          : (ratingObj['count'] as num).toInt(),
    );
  }
}
