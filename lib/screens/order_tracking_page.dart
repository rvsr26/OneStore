import 'package:flutter/material.dart';
import 'chatbot_screen.dart'; // 🔗 Link to the AI Chatbot we fixed earlier

class OrderTrackingPage extends StatelessWidget {
  final String status; // e.g., "Placed", "Packed", "Shipped", "Delivered"
  final String orderId; 

  OrderTrackingPage({
    required this.status, 
    this.orderId = "#OD-429384" 
  });

  @override
  Widget build(BuildContext context) {
    // 1. Define the Order Steps
    final List<Map<String, dynamic>> steps = [
      {'status': 'Placed', 'title': 'Order Placed', 'desc': 'We have received your order', 'time': '9:00 AM', 'icon': Icons.assignment_turned_in_outlined},
      {'status': 'Packed', 'title': 'Order Packed', 'desc': 'Seller has packed your package', 'time': '11:30 AM', 'icon': Icons.inventory_2_outlined},
      {'status': 'Shipped', 'title': 'Shipped', 'desc': 'Your package is on the way', 'time': '2:00 PM', 'icon': Icons.local_shipping_outlined},
      {'status': 'Delivered', 'title': 'Delivered', 'desc': 'Package delivered to you', 'time': 'Expected 5:00 PM', 'icon': Icons.home_work_outlined},
    ];

    // 2. Calculate Current Step Index (Case Insensitive Safety)
    int currentStep = steps.indexWhere((e) => e['status'].toString().toLowerCase() == status.toLowerCase());
    if (currentStep == -1) currentStep = 0; 

    // 🌙 DARK MODE VARIABLES
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final mutedText = isDark ? Colors.grey[400] : Colors.grey[600];
    final lineColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Track Order", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ORDER SUMMARY CARD ---
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: Icon(Icons.local_shipping, color: Colors.white, size: 28),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Order $orderId", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(status == 'Delivered' ? "Arrived" : "Arriving Soon", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30),
            Text("Timeline", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            SizedBox(height: 20),

            // --- TIMELINE LIST ---
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                bool isCompleted = index <= currentStep;
                bool isLast = index == steps.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Timeline Line & Dot
                    Column(
                      children: [
                        Container(
                          width: 30,
                          child: Column(
                            children: [
                              // The Icon/Dot
                              Container(
                                height: 40, width: 40,
                                decoration: BoxDecoration(
                                  color: isCompleted ? Colors.green : cardColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: isCompleted ? Colors.green : lineColor, width: 2),
                                ),
                                child: Icon(
                                  isCompleted ? Icons.check : step['icon'], 
                                  color: isCompleted ? Colors.white : Colors.grey,
                                  size: 20,
                                ),
                              ),
                              // The Vertical Line
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 60, 
                                  color: index < currentStep ? Colors.green : lineColor,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 15),
                    
                    // 2. Text Content
                    Expanded(
                      child: Container(
                        constraints: BoxConstraints(minHeight: 80), 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  step['title'], 
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 16,
                                    color: isCompleted ? textColor : Colors.grey
                                  )
                                ),
                                Text(
                                  step['time'], 
                                  style: TextStyle(fontSize: 12, color: mutedText)
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text(
                              step['desc'], 
                              style: TextStyle(color: mutedText, fontSize: 13)
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: 20),

            // --- BOTTOM ACTIONS ---
            if (status != "Delivered" && status != "Cancelled")
            Row(
              children: [
                // SUPPORT BUTTON -> Connects to Chatbot
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatbotScreen())), 
                    icon: Icon(Icons.support_agent, color: textColor), 
                    label: Text("Support", style: TextStyle(color: textColor)),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      side: BorderSide(color: lineColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                // CANCEL BUTTON -> Shows Confirmation
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmCancel(context), 
                    icon: Icon(Icons.cancel_outlined, color: Colors.white), 
                    label: Text("Cancel Order", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // 🗑️ Helper: Cancel Dialog
  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Cancel Order?"),
        content: Text("Are you sure you want to cancel this order? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("No")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cancellation request sent!")));
            },
            child: Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}