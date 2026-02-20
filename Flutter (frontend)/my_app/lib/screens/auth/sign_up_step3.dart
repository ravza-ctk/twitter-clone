import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/sign_up_data.dart';
import '../../services/auth_service.dart';
import 'sign_up_step4.dart';

class SignUpStep3 extends StatefulWidget {
  final SignUpData data;
  const SignUpStep3({super.key, required this.data});

  @override
  State<SignUpStep3> createState() => _SignUpStep3State();
}

class _SignUpStep3State extends State<SignUpStep3> {
  File? _selectedImage;
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? returnedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (returnedImage != null) {
      setState(() {
        _selectedImage = File(returnedImage.path);
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
        centerTitle: true,
        title: const Icon(Icons.onetwothree, color: Colors.blue),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Profil resmi seç",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Favori bir selfie var mı? Hemen yükle.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 60),

              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                    child: _selectedImage == null
                        ? Icon(Icons.add_a_photo_outlined, size: 60, color: Colors.grey.shade600)
                        : null,
                  ),
                ),
              ),

              const Spacer(),

               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpStep4(data: widget.data),
                        ),
                      );
                    },
                    child: const Text("Şimdilik geç", style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_selectedImage != null) {
                         // Fotoğraf yükle
                         bool success = await _authService.uploadProfilePhoto(widget.data.userId!, _selectedImage!.path);
                         if (!success) {
                           if(context.mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fotoğraf yükleme başarısız, ama devam ediliyor.")));
                           }
                         }
                      }
                      
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpStep4(data: widget.data),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text("İleri", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
