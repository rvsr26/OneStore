import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import '../providers/auth_provider.dart' as app_auth;
import 'product_list.dart'; 

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // 🧹 CRITICAL: Clean up controllers to prevent memory leaks
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🌙 Dark Mode Support
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final inputFill = isDark ? Colors.grey[800] : Colors.grey[100];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(25),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
                  Text(
                    "Create Account", 
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor)
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Join us and start shopping today!", 
                    style: TextStyle(fontSize: 16, color: Colors.grey[600])
                  ),
                  SizedBox(height: 40),

                  // --- FULL NAME ---
                  _buildTextField(
                    controller: _nameController,
                    label: "Full Name",
                    icon: Icons.person_outline,
                    inputType: TextInputType.name,
                    textColor: textColor,
                    inputFill: inputFill,
                  ),
                  SizedBox(height: 20),

                  // --- EMAIL ---
                  _buildTextField(
                    controller: _emailController,
                    label: "Email Address",
                    icon: Icons.email_outlined,
                    inputType: TextInputType.emailAddress,
                    textColor: textColor,
                    inputFill: inputFill,
                  ),
                  SizedBox(height: 20),

                  // --- PASSWORD ---
                  _buildPasswordField(
                    controller: _passController,
                    label: "Password",
                    isObscure: _obscurePass,
                    onToggle: () => setState(() => _obscurePass = !_obscurePass),
                    textColor: textColor,
                    inputFill: inputFill,
                  ),
                  SizedBox(height: 20),

                  // --- CONFIRM PASSWORD ---
                  _buildPasswordField(
                    controller: _confirmPassController,
                    label: "Confirm Password",
                    isObscure: _obscureConfirm,
                    onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    textColor: textColor,
                    inputFill: inputFill,
                    validator: (val) {
                      if (val != _passController.text) return "Passwords do not match";
                      return null;
                    }
                  ),
                  
                  SizedBox(height: 40),

                  // --- SIGN UP BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                      child: _isLoading 
                        ? CircularProgressIndicator(color: Colors.white) 
                        : Text("Sign Up", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),

                  SizedBox(height: 20),

                  // --- LOGIN LINK ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? ", style: TextStyle(color: Colors.grey[600])),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          "Login", 
                          style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🛠️ LOGIC: Handle Sign Up
  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus(); // Close keyboard

    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);

    // 1. Create User in Firebase
    final error = await authProvider.signUp(
      _emailController.text.trim(), 
      _passController.text.trim()
    );

    if (error != null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
    } else {
      // 2. Success: Update Display Name
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updateDisplayName(_nameController.text.trim());
          await user.reload();
          authProvider.reloadUser(); 
        }
      } catch (e) {
        print("Failed to update profile name: $e");
      }

      setState(() => _isLoading = false);
      
      if (!mounted) return;
      
      Navigator.pop(context); // Go back to Login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account created successfully! Please Login."), backgroundColor: Colors.green)
      );
    }
  }

  // ✨ HELPER: Normal Text Field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    required Color textColor,
    required Color? inputFill,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      style: TextStyle(color: textColor),
      textInputAction: TextInputAction.next,
      validator: (value) => value!.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        filled: true,
        fillColor: inputFill,
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }

  // ✨ HELPER: Password Field
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isObscure,
    required VoidCallback onToggle,
    required Color textColor,
    required Color? inputFill,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: TextStyle(color: textColor),
      validator: validator ?? (val) => (val!.length < 6) ? "Password must be 6+ chars" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(Icons.lock_outline, color: Colors.indigo),
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        filled: true,
        fillColor: inputFill,
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }
}