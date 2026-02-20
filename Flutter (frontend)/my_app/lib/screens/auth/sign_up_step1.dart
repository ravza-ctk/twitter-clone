import 'package:flutter/material.dart';
import '../../models/sign_up_data.dart';
import '../../services/auth_service.dart';
import 'sign_up_step2.dart';

class SignUpStep1 extends StatefulWidget {
  const SignUpStep1({super.key});

  @override
  State<SignUpStep1> createState() => _SignUpStep1State();
}

class _SignUpStep1State extends State<SignUpStep1> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _dobController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  
  // State variables
  final SignUpData _signUpData = SignUpData();
  bool _useEmail = true;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_signUpData.dateOfBirth == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen doğum tarihini seç")));
        return;
      }

      setState(() {
        _isLoading = true;
      });

      _signUpData.name = _nameController.text;
      _signUpData.emailOrPhone = _contactController.text;
      
      // Backend yyyy-MM-dd formatında bekliyor
      String formattedDate = "${_signUpData.dateOfBirth!.year}-${_signUpData.dateOfBirth!.month.toString().padLeft(2, '0')}-${_signUpData.dateOfBirth!.day.toString().padLeft(2, '0')}";

      try {
        final userId = await _authService.registerStep1(
          _signUpData.name, 
          _signUpData.emailOrPhone, 
          formattedDate
        );

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        if (userId != null) {
          _signUpData.userId = userId;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignUpStep2(data: _signUpData),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        // Hata mesajını temizle (Exception: ... kısmını at)
        String message = e.toString().replaceAll("Exception: ", "");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Default 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _signUpData.dateOfBirth = picked;
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Icon(Icons.onetwothree, color: Colors.blue), // Placeholder icon
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Hesabını oluştur",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                
                // Name Input
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "İsim",
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Lütfen ismini gir';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Phone/Email Input
                TextFormField(
                  controller: _contactController,
                  keyboardType: _useEmail ? TextInputType.emailAddress : TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: _useEmail ? "E-posta" : "Telefon",
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Lütfen bilgini gir';
                    return null;
                  },
                ),
                
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _useEmail = !_useEmail;
                        _contactController.clear();
                      });
                    },
                    child: Text(_useEmail ? "Telefon kullan" : "E-posta kullan"),
                  ),
                ),

                const SizedBox(height: 10),

                // DOB Input
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: const InputDecoration(
                    labelText: "Doğum tarihi",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Lütfen doğum tarihini seç';
                    return null;
                  },
                ),

                const Spacer(),

                // Next Button
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("İleri", style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
