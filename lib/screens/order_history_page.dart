import 'package:flutter/material.dart';

class PastOrder {
  final String id;
  final String date;
  final double total;
  final String itemsSummary;

  const PastOrder({
    required this.id,
    required this.date,
    required this.total,
    required this.itemsSummary,
  });
}

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  static final List<PastOrder> pastOrders = const [
    PastOrder(
      id: '#M4U1001',
      date: 'Oct 05, 2025',
      total: 25.70,
      itemsSummary: 'Pizza (M), Carbonara',
    ),
    PastOrder(
      id: '#M4U1000',
      date: 'Sep 28, 2025',
      total: 12.50,
      itemsSummary: 'Chickpea Soup (L)',
    ),
    PastOrder(
      id: '#M4U0999',
      date: 'Sep 21, 2025',
      total: 45.99,
      itemsSummary: 'Sushi Set, Tempura, Cola',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15.0),
        itemCount: pastOrders.length,
        itemBuilder: (context, index) {
          final order = pastOrders[index];
          return OrderCard(order: order);
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final PastOrder order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
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
                  'Order ID: ${order.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(order.date, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Divider(height: 15),

            Text(
              'Items: ${order.itemsSummary}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: \$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.deepOrange,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reordering ${order.itemsSummary}...'),
                      ),
                    );
                    Navigator.pushNamed(context, '/cart');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Reorder',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
