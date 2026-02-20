import 'package:flutter/material.dart';
import '../../models/sign_up_data.dart';
import '../../services/auth_service.dart';
import 'sign_up_step_password.dart';

class SignUpStep2 extends StatefulWidget {
  final SignUpData data;
  const SignUpStep2({super.key, required this.data});

  @override
  State<SignUpStep2> createState() => _SignUpStep2State();
}

class _SignUpStep2State extends State<SignUpStep2> {
  final _codeController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleVerify() async {
    if (widget.data.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kullanıcı ID bulunamadı!")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await _authService.verifyCode(widget.data.userId!, _codeController.text);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpStepPassword(data: widget.data),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kod doğrulanamadı. Tekrar dene.")));
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Icon(Icons.onetwothree, color: Colors.blue), // Placeholder
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Kodu sana gönderdik",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "${widget.data.emailOrPhone} adresine/numarasına doğrulama kodu gönderildi.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 30),
              
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Doğrulama kodu",
                  border: OutlineInputBorder(),
                ),
              ),

              const Spacer(),

              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleVerify,
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
    );
  }
}
