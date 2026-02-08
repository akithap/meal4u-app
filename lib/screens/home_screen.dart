import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/itemcard.dart';
import '../providers/meals_provider.dart';
import 'item_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MealsProvider>(context, listen: false).fetchMeals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: const AppDrawer(), // Removed drawer as we use BottomNav
      appBar: AppBar(
        title: const Text(
          'Meal4U',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<MealsProvider>(context, listen: false).fetchMeals();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              Stack(
                children: [
                  // Use a fixed placeholder or network image for hero
                  Image.network(
                    'https://images.unsplash.com/photo-1551024709-8f23befc6f87',
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
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

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top Picks',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'These are our favorite dishes',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 15),

                    // Meals List from Provider
                    SizedBox(
                      height: 240, // Adjusted height for new ItemCard
                      child: Consumer<MealsProvider>(
                        builder: (context, mealsProvider, child) {
                          if (mealsProvider.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (mealsProvider.error != null) {
                            return Center(
                              child: Text('Error: ${mealsProvider.error}'),
                            );
                          }

                          if (mealsProvider.meals.isEmpty) {
                            return const Center(child: Text('No meals found.'));
                          }

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: mealsProvider.meals.length,
                            itemBuilder: (context, index) {
                              final meal = mealsProvider.meals[index];
                              return ItemCard(
                                title: meal['title'],
                                category: meal['category'],
                                price: (meal['price'] as num).toDouble(),
                                imageUrl: meal['image_url'],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItemDetailScreen(
                                        item: {
                                          'id': meal['id'], // Pass the ID!
                                          'title':
                                              meal['title'] ?? 'Unknown Meal',
                                          'category':
                                              meal['category'] ?? 'General',
                                          'price':
                                              (meal['price'] as num?)
                                                  ?.toDouble() ??
                                              0.0,
                                          'image_url':
                                              meal['image_url'] ??
                                              '', // Use 'image_url' to match backend
                                          'description':
                                              meal['description'] ??
                                              'No description available.',
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Food types',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Replaced CategoryChip with simple chips or standard widget if CategoryChip is also removed
                    // Or I should keep CategoryChip or move it to widgets.
                    // For now, I'll just hardcode simple containers or restore CategoryChip if I deleted it.
                    // I will include CategoryChip class here locally or verify if I should move it.
                    // To keep it clean, I'll use standard Chips.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        Chip(label: Text('Italian')),
                        Chip(label: Text('Vegan')),
                        Chip(label: Text('Spicy')),
                        Chip(label: Text('Desserts')),
                      ],
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
