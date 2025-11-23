import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'product_list.dart';
import 'cart_page.dart';
import 'wishlist_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // The list of pages for the bottom nav
  final List<Widget> _pages = [
    ProductListScreen(), // Index 0
    WishlistPage(),      // Index 1
    CartPage(),          // Index 2
    ProfilePage(),       // Index 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[900] : Colors.white;
    final selectedColor = Colors.indigo;
    final unselectedColor = Colors.grey;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: bgColor,
          selectedItemColor: selectedColor,
          unselectedItemColor: unselectedColor,
          showUnselectedLabels: true,
          elevation: 0,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite), label: 'Wishlist'),
            BottomNavigationBarItem(
              icon: Consumer<CartProvider>(
                builder: (_, cart, __) => Stack(
                  children: [
                    Icon(Icons.shopping_bag_outlined),
                    if (cart.totalItems > 0)
                      Positioned(
                        right: 0, top: 0,
                        child: Container(
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                          constraints: BoxConstraints(minWidth: 12, minHeight: 12),
                          child: Text('${cart.totalItems}', style: TextStyle(color: Colors.white, fontSize: 8), textAlign: TextAlign.center),
                        ),
                      )
                  ],
                ),
              ),
              label: 'Cart',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}