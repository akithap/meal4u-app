import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/home_screen.dart';
import '../screens/auth/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // if (auth.isLoading) {
        //   return const Scaffold(
        //     body: Center(child: CircularProgressIndicator()),
        //   );
        // }
        return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
