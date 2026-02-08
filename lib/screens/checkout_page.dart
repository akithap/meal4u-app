import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  late final _locationController =
      TextEditingController(); // late final to support hot reload
  String _paymentMethod = 'Credit Card';
  bool _isLoading = false;
  bool _isLocationLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocationLoading = true);

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
      setState(() => _isLocationLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        setState(() => _isLocationLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied.'),
          ),
        );
      setState(() => _isLocationLoading = false);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        // Update the new dedicated field
        _locationController.text =
            'Lat: ${position.latitude.toStringAsFixed(4)}, Long: ${position.longitude.toStringAsFixed(4)}';

        // Optionally clear other fields or leave them for manual entry as requested
        // _addressController.text = '';
        // _cityController.text = '';
      });
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Location Fetched!')));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLocationLoading = false);
    }
  }

  Future<void> _placeOrder() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final cart = Provider.of<CartProvider>(context, listen: false);
        final items = cart.items
            .map(
              (item) => {
                'meal_id': int.parse(item.id),
                'quantity': item.quantity,
              },
            )
            .toList();

        await ApiService().createOrder(cart.totalAmount, items);

        // Clear the cart using the provider
        cart.clearCart();

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/confirmation');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order failed: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
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
              const Text(
                'Delivery Address',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 20, thickness: 1),

              // Dedicated Location Field
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _locationController,
                      label: 'Detected Location',
                      hint: 'Coordinates will appear here',
                      icon: Icons.my_location,
                      readOnly: true, // User cannot edit this manually
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: IconButton(
                      onPressed: _isLocationLoading
                          ? null
                          : _getCurrentLocation,
                      icon: _isLocationLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.gps_fixed),
                      tooltip: 'Get Current Location',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ],
              ),

              _buildTextFormField(
                controller: _addressController,
                label: 'Street Address',
                hint: '123 Main St',
                icon: Icons.location_on_outlined,
              ),
              _buildTextFormField(
                controller: _cityController,
                label: 'City',
                hint: 'New York',
                icon: Icons.apartment_outlined,
              ),
              _buildTextFormField(
                controller: _zipController,
                label: 'Postal Code',
                hint: '10001',
                icon: Icons.markunread_mailbox_outlined,
              ),
              const SizedBox(height: 30),

              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 20, thickness: 1),

              _buildPaymentTile('Credit Card', Icons.credit_card),
              _buildPaymentTile('PayPal', Icons.payment),
              _buildPaymentTile('Cash on Delivery', Icons.money),

              const SizedBox(height: 50),

              ElevatedButton(
                onPressed: _isLoading ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
          fillColor: readOnly ? Colors.grey[100] : null,
          filled: readOnly,
        ),
        validator: (value) {
          // If readOnly (Location field), it's optional effectively unless we enforce it
          // But strict form validation might annoy user if GPS fails
          if (!readOnly && (value == null || value.isEmpty)) {
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
