class BookingModel {
  final String? id;
  final String name;
  final double price;
  final String description;
  final String images;
  final String category;
  final int quantity;

  BookingModel({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.images,
    required this.category,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'images': images,
      'category': category,
      'quantity': quantity,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return BookingModel(
      id: docId ?? '',
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      description: map['description'],
      images: map['images'] ?? '',
      category: map['category'],
      quantity: map['quantity'],
    );
  }
}
