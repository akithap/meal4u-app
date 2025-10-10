import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'item_detail_screen.dart';
// Assuming PlaceholderImage and ItemCard are defined in a file named 'widgets.dart'
// or defined below if they are small. For this example, I'll define them here.

// *******************************************************************
// Helper Widgets (PlaceholderImage and ItemCard - Define these
// only if they were not in a separate 'widgets.dart' file)
// *******************************************************************

class PlaceholderImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BoxFit fit;

  const PlaceholderImage({
    super.key,
    required this.imageUrl,
    required this.height,
    required this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    // In a real app, use Image.network(imageUrl, ...) with a loading builder
    return Image.network(
      imageUrl,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          width: width,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: height,
          width: width,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(color: Colors.black),
          ),
        );
      },
    );
  }
}

class ItemCard extends StatelessWidget {
  final String title;
  final String category;
  final String imageUrl;
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: PlaceholderImage(
                imageUrl: imageUrl,
                height: 150,
                width: 150,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              category,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;

  const CategoryChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// *******************************************************************
// Main HomeScreen Widget
// *******************************************************************

// Define the sample data for all the items
final List<Map<String, dynamic>> topPicks = const [
  {
    'title': 'Chickpea Soup',
    'category': 'Vegan',
    'price': 6.00,
    'imageUrl': 'assets/images/soup.jpg',
    'description': 'A hearty, nutritious vegan chickpea soup.',
  },
  {
    'title': 'Tomato Pizza',
    'category': 'Cheap Eat',
    'price': 4.50,
    'imageUrl': 'assets/images/pizza.jpg',
    'description': 'Traditional Italian pizza with fresh tomatoes and basil.',
  },
  {
    'title': 'Pasta Carbonara',
    'category': 'Italian',
    'price': 8.75,
    'imageUrl': 'assets/images/pasta.jpg',
    'description': 'Classic creamy carbonara with guanciale and cheese.',
  },
  {
    'title': 'Sushi Set',
    'category': 'Japanese',
    'price': 15.00,
    'imageUrl': 'assets/images/sushi.jpg',
    'description': 'Chef\'s selection of fresh sushi and sashimi.',
  },
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),

      appBar: AppBar(
        title: const Text(
          'Meal4U',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,

        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Section (Image/Text) ---
            Stack(
              children: [
                // Background Image
                const PlaceholderImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1551024709-8f23befc6f87',
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Overlay Gradient and Text
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Text overlay
                Positioned(
                  bottom: 50,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'You hungry?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "We'll give you the best food.",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // --- Top Picks Section ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top Picks',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'These are our favorite dishes',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 15),

                  // Horizontal list of Item Cards (FIXED NAVIGATION HERE)
                  SizedBox(
                    height: 230,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: topPicks.length,
                      itemBuilder: (context, index) {
                        final item = topPicks[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: ItemCard(
                            title: item['title'] as String,
                            category: item['category'] as String,
                            imageUrl: item['imageUrl'] as String,
                            onTap: () {
                              // CORRECT: Navigate and pass the item object
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ItemDetailScreen(item: item),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // --- Food Types Section ---
                  const SizedBox(height: 20),
                  const Text(
                    'Food types',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  // Placeholder for Food Types Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      CategoryChip(label: 'Italian'),
                      CategoryChip(label: 'Vegan'),
                      CategoryChip(label: 'Spicy'),
                      CategoryChip(label: 'Desserts'),
                    ],
                  ),
                  const SizedBox(height: 50), // End padding
                ],
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button for Cart
      // floatingActionButton: FloatingActionButton(
      // onPressed: () => Navigator.pushNamed(context, '/cart'),
      // backgroundColor: Colors.black,
      //child: const Icon(Icons.shopping_cart, color: Colors.white),
      //),
    );
  }
}
