import 'package:flutter/material.dart';

// Dummy Cart Item Model (already defined)
class CartItem {
  final String name;
  final String size;
  final double price;
  int quantity;

  CartItem({
    required this.name,
    required this.size,
    required this.price,
    this.quantity = 1,
  });
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  // MAKE THE CART DATA STATIC so we can access and modify it globally
  static List<CartItem> cartItems = [
    // You can remove these initial samples if you want the cart to start empty
  ];

  // Helper method to simulate adding an item
  static void addItem(CartItem newItem) {
    // Simple logic to check if item already exists (based on name and size)
    int index = cartItems.indexWhere(
      (item) => item.name == newItem.name && item.size == newItem.size,
    );

    if (index != -1) {
      // If found, increment quantity
      cartItems[index].quantity += newItem.quantity;
    } else {
      // If not found, add new item
      cartItems.add(newItem);
    }
  }

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Now reference the static list from the StatefulWidget
  List<CartItem> get cartItems => CartPage.cartItems;

  void _removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  void _adjustQuantity(int index, int delta) {
    setState(() {
      if (cartItems[index].quantity + delta > 0) {
        cartItems[index].quantity += delta;
      } else {
        // Option to remove item if quantity drops to zero
        _removeItem(index);
      }
    });
  }

  double get _subtotal =>
      cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  @override
  Widget build(BuildContext context) {
    // ... (rest of the build method is the same)
    // The rest of the CartPage code below is unchanged from the original implementation

    const double deliveryFee = 3.00;
    final double total = _subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // --- Cart Items List ---
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
                    child: Text(
                      'Your cart is empty! 🛒',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: cartItems.length,
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 20,
                      right: 20,
                    ),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return CartItemTile(
                        item: item,
                        // Note: These methods still need to call setState to update the UI on this page
                        onRemove: () => _removeItem(index),
                        onAdjustQuantity: (delta) =>
                            _adjustQuantity(index, delta),
                      );
                    },
                  ),
          ),

          // --- Total Summary and Checkout Button ---
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black12, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subtotal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:', style: TextStyle(fontSize: 16)),
                    Text(
                      '\$${_subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // Delivery Fee
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Delivery Fee:', style: TextStyle(fontSize: 16)),
                    Text(
                      '\$${deliveryFee.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const Divider(height: 20, thickness: 1),
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // "Proceed to Checkout" Button
                ElevatedButton(
                  onPressed: cartItems.isEmpty
                      ? null
                      : () => Navigator.pushNamed(context, '/checkout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: const Text(
                    'PROCEED TO CHECKOUT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Widget for a single item in the cart (CartItemTile, _QuantityButton)
class CartItemTile extends StatelessWidget {
  // ... (unchanged code)
  final CartItem item;
  final VoidCallback onRemove;
  final Function(int) onAdjustQuantity;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onAdjustQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Image Placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.restaurant, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 15),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Size: ${item.size}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Quantity and Remove Button
          Column(
            children: [
              // Quantity Adjuster
              Row(
                children: [
                  _QuantityButton(
                    icon: Icons.remove,
                    onPressed: () => onAdjustQuantity(-1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      item.quantity.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _QuantityButton(
                    icon: Icons.add,
                    onPressed: () => onAdjustQuantity(1),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              // Remove Button
              GestureDetector(
                onTap: onRemove,
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
