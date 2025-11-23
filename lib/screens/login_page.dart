import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'signup_page.dart';
import 'product_list.dart';
// import 'main_screen.dart'; // If you have a bottom nav bar, use this.

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(); // 🟢 Added for validation
  final _email = TextEditingController();
  final _password = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true; 

  // 🧹 CRITICAL: Cleanup memory
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🌙 DARK MODE VARIABLES
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedText = isDark ? Colors.grey[400] : Colors.grey[600];
    final inputFill = isDark ? Colors.grey[800] : Colors.grey[100];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.lock_outline_rounded, size: 60, color: Colors.indigo),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Welcome Back!", 
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor)
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Please sign in to continue shopping", 
                    style: TextStyle(fontSize: 16, color: mutedText)
                  ),
                  SizedBox(height: 40),

                  // --- EMAIL INPUT ---
                  _buildTextField(
                    controller: _email,
                    label: "Email Address",
                    icon: Icons.email_outlined,
                    inputType: TextInputType.emailAddress,
                    textColor: textColor,
                    inputFill: inputFill,
                    validator: (val) => val != null && val.contains('@') ? null : "Enter a valid email",
                  ),
                  SizedBox(height: 20),

                  // --- PASSWORD INPUT ---
                  TextFormField(
                    controller: _password,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: textColor),
                    validator: (val) => val != null && val.length > 5 ? null : "Password too short",
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.indigo),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility, 
                          color: Colors.grey
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: inputFill,
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    ),
                  ),

                  // --- FORGOT PASSWORD (Working Logic) ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetPassword,
                      child: Text("Forgot Password?", style: TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  SizedBox(height: 20),

                  // --- LOGIN BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        shadowColor: Colors.indigo.withOpacity(0.4),
                      ),
                      child: _isLoading 
                        ? SizedBox(height: 25, width: 25, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)) 
                        : Text("Sign In", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  SizedBox(height: 30),

                  // --- SIGN UP LINK ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: TextStyle(color: mutedText)),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignupPage())),
                        child: Text(
                          "Sign Up", 
                          style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 16)
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

  // 🛠️ Helper for TextFields
  Widget _buildTextField({
    required TextEditingController controller, 
    required String label, 
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    required Color textColor,
    required Color? inputFill,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      style: TextStyle(color: textColor),
      validator: validator,
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

  // 🔐 Logic: Handle Login
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    // Close keyboard
    FocusScope.of(context).unfocus();

    // 1. Attempt Login
    final err = await Provider.of<AuthProvider>(context, listen: false)
        .signIn(_email.text.trim(), _password.text.trim());

    if (!mounted) return; 

    setState(() => _isLoading = false);

    // 2. Handle Result
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.red)
      );
    } else {
      // 3. Navigate to Home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => ProductListScreen()), 
        (route) => false,
      );
    }
  }

  // 🔐 Logic: Reset Password
  Future<void> _resetPassword() async {
    if (_email.text.isEmpty || !_email.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a valid email to reset password"), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isLoading = true);

    final err = await Provider.of<AuthProvider>(context, listen: false).resetPassword(_email.text.trim());

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password reset link sent to ${_email.text}"), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
    }
  }
}