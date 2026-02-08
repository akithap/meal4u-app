import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/meals_provider.dart';
import '../providers/cart_provider.dart';

import '../widgets/auth_wrapper.dart';
import '../screens/cart_page.dart';
import '../screens/checkout_page.dart';
import '../screens/order_history_page.dart';
import '../screens/profile_page.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../services/light_sensor_service.dart'; // Import key service

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuth()),
        ChangeNotifierProvider(create: (_) => MealsProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Meal 4 U',
      scrollBehavior: AppScrollBehavior(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return SensorListener(child: child!);
      },
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepOrange,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepOrange,
        ),
      ),
      themeMode: themeProvider.themeMode,

      routes: {
        '/': (context) => const AuthWrapper(),
        '/cart': (context) => const CartPage(),
        '/checkout': (context) => const CheckoutPage(),
        '/confirmation': (context) => const ConfirmationPage(),
        '/orderHistory': (context) => const OrderHistoryPage(),
        '/profile': (context) => const ProfilePage(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}

class SensorListener extends StatefulWidget {
  final Widget child;
  const SensorListener({super.key, required this.child});

  @override
  State<SensorListener> createState() => _SensorListenerState();
}

class _SensorListenerState extends State<SensorListener> {
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _lightSubscription;
  final LightSensorService _lightSensorService = LightSensorService();
  DateTime _lastToggle = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initSensors();
  }

  void _initSensors() {
    // 1. Connectivity
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      if (results.contains(ConnectivityResult.none)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No Internet Connection'),
            backgroundColor: Colors.red,
            duration: Duration(days: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });

    // 2. Light Sensor (Mobile & Web via Service)
    try {
      _lightSubscription = _lightSensorService.luxStream.listen((lux) {
        if (DateTime.now().difference(_lastToggle).inSeconds > 2) {
          final themeProvider = Provider.of<ThemeProvider>(
            context,
            listen: false,
          );
          final isDark = lux < 10; // Dark mode if < 10 lux

          if (isDark && themeProvider.themeMode == ThemeMode.light) {
            themeProvider.toggleTheme(true);
            _lastToggle = DateTime.now();
            // Optional: Show snackbar for demo purposes (can remove for production)
            /*
                     ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Low light detected! Switched to Dark Mode'), duration: Duration(milliseconds: 1000)),
                     );
                     */
          } else if (!isDark && themeProvider.themeMode == ThemeMode.dark) {
            themeProvider.toggleTheme(false);
            _lastToggle = DateTime.now();
            /*
                     ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bright light detected! Switched to Light Mode'), duration: Duration(milliseconds: 1000)),
                     );
                     */
          }
        }
      });
    } catch (e) {
      debugPrint("Light Sensor Init Failed: $e");
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _lightSubscription?.cancel();
    _lightSensorService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Confirmed')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Your order has been placed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Thank you for shopping with Meal4U.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text(
                'Continue Shopping',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
