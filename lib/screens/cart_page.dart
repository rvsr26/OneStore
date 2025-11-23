import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart'; // 📦 Ensure this is in pubspec.yaml
import '../providers/cart_provider.dart';
import '../models/product.dart'; // Needed for undo logic
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _couponCtrl = TextEditingController();

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    
    // 🌙 DARK MODE VARIABLES
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final mutedText = isDark ? Colors.grey[400] : Colors.grey[600];
    final iconColor = isDark ? Colors.white : Colors.black;
    
    // 🚚 Free Delivery Logic
    double freeDeliveryThreshold = 200.00;
    double deliveryFee = 40.0;
    double currentTotal = cart.subtotal; 
    double progress = (currentTotal / freeDeliveryThreshold).clamp(0.0, 1.0);
    double remaining = freeDeliveryThreshold - currentTotal;
    bool isFreeDelivery = remaining <= 0;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Column(
          children: [
            Text("My Cart", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            Text("${cart.totalItems} items", style: TextStyle(color: mutedText, fontSize: 12)),
          ],
        ),
        centerTitle: true,
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: iconColor),
      ),
      
      // --- EMPTY STATE HANDLING ---
      body: cart.items.isEmpty
          ? _buildEmptyState(context, isDark, textColor, mutedText)
          : Column(
              children: [
                // 1. FREE DELIVERY PROGRESS BAR
                Container(
                  padding: EdgeInsets.all(16),
                  color: cardColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(isFreeDelivery ? Icons.check_circle : Icons.local_shipping_outlined, 
                               color: isFreeDelivery ? Colors.green : Colors.indigo),
                          SizedBox(width: 10),
                          Text(
                            isFreeDelivery 
                              ? "🎉 You've unlocked Free Delivery!" 
                              : "Add \$${remaining.toStringAsFixed(2)} for Free Delivery",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(isFreeDelivery ? Colors.green : Colors.indigo),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 2. CART ITEMS LIST
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    itemCount: cart.items.length,
                    separatorBuilder: (ctx, i) => SizedBox(height: 15),
                    itemBuilder: (ctx, i) {
                      final item = cart.items[i];
                      final key = "${item.product.id}_${item.selectedVariant}"; 
                      
                      return Dismissible(
                        key: Key(key), // Use Key() wrapper for strings
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(15)),
                          child: Icon(Icons.delete_outline, color: Colors.white, size: 30),
                        ),
                        onDismissed: (direction) {
                          // Cache data for undo
                          final deletedProduct = item.product;
                          final deletedVariant = item.selectedVariant;
                          final deletedQty = item.quantity;

                          // Remove
                          cart.removeAll(item.product.id, item.selectedVariant);
                          
                          // Undo SnackBar
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${deletedProduct.title} removed"),
                              action: SnackBarAction(
                                label: "UNDO",
                                textColor: Colors.amber,
                                onPressed: () {
                                  // Restore logic: Loop to add quantity back
                                  for(int k=0; k<deletedQty; k++) {
                                    cart.addProduct(deletedProduct, deletedVariant);
                                  }
                                },
                              ),
                            )
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          ),
                          child: Row(
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: item.product.imageUrl,
                                  height: 80, width: 80, fit: BoxFit.cover,
                                  placeholder: (c, u) => Container(color: isDark ? Colors.grey[800] : Colors.grey[200]),
                                  errorWidget: (c, u, e) => Icon(Icons.broken_image, color: mutedText),
                                ),
                              ),
                              SizedBox(width: 15),
                              
                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                                    SizedBox(height: 5),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.grey[800] : Colors.grey[100], 
                                        borderRadius: BorderRadius.circular(5)
                                      ),
                                      child: Text("Size: ${item.selectedVariant}", style: TextStyle(fontSize: 12, color: mutedText)),
                                    ),
                                    SizedBox(height: 8),
                                    Text("\$${item.product.price}", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.indigo)),
                                  ],
                                ),
                              ),
                              
                              // Quantity Controls
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    _qtyBtn(Icons.remove, () => cart.removeProduct(item.product.id, item.selectedVariant), isDark),
                                    Text("${item.quantity}", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                                    _qtyBtn(Icons.add, () => cart.addProduct(item.product, item.selectedVariant), isDark),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

      // --- 3. BOTTOM CHECKOUT SECTION ---
      bottomNavigationBar: cart.items.isEmpty ? null : Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Coupon Field
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: TextField(
                        controller: _couponCtrl,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: "Enter Coupon Code",
                          hintStyle: TextStyle(color: mutedText),
                          prefixIcon: Icon(Icons.local_offer_outlined, size: 20, color: mutedText),
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                          filled: true,
                          fillColor: isDark ? Colors.grey[800] : Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.indigo)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.grey[800] : Colors.black, 
                      fixedSize: Size(80, 45), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    onPressed: () {
                      if (_couponCtrl.text.isEmpty) return;
                      cart.applyCoupon(_couponCtrl.text);
                      
                      // Feedback
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(cart.discount > 0 ? "Coupon Applied!" : "Invalid Coupon Code"), 
                          backgroundColor: cart.discount > 0 ? Colors.green : Colors.red
                        )
                      );
                      if (cart.discount > 0) _couponCtrl.clear();
                    },
                    child: Text("Apply", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
              SizedBox(height: 20),
              
              // Pricing Breakdown
              _priceRow("Subtotal", cart.subtotal, textColor, mutedText),
              if (cart.discount > 0) _priceRow("Discount", -cart.discount, textColor, mutedText, isGreen: true),
              _priceRow("Delivery", isFreeDelivery ? 0 : deliveryFee, textColor, mutedText), 
              Divider(height: 20, color: isDark ? Colors.grey[700] : Colors.grey[300]),
              _priceRow("Total", cart.totalPrice + (isFreeDelivery ? 0 : deliveryFee), textColor, mutedText, isTotal: true),
              
              SizedBox(height: 20),

              // Checkout Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5
                  ),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutPage())),
                  child: Text("Proceed to Checkout", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✨ Helper: Quantity Button
  Widget _qtyBtn(IconData icon, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Icon(icon, size: 16, color: isDark ? Colors.indigoAccent : Colors.indigo),
      ),
    );
  }

  // ✨ Helper: Price Row
  Widget _priceRow(String label, double val, Color textColor, Color? mutedColor, {bool isGreen = false, bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: mutedColor)),
          Text(
            val == 0 && label == "Delivery" ? "FREE" : "\$${val.abs().toStringAsFixed(2)}", 
            style: TextStyle(
              fontSize: isTotal ? 18 : 14, 
              fontWeight: isTotal || isGreen ? FontWeight.bold : FontWeight.normal, 
              color: isGreen || (val == 0 && label == "Delivery") ? Colors.green : textColor
            )
          ),
        ],
      ),
    );
  }

  // ✨ Helper: Empty State
  Widget _buildEmptyState(BuildContext context, bool isDark, Color textColor, Color? mutedColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.indigo),
          ),
          SizedBox(height: 20),
          Text("Your Cart is Empty", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
          Text("Looks like you haven't added anything yet.", style: TextStyle(color: mutedColor)),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: StadiumBorder()),
            child: Text("Start Shopping", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}