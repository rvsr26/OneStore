import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 📦 Ensure intl is in pubspec.yaml
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import 'order_tracking_page.dart';

class OrderHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 🛡️ Safe User Access
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // 🌙 DARK MODE VARIABLES
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final mutedText = isDark ? Colors.grey[400] : Colors.grey[600];

    if (user == null) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text("My Orders", style: TextStyle(color: textColor)),
          backgroundColor: cardColor,
          elevation: 0,
          iconTheme: IconThemeData(color: textColor),
        ),
        body: Center(child: Text("Please login to view orders", style: TextStyle(color: mutedText))),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("My Orders", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getUserOrders(user.uid),
        builder: (context, snapshot) {
          // 1. Handle Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // 2. Handle Errors
          if (snapshot.hasError) {
            return Center(child: Text("Error loading orders", style: TextStyle(color: Colors.red)));
          }

          // 3. Handle Empty Data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No orders found", style: TextStyle(color: mutedText, fontSize: 16)),
                ],
              ),
            );
          }

          // 4. Sort Data Locally (Newest First)
          // 🛡️ CRASH FIX: Create a modifiable copy using List.from()
          // Firestore lists are often read-only, sorting them directly causes a crash.
          final docs = List<QueryDocumentSnapshot>.from(snapshot.data!.docs);
          
          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime = (aData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            final bTime = (bData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            return bTime.compareTo(aTime); // Descending order
          });

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final date = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
              final items = (data['items'] as List<dynamic>?) ?? [];
              final status = data['status'] ?? 'Paid';
              final orderId = docs[i].id.substring(0, 5).toUpperCase();

              // Status Color Logic
              Color statusColor;
              if (status == 'Delivered') statusColor = Colors.green;
              else if (status == 'Cancelled') statusColor = Colors.red;
              else statusColor = Colors.orange;

              return Card(
                color: cardColor,
                elevation: 2,
                margin: EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  iconColor: textColor,
                  collapsedIconColor: textColor,
                  title: Text(
                    "Order #$orderId",
                    style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMM dd, yyyy • hh:mm a').format(date),
                        style: TextStyle(color: mutedText, fontSize: 12),
                      ),
                      SizedBox(height: 5),
                      // Track Order Button
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderTrackingPage(status: status, orderId: "#$orderId"),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Track Order", style: TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.bold)),
                              SizedBox(width: 5),
                              Icon(Icons.arrow_forward, size: 14, color: Colors.indigoAccent)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      status, 
                      style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)
                    ),
                  ),
                  children: items.map<Widget>((item) {
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      title: Text(item['title'] ?? 'Unknown Product', style: TextStyle(color: textColor)),
                      trailing: Text(
                        "${item['quantity']} x \$${item['price']}", 
                        style: TextStyle(color: mutedText, fontWeight: FontWeight.bold)
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}