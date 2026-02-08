import 'package:flutter/material.dart';

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
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: height,
            width: width,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imageUrl,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey, size: 30),
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final String title;
  final String category;
  final String imageUrl;
  final double price;
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: PlaceholderImage(
                imageUrl: imageUrl,
                height: 120,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
