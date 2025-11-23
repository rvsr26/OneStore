import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 📦 Add this to pubspec.yaml

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en'); // Default to English

  Locale get locale => _locale;

  // IMPROVEMENT: Structured Translation Map
  final Map<String, Map<String, String>> _vals = {
    'en': {
      'discover': 'Discover',
      'search': 'Search...',
      'cart': 'My Cart',
      'profile': 'My Profile',
      'wishlist': 'Wishlist',
      'settings': 'Settings', // Added common keys
      'language': 'Language',
    },
    'hi': {
      'discover': 'खोजें',
      'search': 'खोजें...',
      'cart': 'मेरी टोकरी',
      'profile': 'प्रोफ़ाइल',
      'wishlist': 'इच्छा सूची',
      'settings': 'सेटिंग्स',
      'language': 'भाषा',
    }
  };

  LanguageProvider() {
    loadLocale(); // 🟢 Auto-load saved language on startup
  }

  // FEATURE: Persistence (Save Language)
  Future<void> changeLanguage(String code) async {
    if (_vals.containsKey(code)) {
      _locale = Locale(code);
      notifyListeners();
      
      // Save to storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_lang', code);
    }
  }

  // FEATURE: Persistence (Load Language)
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedCode = prefs.getString('app_lang');
    
    if (savedCode != null && _vals.containsKey(savedCode)) {
      _locale = Locale(savedCode);
      notifyListeners();
    }
  }

  // IMPROVEMENT: Smart Fallback
  // If translation is missing in Hindi, show English instead of the raw Key.
  String getText(String key) {
    // 1. Try specific language (e.g., Hindi)
    String? text = _vals[_locale.languageCode]?[key];
    
    // 2. Fallback to English if Hindi translation is missing
    if (text == null) {
      text = _vals['en']?[key];
    }
    
    // 3. Fallback to the raw key if everything fails
    return text ?? key;
  }
}