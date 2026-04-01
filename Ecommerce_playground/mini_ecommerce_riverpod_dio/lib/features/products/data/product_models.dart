class Product {
  final int id;
  final String title;
  final String description;
  final num price;
  final num rating;
  final String thumbnail;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.thumbnail,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      price: (json['price'] ?? 0) as num,
      rating: (json['rating'] ?? 0) as num,
      thumbnail: (json['thumbnail'] ?? '') as String,
    );
  }
}


class ProductsResponse {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  ProductsResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['products'] as List<dynamic>? ?? [])
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();

    return ProductsResponse(
      products: list,
      total: (json['total'] as num? ?? 0).toInt(),
      skip: (json['skip'] as num? ?? 0).toInt(),
      limit: (json['limit'] as num? ?? 0).toInt(),
    );
  }
}