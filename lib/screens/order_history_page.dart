import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  late Future<List<dynamic>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = ApiService().getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            final error = snapshot.error.toString();
            if (error.contains('Could not validate credentials') ||
                error.contains('401')) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Session Expired. Please log in again.'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Ideally we should use AuthProvider.logout() but for now just push to login
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      child: const Text('Log In'),
                    ),
                  ],
                ),
              );
            }
            return Center(child: Text('Error: $error'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No past orders found.'));
          }

          // Show newest orders first
          final orders = snapshot.data!.reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(15.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(order: order);
            },
          );
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final items = order['items'] as List<dynamic>;
    final itemsSummary = items
        .map((item) => '${item['meal_title']} (x${item['quantity']})')
        .join(', ');
    final total = (order['total_amount'] as num).toDouble();
    final date = order['created_at'].toString().split(
      'T',
    )[0]; // Simple date formatting

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ID: #${order['id']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(date, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Divider(height: 15),

            Text('items: $itemsSummary', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: \$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.deepOrange,
                  ),
                ),
                // Removed Reorder button for now as it requires more complex logic to add back to cart properly
              ],
            ),
          ],
        ),
      ),
    );
  }
}
