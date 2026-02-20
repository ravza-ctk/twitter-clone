import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/sign_up_data.dart';
import '../../services/auth_service.dart';
import 'sign_up_step5.dart';

class SignUpStep4 extends StatefulWidget {
  final SignUpData data;
  const SignUpStep4({super.key, required this.data});

  @override
  State<SignUpStep4> createState() => _SignUpStep4State();
}

class _SignUpStep4State extends State<SignUpStep4> {
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _usernameController.text = "${widget.data.name.replaceAll(' ', '').toLowerCase()}${DateTime.now().millisecond}";
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final newUsername = await _authService.setUsername(widget.data.userId!, _usernameController.text);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (newUsername != null) {
        widget.data.username = newUsername;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpStep5(userId: widget.data.userId!),
          ),
        );
      } else {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bu kullanıcı adı alınmış veya bir hata oluştu.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Icon(Icons.onetwothree, color: Colors.blue),
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
                  "Sana ne diyelim?",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Telefon numaran veya e-postan gizli kalır. @kullaniciadi herkese açıktır.",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
                const SizedBox(height: 30),
                
                TextFormField(
                  controller: _usernameController,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'@')),
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                  decoration: const InputDecoration(
                    labelText: "Kullanıcı adı",
                    border: OutlineInputBorder(),
                    prefixText: "@",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Kullanıcı adı gerekli';
                    if (value.length < 4) return 'En az 4 karakter olmalı';
                    if (value.contains('@')) return '@ işareti kullanılamaz';
                    return null;
                  },
                ),

                const Spacer(),

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
