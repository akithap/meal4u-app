import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // Helper method to build consistent ListTile items
  Widget _buildListTile(
    BuildContext context,
    String title,
    IconData icon,
    String routeName,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.black, size: 24),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        // Close the drawer before navigating
        Navigator.pop(context);
        Navigator.pushNamed(context, routeName);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access the ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Header
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.white),
            child: Text(
              'Meal4U Menu',
              style: TextStyle(
                color: Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // --- Cart Page ---
          _buildListTile(
            context,
            'My Cart',
            Icons.shopping_cart_outlined,
            '/cart',
          ),

          // Profile
          _buildListTile(
            context,
            'My Profile',
            Icons.person_outline,
            '/profile',
          ),

          // Order History
          _buildListTile(
            context,
            'Order History',
            Icons.history,
            '/orderHistory',
          ),

          const Divider(),

          // Dark Mode Toggle
          SwitchListTile(
            title: const Text(
              'Dark Mode',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            secondary: const Icon(Icons.brightness_6, color: Colors.black),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) => themeProvider.toggleTheme(value),
          ),
        ],
      ),
    );
  }
}
