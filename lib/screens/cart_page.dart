import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    const double deliveryFee = 3.00;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              Provider.of<CartProvider>(context, listen: false).clearCart();
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          final cartItems = cart.items;
          final subtotal = cart.totalAmount;
          final total = subtotal + (cartItems.isEmpty ? 0 : deliveryFee);

          return Column(
            children: [
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
                            onRemove: () => cart.removeFromCart(item),
                            onAdd: () => cart.addSingleItem(item),
                            onReduce: () => cart.removeSingleItem(item),
                          );
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.black12, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:', style: TextStyle(fontSize: 16)),
                        Text(
                          '\$${subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    if (cartItems.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Delivery Fee:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '\$${deliveryFee.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                    const Divider(height: 20, thickness: 1),
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
          );
        },
      ),
    );
  }
}

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onAdd;
  final VoidCallback onReduce;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onAdd,
    required this.onReduce,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.imageUrl.isNotEmpty
                  ? (item.imageUrl.startsWith('http')
                        ? Image.network(item.imageUrl, fit: BoxFit.cover)
                        : Image.asset(item.imageUrl, fit: BoxFit.cover))
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.restaurant, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(width: 15),
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
          Column(
            children: [
              Row(
                children: [
                  _QuantityButton(icon: Icons.remove, onPressed: onReduce),
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
                  _QuantityButton(icon: Icons.add, onPressed: onAdd),
                ],
              ),
              const SizedBox(height: 5),
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
