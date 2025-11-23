import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/address.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import 'add_address_page.dart';

class AddressListPage extends StatelessWidget {
  final bool isSelectionMode; 
  
  AddressListPage({this.isSelectionMode = false});

  @override
  Widget build(BuildContext context) {
    // 🛡️ Safety: Ensure user is logged in
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(body: Center(child: Text("Please log in to view addresses")));
    }

    final firestoreService = FirestoreService();

    // 🌙 DARK MODE VARIABLES
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedText = isDark ? Colors.grey[400] : Colors.grey[700];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          isSelectionMode ? "Select Address" : "My Addresses",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      
      // ✨ Extended Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddAddressPage())),
        backgroundColor: Colors.indigo,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text("Add New Address", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      
      body: StreamBuilder<List<Address>>(
        stream: firestoreService.getUserAddresses(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
             return Center(child: Text("Error loading addresses", style: TextStyle(color: Colors.red)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(context, textColor, mutedText);
          }

          final addresses = snapshot.data!;

          return ListView.separated(
            padding: EdgeInsets.all(20),
            physics: BouncingScrollPhysics(), // Better feel
            itemCount: addresses.length,
            separatorBuilder: (ctx, i) => SizedBox(height: 15),
            itemBuilder: (ctx, i) {
              final address = addresses[i];
              return _buildAddressCard(context, address, firestoreService, user.uid, isDark, cardColor, textColor, mutedText);
            },
          );
        },
      ),
    );
  }

  // 🎨 WIDGET: Single Address Card
  Widget _buildAddressCard(
    BuildContext context, 
    Address address, 
    FirestoreService db, 
    String uid, 
    bool isDark, 
    Color cardColor, 
    Color textColor, 
    Color? mutedText
  ) {
    // 🟢 IMPROVEMENT: Material widget ensures InkWell ripple is visible
    return Material(
      color: cardColor,
      elevation: 2,
      borderRadius: BorderRadius.circular(15),
      shadowColor: Colors.black.withOpacity(0.05),
      child: InkWell(
        onTap: () {
          if (isSelectionMode) {
            Navigator.pop(context, address); // Return selected address
          }
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: isSelectionMode 
                ? Border.all(color: Colors.indigo.withOpacity(0.5), width: 1.5) 
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.location_on_outlined, color: isDark ? Colors.indigoAccent : Colors.indigo, size: 24),
              ),
              SizedBox(width: 15),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          address.name, 
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)
                        ),
                        if (!isSelectionMode)
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            constraints: BoxConstraints(), 
                            padding: EdgeInsets.zero,
                            onPressed: () => _confirmDelete(context, db, uid, address.id, isDark),
                          ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      "${address.street}, ${address.city}",
                      style: TextStyle(color: mutedText, fontSize: 14, height: 1.4),
                    ),
                    Text(
                      "${address.state} - ${address.zip}",
                      style: TextStyle(color: mutedText, fontSize: 14, height: 1.4),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: mutedText),
                        SizedBox(width: 5),
                        Text(address.phone, style: TextStyle(color: mutedText, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Selection Indicator (Only if in selection mode)
              if (isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
                  child: Icon(Icons.check_circle, size: 20, color: Colors.indigo),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 🗑️ HELPER: Delete Confirmation Dialog
  void _confirmDelete(BuildContext context, FirestoreService db, String uid, String addressId, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        title: Text("Delete Address?", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text("Are you sure you want to remove this address?", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[800])),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              db.deleteAddress(uid, addressId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Address removed"), backgroundColor: Colors.redAccent)
              );
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 🖼️ HELPER: Empty State UI
  Widget _buildEmptyState(BuildContext context, Color textColor, Color? mutedText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 120, width: 120,
            decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.map_outlined, size: 60, color: Colors.indigo.withOpacity(0.5)),
          ),
          SizedBox(height: 20),
          Text("No Addresses Found", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          SizedBox(height: 10),
          Text("Save your delivery locations here.", style: TextStyle(color: mutedText)),
        ],
      ),
    );
  }
}