class Equipment {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rentalPrice;
  final double purchasePrice;
  final String category;
  final double rating;
  final bool isAvailable;

  Equipment({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rentalPrice,
    required this.purchasePrice,
    required this.category,
    this.rating = 0.0,
    this.isAvailable = true,
  });

  factory Equipment.fromMap(Map<String, dynamic> map, String id) {
    return Equipment(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      rentalPrice: (map['rentalPrice'] ?? 0).toDouble(),
      purchasePrice: (map['purchasePrice'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'rentalPrice': rentalPrice,
      'purchasePrice': purchasePrice,
      'category': category,
      'rating': rating,
      'isAvailable': isAvailable,
    };
  }
}
