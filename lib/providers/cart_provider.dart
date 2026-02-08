import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../services/database_helper.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => [..._items];

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  CartProvider() {
    _loadCartFromDB();
  }

  Future<void> _loadCartFromDB() async {
    try {
      _items = await DatabaseHelper().getItems();
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading cart from DB: $e");
    }
  }

  Future<void> addToCart(CartItem newItem) async {
    int index = _items.indexWhere(
      (item) => item.name == newItem.name && item.size == newItem.size,
    );

    if (index != -1) {
      _items[index].quantity += newItem.quantity;
      await DatabaseHelper().updateItem(_items[index]);
    } else {
      _items.add(newItem);
      await DatabaseHelper().insertItem(newItem);
    }
    notifyListeners();
  }

  Future<void> removeFromCart(CartItem item) async {
    _items.remove(item);
    await DatabaseHelper().deleteItem(item.id);
    notifyListeners();
  }

  Future<void> removeSingleItem(CartItem item) async {
    int index = _items.indexOf(item);
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
        await DatabaseHelper().updateItem(_items[index]);
      } else {
        _items.removeAt(index);
        await DatabaseHelper().deleteItem(item.id);
      }
      notifyListeners();
    }
  }

  Future<void> addSingleItem(CartItem item) async {
    int index = _items.indexOf(item);
    if (index != -1) {
      _items[index].quantity++;
      await DatabaseHelper().updateItem(_items[index]);
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _items.clear();
    await DatabaseHelper().clearCart();
    notifyListeners();
  }
}
