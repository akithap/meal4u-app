import 'package:flutter/material.dart';

// --- Placeholder for Network Image ---
// Since you don't have an assets folder, we'll use a NetworkImage
// or a simple placeholder color container for the images.
class PlaceholderImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BoxFit fit;

  const PlaceholderImage({
    super.key,
    required this.imageUrl,
    this.height = 100,
    this.width = 100,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    // Using an Image.network with a fallback error builder
    // The image URLs used in the examples are placeholders.
    return Image.asset(
      imageUrl,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Fallback: Use a colored container with a generic icon
        return Container(
          height: height,
          width: width,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.fastfood, color: Colors.grey, size: 40),
          ),
        );
      },
    );
  }
}

// --- ItemCard Widget (for homescreen Top Picks) ---
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
            // Image Area
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: PlaceholderImage(
                imageUrl: imageUrl,
                height: 150,
                width: 150,
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            // Category/Tag
            Text(
              category,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
