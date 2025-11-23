import 'dart:io';
import 'dart:typed_data'; 
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:intl/intl.dart';

import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/theme_provider.dart'; 
import 'order_history_page.dart';
import 'wishlist_page.dart';
import 'address_list_page.dart';
import 'login_page.dart';
import 'chatbot_screen.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isUploading = false;

  // 📸 Show Dialog to Choose Camera or Gallery
  void _showImagePickerOptions(User user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.indigo),
              title: Text("Photo Library", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(user, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.indigo),
              title: Text("Take Photo", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(user, ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 📤 Logic: Pick & Upload
  Future<void> _pickAndUploadImage(User user, ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source, 
      imageQuality: 60, 
      maxWidth: 800,    
    );

    if (pickedFile != null) {
      setState(() => _isUploading = true);

      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_profile_images')
            .child('${user.uid}.jpg');

        // 2. Check Platform to choose upload method
        if (kIsWeb) {
          Uint8List bytes = await pickedFile.readAsBytes();
          await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        } else {
          File file = File(pickedFile.path);
          await ref.putFile(file);
        }

        final imageUrl = await ref.getDownloadURL();

        await user.updatePhotoURL(imageUrl);
        await user.reload();

        if (mounted) {
           Provider.of<AuthProvider>(context, listen: false).reloadUser();
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated!"), backgroundColor: Colors.green));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed: $e"), backgroundColor: Colors.red));
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  // ✏️ Edit Name Dialog
  void _editName(BuildContext context, User user) {
    final _nameController = TextEditingController(text: user.displayName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Edit Name", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: TextField(
          controller: _nameController,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: "Enter full name",
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () async {
              if (_nameController.text.isNotEmpty) {
                await user.updateDisplayName(_nameController.text);
                await user.reload();
                if (mounted) {
                  Provider.of<AuthProvider>(context, listen: false).reloadUser();
                  Navigator.pop(c);
                }
              }
            },
            child: Text("Save", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final user = authProvider.user;

    if (user == null) return Scaffold(body: Center(child: CircularProgressIndicator()));

    // 🌙 DARK MODE VARIABLES
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedText = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 280,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark 
                          ? [Colors.indigo.shade900, Colors.black] 
                          : [Colors.indigo.shade800, Colors.indigo.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                  ),
                  child: SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text("Profile", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
                
                Positioned(
                  top: 50, left: 20,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),

                // Profile Card
                Positioned(
                  bottom: -60,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 10))],
                    ),
                    child: Column(
                      children: [
                        // Image
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: (user.photoURL != null) ? NetworkImage(user.photoURL!) : null,
                              child: (user.photoURL == null) ? Icon(Icons.person, size: 50, color: Colors.grey) : null,
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: GestureDetector(
                                onTap: _isUploading ? null : () => _showImagePickerOptions(user),
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: Colors.indigo, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                  child: _isUploading 
                                      ? SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 10),
                        // Name
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user.displayName ?? "Guest",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            SizedBox(width: 5),
                            GestureDetector(
                              onTap: () => _editName(context, user),
                              child: Icon(Icons.edit_outlined, size: 18, color: Colors.indigo),
                            )
                          ],
                        ),
                        Text(user.email ?? "", style: TextStyle(color: mutedText, fontSize: 13)),
                        SizedBox(height: 5),
                        // Joined Date
                        if (user.metadata.creationTime != null)
                          Text(
                            "Member since ${DateFormat.yMMMd().format(user.metadata.creationTime!)}",
                            style: TextStyle(color: Colors.indigo, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 80),

            // --- STATS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(Icons.account_balance_wallet, "₹0", "Wallet", Colors.orange, cardColor, textColor, mutedText),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('orders').where('userId', isEqualTo: user.uid).snapshots(),
                      builder: (context, snapshot) {
                        String count = snapshot.hasData ? snapshot.data!.docs.length.toString() : "0";
                        return _buildStatCard(Icons.shopping_bag_outlined, count, "Orders", Colors.blue, cardColor, textColor, mutedText);
                      },
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: _buildStatCard(Icons.favorite_border, productProvider.favorites.length.toString(), "Wishlist", Colors.redAccent, cardColor, textColor, mutedText),
                  ),
                ],
              ),
            ),

            SizedBox(height: 25),

            // --- MENU LIST ---
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("My Account"),
                  _buildMenuTile(Icons.history_rounded, "Order History", "Track & view orders", () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderHistoryPage())), cardColor, textColor, mutedText),
                  _buildMenuTile(Icons.location_on_outlined, "Shipping Addresses", "Manage delivery locations", () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddressListPage())), cardColor, textColor, mutedText),
                  _buildMenuTile(Icons.favorite_outline, "My Wishlist", "Your saved items", () => Navigator.push(context, MaterialPageRoute(builder: (_) => WishlistPage())), cardColor, textColor, mutedText),

                  SizedBox(height: 20),
                  _buildSectionHeader("App Settings"),
                  
                  // Dark Mode Switch
                  Container(
                    margin: EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
                    child: SwitchListTile(
                      secondary: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.dark_mode_outlined, color: Colors.purple),
                      ),
                      title: Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (val) => themeProvider.toggleTheme(val),
                      activeColor: Colors.indigo,
                    ),
                  ),

                  _buildMenuTile(Icons.support_agent, "Help & Support", "Chat with AI Assistant", () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatbotScreen())), cardColor, textColor, mutedText),
                  
                  SizedBox(height: 10),
                  _buildMenuTile(Icons.logout_rounded, "Log Out", "Sign out of your account", () async {
                    bool confirm = await _showLogoutDialog(context, isDark);
                    if(confirm) {
                      await authProvider.signOut();
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginPage()), (r) => false);
                    }
                  }, cardColor, textColor, mutedText, isDestructive: true),

                  SizedBox(height: 20),
                  Center(child: Text("v1.0.0", style: TextStyle(color: mutedText, fontSize: 12))),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildStatCard(IconData icon, String val, String label, Color color, Color bg, Color text, Color subText) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(val, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: text)),
          Text(label, style: TextStyle(color: subText, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, String subtitle, VoidCallback onTap, Color bg, Color text, Color subText, {bool isDestructive = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDestructive ? Colors.red.withOpacity(0.1) : Colors.indigo.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: isDestructive ? Colors.red : Colors.indigo, size: 22),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDestructive ? Colors.red : text)),
        subtitle: Text(subtitle, style: TextStyle(color: subText, fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
    );
  }

  Future<bool> _showLogoutDialog(BuildContext context, bool isDark) async {
    return await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        title: Text("Log Out", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text("Are you sure you want to log out?", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text("Cancel", style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text("Log Out", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;
  }
}