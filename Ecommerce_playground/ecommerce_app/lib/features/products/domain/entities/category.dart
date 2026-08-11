class Category {
  const Category({required this.slug, required this.name});

  final String slug;
  final String name;

  factory Category.fromJson(Map<String, dynamic> json) {
    final slug = json['slug'] as String? ?? json['name'] as String? ?? '';
    final name = json['name'] as String? ?? slug;
    return Category(slug: slug, name: name);
  }
}
