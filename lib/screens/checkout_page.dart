import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../models/address.dart';
import '../services/api_service.dart';
import '../services/razorpay_service.dart';
import '../services/firestore_service.dart';
import '../services/invoice_service.dart';
import 'scratch_card_screen.dart';
import 'address_list_page.dart';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late RazorpayService _razorpayService;
  Address? _selectedAddress;
  int _selectedPaymentMethod = 0; // 0: Online, 1: COD
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize Payment Gateway
    _razorpayService = RazorpayService(
      api: ApiService(baseUrl: kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000'),
      onSuccess: (pid) => _handleOrderSuccess(pid, "Online"),
      onFailure: (err) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
      },
    );
  }

  // 🧹 CRITICAL FIX: Dispose Razorpay to prevent memory leaks
  @override
  void dispose() {
    _razorpayService.dispose(); // Ensure your RazorpayService has a dispose/clear method
    super.dispose();
  }

  Future<void> _handleOrderSuccess(String paymentId, String method) async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    if (user == null) return;

    setState(() => _isLoading = true);
    
    try {
      await FirestoreService().saveOrder(
        userId: user.uid,
        total: cart.totalPrice,
        items: cart.items,
        paymentId: paymentId,
        shippingAddress: _selectedAddress.toString(),
      );

      // Cache items for Invoice before clearing cart
      final tempItems = [...cart.items];
      final tempTotal = cart.totalPrice;

      cart.clear();
      
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      // Close Checkout Page first
      Navigator.pop(context); 
      
      // Show Rewards Dialog on the previous screen (Home/Cart)
      // We use a slight delay to ensure the context is valid after the pop
      Future.delayed(Duration(milliseconds: 300), () {
        showDialog(context: context, builder: (_) => ScratchCardDialog());
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 10), Text("Order Placed!")]),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: "INVOICE", 
              textColor: Colors.white,
              onPressed: () => InvoiceService.generateInvoice(tempItems, tempTotal),
            ),
          )
        );
      });

    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order failed: $e")));
    }
  }

  void _processPayment() {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("⚠️ Please select a delivery address"), backgroundColor: Colors.orange));
      return;
    }

    // Lock UI
    setState(() => _isLoading = true);

    final cart = Provider.of<CartProvider>(context, listen: false);
    // Free delivery threshold check
    double deliveryCharge = cart.subtotal > 200 ? 0.0 : 40.0;
    final totalAmount = cart.totalPrice + deliveryCharge;

    if (_selectedPaymentMethod == 1) {
      // COD
      _handleOrderSuccess("COD_${DateTime.now().millisecondsSinceEpoch}", "Cash on Delivery");
    } else {
      // Online
      _razorpayService.startPayment((totalAmount * 100).toInt());
      // Unlock UI if user cancels (this logic depends on Razorpay callback, usually handled in onFailure)
      setState(() => _isLoading = false); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final subtotal = cart.subtotal;
    final discount = cart.discount;
    final deliveryCharge = subtotal > 200 ? 0.0 : 40.0;
    final total = cart.totalPrice + deliveryCharge;

    // 🌙 DARK MODE VARIABLES
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final mutedText = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cardColor,
        iconTheme: IconThemeData(color: textColor),
        title: Text("Checkout", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      
      // --- FIXED BOTTOM BAR ---
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Amount", style: TextStyle(color: mutedText, fontSize: 16)),
                  Text("\$${total.toStringAsFixed(2)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                ],
              ),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  onPressed: _isLoading ? null : _processPayment,
                  child: _isLoading 
                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text("Place Order", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. ADDRESS SECTION ---
            _buildSectionTitle("Shipping Address", textColor),
            SizedBox(height: 10),
            InkWell(
              onTap: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddressListPage(isSelectionMode: true)));
                if (result != null) setState(() => _selectedAddress = result);
              },
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _selectedAddress != null ? Colors.indigo : Colors.grey.shade300, width: _selectedAddress != null ? 1.5 : 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(Icons.location_on, color: Colors.indigo),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: _selectedAddress == null
                          ? Text("Select Delivery Address", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_selectedAddress!.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                                SizedBox(height: 5),
                                Text(_selectedAddress!.fullAddress, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: mutedText, fontSize: 13)), // Uses the getter we added to Address
                              ],
                            ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // --- 2. PAYMENT METHODS ---
            _buildSectionTitle("Payment Method", textColor),
            SizedBox(height: 15),
            _buildPaymentCard(0, "Online Payment", Icons.credit_card, "Razorpay, UPI, Cards", cardColor, textColor, mutedText),
            SizedBox(height: 10),
            _buildPaymentCard(1, "Cash on Delivery", Icons.money, "Pay at your doorstep", cardColor, textColor, mutedText),

            SizedBox(height: 30),

            // --- 3. ORDER SUMMARY ---
            _buildSectionTitle("Order Summary", textColor),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _row("Subtotal", "\$${subtotal.toStringAsFixed(2)}", textColor, mutedText),
                  if (discount > 0) _row("Discount", "-\$${discount.toStringAsFixed(2)}", Colors.green, mutedText),
                  _row("Delivery Fee", deliveryCharge == 0 ? "FREE" : "\$${deliveryCharge.toStringAsFixed(2)}", deliveryCharge == 0 ? Colors.green : textColor, mutedText),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(thickness: 1, color: Colors.grey.withOpacity(0.3)), 
                  ),
                  
                  _row("Total", "\$${total.toStringAsFixed(2)}", textColor, mutedText, isBold: true, size: 18),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                  SizedBox(width: 5),
                  Text("Payments are 100% Secure", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            SizedBox(height: 20), 
          ],
        ),
      ),
    );
  }

  // ✨ HELPER: Payment Selection Card
  Widget _buildPaymentCard(int value, String title, IconData icon, String subtitle, Color cardColor, Color textColor, Color mutedText) {
    bool isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo.withOpacity(0.1) : cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.indigo : Colors.grey.shade300, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.indigo : Colors.grey, size: 28),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelected ? Colors.indigo : textColor)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: mutedText)),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: Colors.indigo),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color));
  }

  Widget _row(String label, String val, Color valColor, Color labelColor, {bool isBold = false, double size = 14.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: size, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: labelColor)),
          Text(val, style: TextStyle(fontSize: size, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: valColor)),
        ],
      ),
    );
  }
}