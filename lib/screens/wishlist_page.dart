import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart'; 
import 'product_detail.dart';
import 'main_screen.dart'; // 🟢 Changed navigation target to keep Bottom Bar

class WishlistPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).user; 
    final favorites = productProvider.favorites;

    // 🌙 DARK MODE VARIABLES
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final mutedText = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("My Wishlist", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          if (favorites.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
              tooltip: "Clear Wishlist",
              onPressed: () => _confirmClearWishlist(context, productProvider, user?.uid),
            )
        ],
      ),
      body: favorites.isEmpty
          ? _buildEmptyState(context, textColor, mutedText)
          : GridView.builder(
              padding: EdgeInsets.all(16),
              physics: BouncingScrollPhysics(), // Better scrolling feel
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65, 
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: favorites.length,
              itemBuilder: (ctx, i) {
                final product = favorites[i];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- IMAGE & DELETE BUTTON ---
                        Expanded(
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                                child: CachedNetworkImage(
                                  imageUrl: product.imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (c, u) => Container(color: isDark ? Colors.grey[800] : Colors.grey[100]),
                                  errorWidget: (c, u, e) => Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              ),
                              Positioned(
                                top: 8, right: 8,
                                child: InkWell(
                                  onTap: () => productProvider.toggleFavorite(product.id, user?.uid),
                                  child: Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: isDark ? Colors.black54 : Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                                    child: Icon(Icons.close, size: 18, color: isDark ? Colors.white : Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // --- DETAILS & ACTIONS ---
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title, 
                                maxLines: 1, 
                                overflow: TextOverflow.ellipsis, 
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)
                              ),
                              SizedBox(height: 5),
                              Text(
                                "\$${product.price}", 
                                style: TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.w900, fontSize: 16)
                              ),
                              SizedBox(height: 10),
                              
                              // Move to Cart Button
                              SizedBox(
                                width: double.infinity,
                                height: 35,
                                child: OutlinedButton.icon(
                                  icon: Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.indigoAccent),
                                  label: Text("Move to Cart", style: TextStyle(fontSize: 12, color: Colors.indigoAccent)),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.indigoAccent),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    // 1. Add to Cart
                                    String variant = "Default";
                                    if (product.variants.isNotEmpty) {
                                       variant = product.variants.values.first.first; 
                                    }
                                    cartProvider.addProduct(product, variant);
                                    
                                    // 2. Remove from Wishlist
                                    productProvider.toggleFavorite(product.id, user?.uid);
                                    
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Moved to Cart"), backgroundColor: Colors.green, duration: Duration(seconds: 1))
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // 🗑️ Helper: Clear Confirmation
  void _confirmClearWishlist(BuildContext context, ProductProvider provider, String? uid) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Clear Wishlist?"),
        content: Text("Are you sure you want to remove all items?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              // Loop through a COPY of the list to avoid modification errors during iteration
              final itemsToRemove = List.from(provider.favorites);
              for (var p in itemsToRemove) {
                 provider.toggleFavorite(p.id, uid);
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Wishlist Cleared")));
            }, 
            child: Text("Clear All", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  // 🎨 HELPER: Empty State
  Widget _buildEmptyState(BuildContext context, Color textColor, Color? mutedText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.favorite_border, size: 60, color: Colors.redAccent),
          ),
          SizedBox(height: 20),
          Text("Your Wishlist is Empty", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
          Text("Save items you want to buy later!", style: TextStyle(color: mutedText)),
          SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: StadiumBorder()
            ),
            // 🟢 FIX: Navigate to MainScreen to keep the bottom bar context
            onPressed: () => Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (_) => MainScreen()), 
              (r) => false
            ),
            child: Text("Start Shopping", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}