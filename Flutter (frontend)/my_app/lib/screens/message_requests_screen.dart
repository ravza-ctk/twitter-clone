import 'package:flutter/material.dart';

class MessageRequestsPage extends StatelessWidget {
  const MessageRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Düz görünüm için gölgeyi kaldır
        centerTitle: false, // Başlık sola hizalı olsun (Android varsayılanı)
        
        // 1. Geri Butonu
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Önceki sayfaya dönme işlemi
            Navigator.pop(context);
          },
        ),
        
        // 2. Sayfa Başlığı
        title: const Text(
          "Mesaj istekleri",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        // 3. Sağ Üst Ayarlar İkonu
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      
      // 4. İçerik Alanı
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0), // Kenarlardan boşluk
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Dikeyde ortala
            crossAxisAlignment: CrossAxisAlignment.start, // Yatayda sola yasla
            children: [
              // Başlık
              const Text(
                "Mesaj isteklerin boş",
                style: TextStyle(
                  fontSize: 28, // Görseldeki gibi büyük font
                  fontWeight: FontWeight.w900, // Çok kalın yazı tipi
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12), // Başlık ile açıklama arası boşluk
              
              // Açıklama Metni
              Text(
                "Takip etmediğin kişilerden gelen mesajları veya grup mesajlarını burada göreceksin. Bu istekleri kabul edebilir veya silebilirsin.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600], // Twitter grisi
                  height: 1.4, // Satır aralığı
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
