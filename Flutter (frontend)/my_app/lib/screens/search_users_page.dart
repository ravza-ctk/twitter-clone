import 'package:flutter/material.dart';
import 'chat_screen.dart';

class SearchUsersPage extends StatelessWidget {
  const SearchUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0, // Sol boşluğu azalt
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        // Başlık yerine Arama Alanı (TextField)
        title: const TextField(
          autofocus: true, // Sayfa açılınca klavye gelsin
          decoration: InputDecoration(
            hintText: "Ara",
            hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none, // Alt çizgiyi kaldır
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Kullanıcı
            _UserResultItem(
              name: "Codie Sanchez",
              handle: "@Codie_Sanchez",
              imageUrl: "https://i.pravatar.cc/150?img=32", // Örnek Resim
              onTap: () => _openChat(context, "Codie Sanchez", "https://i.pravatar.cc/150?img=32"),
            ),
            
            const SizedBox(width: 24), // İki kişi arasındaki boşluk
            
            // 2. Kullanıcı
            _UserResultItem(
              name: "non aesthetic t...",
              handle: "@PicturesFoIder",
              imageUrl: "https://i.pravatar.cc/150?img=47", // Örnek Resim
              onTap: () => _openChat(context, "non aesthetic things", "https://i.pravatar.cc/150?img=47"),
            ),
          ],
        ),
      ),
    );
  }

  // Sohbet Sayfasını Açan Fonksiyon
  void _openChat(BuildContext context, String userName, String avatarUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          name: userName,
          avatarUrl: avatarUrl,
        ),
      ),
    );
  }
}

// --- Alt Bileşen: Kullanıcı Arama Sonucu Öğesi ---
class _UserResultItem extends StatelessWidget {
  final String name;
  final String handle;
  final String imageUrl;
  final VoidCallback onTap;

  const _UserResultItem({
    required this.name,
    required this.handle,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30, // Büyük profil resmi
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            handle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
