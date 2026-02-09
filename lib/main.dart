import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/meals_provider.dart';
import '../providers/cart_provider.dart';

import '../widgets/auth_wrapper.dart';
import '../screens/cart_page.dart';
import '../screens/checkout_page.dart';
import '../screens/confirmation_page.dart';
import '../screens/order_history_page.dart';
import '../screens/profile_page.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../widgets/sensor_listener.dart';

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
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepOrange,
        textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
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
