class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final Map<String, List<String>> variants;
  bool isFavorite; // Kept mutable as per your original code

  // 🟢 NEW FIELDS
  final int stock;
  final List<String> gallery;

  Product({
    required this.id,
    required this.title,
    this.description = 'No description available',
    required this.price,
    required this.imageUrl,
    required this.category,
    this.variants = const {},
    this.isFavorite = false,
    this.stock = 10,
    this.gallery = const [],
  });

  // FEATURE: Serialization (Required for CartItem.toMap to work)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'variants': variants,
      'isFavorite': isFavorite,
      'stock': stock,
      'gallery': gallery,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? 'Unknown Product',
      description: map['description'] ?? 'No description available',
      price: (map['price'] is num) ? (map['price'] as num).toDouble() : 0.0,
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? 'Uncategorized',
      variants: Map<String, List<String>>.from(
          map['variants']?.map((k, v) => MapEntry(k, List<String>.from(v))) ?? {}
      ),
      isFavorite: map['isFavorite'] ?? false,
      stock: map['stock'] ?? 0,
      gallery: List<String>.from(map['gallery'] ?? []),
    );
  }

  // FEATURE: CopyWith (Useful for state management)
  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    Map<String, List<String>>? variants,
    bool? isFavorite,
    int? stock,
    List<String>? gallery,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      variants: variants ?? this.variants,
      isFavorite: isFavorite ?? this.isFavorite,
      stock: stock ?? this.stock,
      gallery: gallery ?? this.gallery,
    );
  }
}