import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  final String selectedVariant; // Stores "Size: M", "Color: Red", etc.

  CartItem({
    required this.product, 
    this.quantity = 1,
    this.selectedVariant = '',
  });

  double get total => product.price * quantity;

  // FEATURE: Safe Quantity Management
  void increment() {
    quantity++;
  }

  void decrement() {
    if (quantity > 1) {
      quantity--;
    }
  }

  // FEATURE: CopyWith
  // Useful if you need to update the variant or quantity immutably
  CartItem copyWith({
    Product? product,
    int? quantity,
    String? selectedVariant,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedVariant: selectedVariant ?? this.selectedVariant,
    );
  }

  // FEATURE: Serialization
  // Essential for saving the cart to SharedPreferences or a Database
  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(), // Assumes your Product class has a toMap() method
      'quantity': quantity,
      'selectedVariant': selectedVariant,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product.fromMap(map['product']), // Assumes your Product class has a fromMap() method
      quantity: map['quantity'] ?? 1,
      selectedVariant: map['selectedVariant'] ?? '',
    );
  }
}