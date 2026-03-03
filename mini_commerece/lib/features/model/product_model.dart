class ProductListResponse {
  final List<Product> products;

  ProductListResponse({required this.products});

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['products'] as List<dynamic>? ?? [])
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();

    return ProductListResponse(products: list);
  }
}

class Product {
  final int id;
  final String title;
  final String thumbnail;
  final double price;
  final double rating;

  Product({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.price,
    required this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? 0) as int,
      title: (json['title'] ?? '') as String,
      thumbnail: (json['thumbnail'] ?? '') as String,
      price: (json['price'] as num? ?? 0).toDouble(),
      rating: (json['rating'] as num? ?? 0).toDouble(),
    );
  }
}
