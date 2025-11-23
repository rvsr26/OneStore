import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 📦 Ensure this is in pubspec.yaml
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';
import 'profile_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  String _version = "1.0.0"; 

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // 💾 Load Notification Preference
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  // 💾 Save Notification Preference
  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _notificationsEnabled = value);
    await prefs.setBool('notifications_enabled', value);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final mutedText = isDark ? Colors.grey[400] : Colors.grey[600];
    final iconColor = isDark ? Colors.indigoAccent : Colors.indigo;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("General", mutedText),
            _buildCard(
              cardColor,
              children: [
                SwitchListTile(
                  activeColor: Colors.indigo,
                  title: Text("Dark Mode", style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                  secondary: Icon(Icons.dark_mode_outlined, color: iconColor),
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) => themeProvider.toggleTheme(value),
                ),
                _buildDivider(isDark),
                SwitchListTile(
                  activeColor: Colors.indigo,
                  title: Text("Push Notifications", style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                  secondary: Icon(Icons.notifications_none_outlined, color: iconColor),
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                ),
              ],
            ),
            
            SizedBox(height: 20),

            _buildSectionHeader("Account", mutedText),
            _buildCard(
              cardColor,
              children: [
                _buildTile(
                  icon: Icons.person_outline, 
                  title: "Edit Profile", 
                  textColor: textColor,
                  iconColor: iconColor,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()))
                ),
                _buildDivider(isDark),
                _buildTile(
                  icon: Icons.lock_outline, 
                  title: "Change Password", 
                  textColor: textColor,
                  iconColor: iconColor,
                  onTap: () => _confirmPasswordReset(context, authProvider, user?.email),
                ),
                _buildDivider(isDark),
                _buildTile(
                  icon: Icons.delete_outline, 
                  title: "Delete Account", 
                  textColor: Colors.redAccent,
                  iconColor: Colors.redAccent,
                  onTap: () => _confirmDeleteAccount(context)
                ),
              ],
            ),

            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text("Log Out", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () => _confirmLogout(context, authProvider),
              ),
            ),
            SizedBox(height: 20),
            Center(child: Text("Version $_version", style: TextStyle(color: mutedText, fontSize: 12))),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color? color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(title.toUpperCase(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color, letterSpacing: 1.2)),
    );
  }

  Widget _buildCard(Color color, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile({required IconData icon, required String title, required Color textColor, required Color iconColor, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(height: 1, thickness: 1, color: isDark ? Colors.grey[800] : Colors.grey[100], indent: 60);
  }

  // 🔓 Logic: Password Reset
  void _confirmPasswordReset(BuildContext context, AuthProvider auth, String? email) {
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No email found.")));
      return;
    }
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text("Reset Password"),
        content: Text("Send a password reset link to $email?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(c);
              await auth.resetPassword(email);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Reset link sent! Check your email."), backgroundColor: Colors.green));
            },
            child: Text("Send", style: TextStyle(color: Colors.indigo)),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text("Log Out"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text("Cancel")),
          TextButton(
            onPressed: () async {
              await auth.signOut();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginPage()), (r) => false);
            }, 
            child: Text("Log Out", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text("Delete Account", style: TextStyle(color: Colors.red)),
        content: Text("This action is irreversible. Your data will be permanently removed."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              // In a real app, you would call auth.deleteUser() here
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please contact support to delete your account securely.")));
            },
            child: Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}