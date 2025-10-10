// item_detail_screen.dart

import 'package:flutter/material.dart';
// Assuming other imports are here (widgets.dart, cart_page.dart)
import 'cart_page.dart';
import '../widgets/itemcard.dart';
import '../widgets/size_buttons.dart';
// Assuming PlaceholderImage, SizeButton, etc. are defined

class ItemDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  // ... (State variables, initState, and helper methods remain unchanged)
  final Map<String, double> sizePriceModifiers = const {
    'S': 0.00,
    'M': 1.50,
    'L': 3.00,
  };

  String _selectedSize = 'M';
  late double _currentPrice;
  late final String itemName;
  late final double basePrice;

  @override
  void initState() {
    super.initState();
    itemName = widget.item['title'] as String;
    basePrice = widget.item['price'] as double;
    _currentPrice = basePrice + sizePriceModifiers[_selectedSize]!;
  }

  void _selectSize(String size) {
    setState(() {
      _selectedSize = size;
      _currentPrice = basePrice + sizePriceModifiers[_selectedSize]!;
    });
  }

  void _addToCart(BuildContext context) {
    // ... (Add to Cart logic remains unchanged)
    final newItem = CartItem(
      name: itemName,
      size: _selectedSize,
      price: _currentPrice,
      quantity: 1,
    );
    CartPage.addItem(newItem);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$itemName (${_selectedSize}) added to cart for \$${_currentPrice.toStringAsFixed(2)}!',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // --- Header Image Section (Fixed Height) ---
          Stack(
            children: [
              PlaceholderImage(
                imageUrl: widget.item['imageUrl'],
                height: 350,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                top: 40,
                right: 10,
                child: IconButton(
                  icon: const Icon(
                    Icons.star_border,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),

          // --- Details Section (MAKE THIS SCROLLABLE) ---
          Expanded(
            // Allows the inner SingleChildScrollView to take available space
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        itemName,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${_currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Description (Using the description from the topPicks map)
                  Text(
                    widget.item['description'] as String,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),

                  const SizedBox(height: 30),

                  // Select Portion Size Title
                  const Text(
                    'Select Portion Size',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 15),

                  // Size Selector Buttons
                  Row(
                    children: ['S', 'M', 'L'].map((size) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: SizeButton(
                          size: size,
                          isSelected: _selectedSize == size,
                          onSelect: _selectSize,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(
                    height: 50,
                  ), // Add padding here if more content is expected
                ],
              ),
            ),
          ),

          // --- Floating 'Add to Cart' Button (Fixed at Bottom) ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _addToCart(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                elevation: 0,
              ),
              child: const Text(
                'ADD TO CART',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ... (SizeButton and other helper classes remain unchanged)
