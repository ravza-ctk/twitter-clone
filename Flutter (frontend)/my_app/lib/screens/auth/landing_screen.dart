import 'package:flutter/material.dart';
import 'sign_up_step1.dart';
import 'login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Üst Kısım: Logo
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                  child: Text(
                    "X",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.5,
                    ),
                  ),
                ),
              ),
              
              const Spacer(),

              // 2. Orta Kısım: Başlık
              const Text(
                "Şu anda dünyada olup bitenleri gör.",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),

              const Spacer(),

              // 3. Alt Kısım: Butonlar ve Linkler
              
              // Google ile Devam Et Butonu
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontFamily: 'Arial', fontSize: 18, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(text: 'G', style: TextStyle(color: Colors.blue)),
                          TextSpan(text: 'o', style: TextStyle(color: Colors.red)),
                          TextSpan(text: 'o', style: TextStyle(color: Colors.yellow)),
                          TextSpan(text: 'g', style: TextStyle(color: Colors.blue)),
                          TextSpan(text: 'l', style: TextStyle(color: Colors.green)),
                          TextSpan(text: 'e', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Google ile devam et",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // "veya" Ayırıcı Çizgi
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("veya", style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),

              const SizedBox(height: 16),

              // Hesap Oluştur Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpStep1()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Hesap oluştur",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Yasal Metin (RichText)
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11, height: 1.3),
                  children: const [
                    TextSpan(text: "Kaydolarak "),
                    TextSpan(
                      text: "Hizmet Şartlarımızı",
                      style: TextStyle(color: Colors.blue),
                    ),
                    TextSpan(text: ", "),
                    TextSpan(
                      text: "Gizlilik Politikamızı",
                      style: TextStyle(color: Colors.blue),
                    ),
                    TextSpan(text: " ve "),
                    TextSpan(
                      text: "Çerez Kullanımı Politikamızı",
                      style: TextStyle(color: Colors.blue),
                    ),
                    TextSpan(text: " kabul etmiş olursun."),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Giriş Yap Linki
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  children: [
                    Text(
                      "Zaten bir hesabın var mı? ",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        "Giriş yap",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
