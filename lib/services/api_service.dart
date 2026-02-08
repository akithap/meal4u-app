import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter/foundation.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000'; // or http://127.0.0.1:8000
    }
    // Note: 'dart.io' Platform check is not available on web, so we check kIsWeb first.
    return 'http://10.0.2.2:8000';
  }

  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': email, // OAuth2 expects 'username'
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _storage.write(key: 'jwt_token', value: data['access_token']);
      return data;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String fullName,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'full_name': fullName,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<List<dynamic>> getMeals() async {
    final response = await http.get(Uri.parse('$baseUrl/meals'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load meals');
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<void> createOrder(
    double totalAmount,
    List<Map<String, dynamic>> items,
  ) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'total_amount': totalAmount, 'items': items}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create order: ${response.body}');
    }
  }

  Future<List<dynamic>> getOrders() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load orders: ${response.body}');
    }
  }
}
