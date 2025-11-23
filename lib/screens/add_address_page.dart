import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/address.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';

class AddAddressPage extends StatefulWidget {
  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    // 🧹 Cleanup controllers to free memory
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  // 💾 Logic: Save Address to Firestore
  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);
    
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) throw Exception("User not logged in");
      
      final newAddress = Address(
        id: '', // FirestoreService should handle ID generation
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zip: _zipController.text.trim(),
      );

      await FirestoreService().addAddress(user.uid, newAddress);
      
      if (!mounted) return;

      // Success Feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address Saved Successfully!"), backgroundColor: Colors.green)
      );
      Navigator.pop(context); // Return to previous screen

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save: $e"), backgroundColor: Colors.red)
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌙 DARK MODE VARIABLES
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final inputFill = isDark ? Colors.grey[800] : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Add New Address", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECTION 1: CONTACT INFO ---
              _buildSectionTitle("Contact Details", hintColor),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _nameController,
                label: "Full Name",
                icon: Icons.person_outline,
                inputType: TextInputType.name,
                capitalization: TextCapitalization.words, // Capitalize Names
                isDark: isDark, inputFill: inputFill, textColor: textColor, hintColor: hintColor
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _phoneController,
                label: "Phone Number",
                icon: Icons.phone_iphone,
                inputType: TextInputType.phone,
                validator: (v) => (v == null || v.length < 10) ? "Enter a valid 10-digit number" : null,
                isDark: isDark, inputFill: inputFill, textColor: textColor, hintColor: hintColor
              ),

              const SizedBox(height: 30),

              // --- SECTION 2: ADDRESS INFO ---
              _buildSectionTitle("Address Details", hintColor),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _streetController,
                label: "House No, Building, Street Area",
                icon: Icons.home_outlined,
                inputType: TextInputType.streetAddress,
                capitalization: TextCapitalization.sentences,
                maxLines: 2,
                isDark: isDark, inputFill: inputFill, textColor: textColor, hintColor: hintColor
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cityController,
                      label: "City / District",
                      icon: Icons.location_city,
                      capitalization: TextCapitalization.words,
                      isDark: isDark, inputFill: inputFill, textColor: textColor, hintColor: hintColor
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      controller: _stateController,
                      label: "State",
                      icon: Icons.map_outlined,
                      capitalization: TextCapitalization.words,
                      isDark: isDark, inputFill: inputFill, textColor: textColor, hintColor: hintColor
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _zipController,
                label: "Pincode (Zip)",
                icon: Icons.pin_drop_outlined,
                inputType: TextInputType.number,
                validator: (v) => (v == null || v.length < 5) ? "Invalid Pincode" : null,
                isDark: isDark, inputFill: inputFill, textColor: textColor, hintColor: hintColor,
                isLast: true, // Changes Enter key to "Done"
                onFieldSubmitted: (_) => _saveAddress(),
              ),

              const SizedBox(height: 40),

              // --- SAVE BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: _isLoading ? null : _saveAddress,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("Save Address", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ✨ HELPER: Section Title
  Widget _buildSectionTitle(String title, Color? color) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color, letterSpacing: 1.2),
    );
  }

  // ✨ HELPER: Reusable Text Field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool isLast = false,
    void Function(String)? onFieldSubmitted,
    required bool isDark,
    required Color? inputFill,
    required Color textColor,
    required Color? hintColor
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      textCapitalization: capitalization,
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: onFieldSubmitted,
      maxLines: maxLines,
      style: TextStyle(color: textColor),
      validator: validator ?? (value) => value!.isEmpty ? "This field is required" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: hintColor),
        alignLabelWithHint: true,
        prefixIcon: Icon(icon, color: isDark ? Colors.indigoAccent : Colors.indigo, size: 22),
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.indigo, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}