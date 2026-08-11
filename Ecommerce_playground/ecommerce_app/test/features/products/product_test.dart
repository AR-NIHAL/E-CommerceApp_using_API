import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app/features/products/domain/entities/product.dart';

void main() {
  const json = {
    'id': 1,
    'title': 'Essence Mascara Lash Princess',
    'description': 'Volumizing mascara',
    'category': 'beauty',
    'price': 9.99,
    'discountPercentage': 10.48,
    'rating': 2.56,
    'stock': 99,
    'brand': 'Essence',
    'thumbnail': 'https://example.com/thumb.webp',
    'images': [
      'https://example.com/1.webp',
      'https://example.com/2.webp',
    ],
  };

  test('Product.fromJson maps all fields', () {
    final product = Product.fromJson(json);

    expect(product.id, 1);
    expect(product.title, 'Essence Mascara Lash Princess');
    expect(product.category, 'beauty');
    expect(product.price, 9.99);
    expect(product.discountPercentage, 10.48);
    expect(product.rating, 2.56);
    expect(product.stock, 99);
    expect(product.brand, 'Essence');
    expect(product.thumbnail, 'https://example.com/thumb.webp');
    expect(product.images, hasLength(2));
  });

  test('Product.fromJson tolerates missing optional fields', () {
    final product = Product.fromJson({
      'id': 2,
      'title': 'T-Shirt',
      'price': 19.99,
    });

    expect(product.description, '');
    expect(product.discountPercentage, 0);
    expect(product.rating, 0);
    expect(product.images, isEmpty);
  });

  test('discountPrice computes discounted amount', () {
    final product = Product.fromJson({
      'id': 3,
      'title': 'Shoes',
      'price': 100,
      'discountPercentage': 25,
    });

    expect(product.hasDiscount, isTrue);
    expect(product.discountPrice, 75.0);
  });

  test('no discount when discountPercentage is zero', () {
    final product = Product.fromJson({
      'id': 4,
      'title': 'Hat',
      'price': 10,
    });

    expect(product.hasDiscount, isFalse);
    expect(product.discountPrice, 10.0);
  });
}
