import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  // 🔔 Dummy Data
  List<Map<String, dynamic>> notifications = [
    {
      'id': '1',
      'title': 'Order Shipped!',
      'body': 'Your order #12345 has been shipped and is on its way.',
      'time': '2 min ago',
      'type': 'order', 
      'isRead': false,
    },
    {
      'id': '2',
      'title': '50% Off Sale!',
      'body': 'Flash sale on all Sneakers. Limited time offer.',
      'time': '1 hour ago',
      'type': 'offer',
      'isRead': false,
    },
    {
      'id': '3',
      'title': 'Account Security',
      'body': 'Your password was changed successfully.',
      'time': '1 day ago',
      'type': 'info',
      'isRead': true,
    },
    {
      'id': '4',
      'title': 'Review Request',
      'body': 'How did you like your recent purchase? Leave a review!',
      'time': '2 days ago',
      'type': 'info',
      'isRead': true,
    },
  ];

  void _markAsRead(int index) {
    setState(() {
      notifications[index]['isRead'] = true;
    });
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Clear Notifications?"),
        content: Text("This will remove all notifications permanently."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() => notifications.clear());
              Navigator.pop(ctx);
            }, 
            child: Text("Clear All", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌙 DARK MODE VARIABLES
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final mutedText = isDark ? Colors.grey[400] : Colors.grey[700];
    final unreadColor = isDark ? Colors.indigo.withOpacity(0.2) : Colors.indigo.withOpacity(0.05);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Notifications", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: _confirmClearAll,
              child: Text("Clear All", style: TextStyle(color: Colors.indigoAccent)),
            )
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(textColor, mutedText)
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return Dismissible(
                  // 🛡️ CRASH FIX: Use UniqueKey() instead of Title
                  // If two notifications had the same title, the app would crash.
                  key: UniqueKey(), 
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    margin: EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.redAccent, 
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    setState(() => notifications.removeAt(index));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Notification removed"), duration: Duration(seconds: 1)));
                  },
                  child: GestureDetector(
                    onTap: () => _markAsRead(index),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 15),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: n['isRead'] ? cardColor : unreadColor,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                        border: n['isRead'] ? null : Border.all(color: Colors.indigo.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _getIconColor(n['type']).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_getIcon(n['type']), color: _getIconColor(n['type']), size: 24),
                          ),
                          SizedBox(width: 15),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        n['title'], 
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)
                                      ),
                                    ),
                                    Text(n['time'], style: TextStyle(color: mutedText, fontSize: 12)),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(n['body'], style: TextStyle(color: mutedText, fontSize: 14)),
                              ],
                            ),
                          ),
                          // Unread Dot
                          if (!n['isRead'])
                            Container(
                              margin: EdgeInsets.only(left: 10, top: 5),
                              width: 8, height: 8,
                              decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ✨ HELPER: Empty State
  Widget _buildEmptyState(Color textColor, Color? mutedText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 20),
          Text("No Notifications", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          Text("We'll let you know when something happens!", style: TextStyle(color: mutedText)),
        ],
      ),
    );
  }

  // ✨ HELPER: Icons based on type
  IconData _getIcon(String type) {
    switch (type) {
      case 'order': return Icons.local_shipping;
      case 'offer': return Icons.local_offer;
      default: return Icons.info_outline;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'order': return Colors.blue;
      case 'offer': return Colors.orange;
      default: return Colors.indigo;
    }
  }
}