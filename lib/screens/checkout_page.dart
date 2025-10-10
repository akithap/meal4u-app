import 'package:flutter/material.dart';
import 'cart_page.dart'; // Import to access CartPage.cartItems

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  String _paymentMethod = 'Credit Card';

  // --- New function to handle placing the order ---
  void _placeOrder() {
    if (_formKey.currentState!.validate()) {
      // 1. Process order logic (simulated)

      // 2. CLEAR THE CART
      CartPage.cartItems.clear();

      // 3. Navigate to confirmation page
      Navigator.pushReplacementNamed(context, '/confirmation');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Delivery Address Section ---
              const Text(
                'Delivery Address',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 20, thickness: 1),

              _buildTextFormField(
                label: 'Street Address',
                hint: '123 Main St',
                icon: Icons.location_on_outlined,
              ),
              _buildTextFormField(
                label: 'City',
                hint: 'New York',
                icon: Icons.apartment_outlined,
              ),
              _buildTextFormField(
                label: 'Postal Code',
                hint: '10001',
                icon: Icons.markunread_mailbox_outlined,
              ),
              const SizedBox(height: 30),

              // --- Payment Method Section ---
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 20, thickness: 1),

              _buildPaymentTile('Credit Card', Icons.credit_card),
              _buildPaymentTile('PayPal', Icons.payment),
              _buildPaymentTile('Cash on Delivery', Icons.money),

              const SizedBox(height: 50),

              // "Place Order" Button
              ElevatedButton(
                // Use the new function here
                onPressed: _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                child: const Text(
                  'PLACE ORDER',
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
      ),
    );
  }

  // --- Helper Widgets (unchanged) ---

  Widget _buildTextFormField({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPaymentTile(String title, IconData icon) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      secondary: Icon(icon),
      value: title,
      groupValue: _paymentMethod,
      onChanged: (value) {
        setState(() {
          _paymentMethod = value!;
        });
      },
      contentPadding: EdgeInsets.zero,
      activeColor: Colors.black,
    );
  }
}
