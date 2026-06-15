class CategoryModel {
  final String slug;
  final String name;
  final String imagePath;

  CategoryModel({
    required this.slug,
    required this.name,
    required this.imagePath,
  });

  factory CategoryModel.fromApi(dynamic json) {
    if (json is String) {
      return CategoryModel(
        slug: json,
        name: _formatName(json),
        imagePath: _getLocalImage(json),
      );
    }

    if (json is Map<String, dynamic>) {
      final slug = json['slug']?.toString() ?? '';
      final name = json['name']?.toString() ?? _formatName(slug);

      return CategoryModel(
        slug: slug,
        name: name,
        imagePath: _getLocalImage(slug),
      );
    }

    throw Exception('Invalid category format');
  }

  static String _formatName(String value) {
    return value
        .split('-')
        .map((word) {
          if (word.isEmpty) return '';
          return '${word[0].toUpperCase()}${word.substring(1)}';
        })
        .join(' ');
  }

  static String _getLocalImage(String slug) {
    const Map<String, String> imageMap = {
      'beauty': 'assets/images/categories/beauty.png',
      'fragrances': 'assets/images/categories/fragrances.png',
      'furniture': 'assets/images/categories/furniture.png',
      'groceries': 'assets/images/categories/groceries.png',
      'home-decoration': 'assets/images/categories/home_decoration.png',
      'kitchen-accessories': 'assets/images/categories/kitchen_accessories.png',
      'laptops': 'assets/images/categories/laptops.png',
      'mens-shirts': 'assets/images/categories/mens_shirts.png',
      'mens-shoes': 'assets/images/categories/mens_shoes.png',
      'mens-watches': 'assets/images/categories/mens_watches.png',
      'mobile-accessories': 'assets/images/categories/mobile_accessories.png',
      'motorcycle': 'assets/images/categories/motorcycle.png',
      'skin-care': 'assets/images/categories/skin_care.png',
      'smartphones': 'assets/images/categories/smartphones.png',
      'sports-accessories': 'assets/images/categories/sports_accessories.png',
      'sunglasses': 'assets/images/categories/sunglasses.png',
      'tablets': 'assets/images/categories/tablets.png',
      'tops': 'assets/images/categories/tops.png',
      'vehicle': 'assets/images/categories/vehicle.png',
      'womens-bags': 'assets/images/categories/womens_bags.png',
      'womens-dresses': 'assets/images/categories/womens_dresses.png',
      'womens-jewellery': 'assets/images/categories/womens_jewellery.png',
      'womens-shoes': 'assets/images/categories/womens_shoes.png',
      'womens-watches': 'assets/images/categories/womens_watches.png',
    };

    return imageMap[slug] ?? 'assets/images/categories/default.png';
  }
}
