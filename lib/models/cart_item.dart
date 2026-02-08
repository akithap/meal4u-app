class CartItem {
  final String id;
  final String name;
  final String size;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.size,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'size': size,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      name: map['name'],
      size: map['size'],
      price: map['price'],
      imageUrl: map['imageUrl'],
      quantity: map['quantity'],
    );
  }
}
