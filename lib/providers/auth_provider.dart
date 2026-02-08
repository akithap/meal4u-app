import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _token;
  final ApiService _apiService = ApiService();

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _token;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.login(email, password);
      _token = data['access_token'];
      _isAuthenticated = true;
    } catch (e) {
      _isAuthenticated = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.register(email, password, fullName);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuth() async {
    _isLoading = true;
    // notifyListeners(); // Avoid rebuilding on splash

    final token = await _apiService.getToken();
    if (token != null) {
      _token = token;
      _isAuthenticated = true;
    } else {
      _isAuthenticated = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _apiService.logout();
    _token = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
