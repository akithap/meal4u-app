import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MealsProvider with ChangeNotifier {
  List<dynamic> _meals = [];
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService = ApiService();

  List<dynamic> get meals => _meals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMeals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _meals = await _apiService.getMeals();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
