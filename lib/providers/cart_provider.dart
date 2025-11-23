import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // 📦 Add this to pubspec.yaml
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  double _discount = 0.0;
  String _appliedCoupon = "";

  // Getters
  int get itemCount => _items.length;
  List<CartItem> get items => _items.values.toList();
  
  // Total quantity (e.g., 2 shirts + 1 pant = 3 items)
  int get totalItems => _items.values.fold(0, (s, i) => s + i.quantity);
  
  double get subtotal => _items.values.fold(0.0, (s, i) => s + i.total);
  
  double get discount => _discount;
  
  double get totalPrice {
    double total = subtotal - _discount;
    return total < 0 ? 0 : total;
  }

  // 🛡️ CRASH FIX: Smart Notify
  // Only notifies if the discount logic actually changes something.
  // Prevents infinite loops if called during build.
  void applyCoupon(String code) {
    double oldDiscount = _discount;
    
    if (code.toUpperCase() == "SAVE20") {
      _discount = subtotal * 0.20;
      _appliedCoupon = code;
    } else if (code.toUpperCase() == "FLAT50") {
      _discount = 50.0;
      _appliedCoupon = code;
    } else {
      _discount = 0.0;
      _appliedCoupon = "";
    }

    // Only redraw if the value actually changed
    if (oldDiscount != _discount) {
      notifyListeners();
    }
  }

  // FEATURE: Stock Validation
  void addProduct(Product p, [String variant = 'Default']) {
    final key = p.id + variant;
    
    if (_items.containsKey(key)) {
      // Check stock before incrementing
      if (_items[key]!.quantity + 1 <= p.stock) {
        _items[key]!.increment(); // Using the method we added to CartItem
      } else {
        // Optional: You could add a way to show a "Out of Stock" toast here
        print("Cannot add more: Out of Stock");
        return; 
      }
    } else {
      if (p.stock > 0) {
        _items[key] = CartItem(product: p, selectedVariant: variant);
      } else {
        print("Item is Out of Stock");
        return;
      }
    }
    
    // Re-calculate discount if total changed
    applyCoupon(_appliedCoupon); 
    notifyListeners();
    saveCart(); // Auto-save
  }
  
  void removeProduct(String pid, String variant) {
    final key = pid + variant;
    if (!_items.containsKey(key)) return;
    
    if (_items[key]!.quantity > 1) {
      _items[key]!.decrement();
    } else {
      _items.remove(key);
    }
    applyCoupon(_appliedCoupon);
    notifyListeners();
    saveCart(); // Auto-save
  }

  void removeAll(String pid, String variant) {
    _items.remove(pid + variant);
    applyCoupon(_appliedCoupon);
    notifyListeners();
    saveCart(); // Auto-save
  }
  
  void clear() {
    _items.clear();
    _discount = 0;
    _appliedCoupon = "";
    notifyListeners();
    saveCart(); // Auto-save
  }

  // 💾 FEATURE: Persistence (Requires shared_preferences)
  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert logic: List<CartItem> -> List<Map> -> JSON String
    final String encodedData = json.encode(
      _items.map((key, item) => MapEntry(key, item.toMap()))
    );
    await prefs.setString('user_cart', encodedData);
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('user_cart')) return;

    final String extractedData = prefs.getString('user_cart') ?? '{}';
    final Map<String, dynamic> decodedData = json.decode(extractedData);

    _items.clear();
    decodedData.forEach((key, value) {
      _items[key] = CartItem.fromMap(value);
    });
    notifyListeners();
  }
}