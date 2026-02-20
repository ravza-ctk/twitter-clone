import 'package:flutter/material.dart';
import 'search_result_screen.dart';

class TwitterSearchScreen extends StatefulWidget {
  const TwitterSearchScreen({super.key});

  @override
  State<TwitterSearchScreen> createState() => _TwitterSearchScreenState();
}

class _TwitterSearchScreenState extends State<TwitterSearchScreen> {
  // Arama çubuğu kontrolcüsü
  final TextEditingController _searchController = TextEditingController(text: " ");

  // Örnek Veri Listesi (Ekran görüntüsündeki gibi karışık veri)
  final List<Map<String, dynamic>> _suggestions = [
    {
      "type": "trend",
      "title": "#EpsteinFiles",
      "subtitle": "Gündemdekiler",
    },
    {
      "type": "trend",
      "title": "#Epstein",
      "subtitle": "Gündemdekiler",
    },
    {
      "type": "trend",
      "title": "epsteinem",
      "subtitle": "Gündemdekiler",
    },
    {
      "type": "user",
      "name": "Gabrielle Epstein",
      "handle": "@GabbyEpstein1",
      "isVerified": true,
      "image": "https://i.pravatar.cc/150?img=1", // Placeholder resim
    },
    {
      "type": "user",
      "name": "epstein",
      "handle": "@epstein",
      "isVerified": false,
      "image": "https://i.pravatar.cc/150?img=2",
    },
    {
      "type": "user",
      "name": "Jennifer Epstein",
      "handle": "@jeneps",
      "isVerified": true,
      "image": "https://i.pravatar.cc/150?img=5",
    },
    {
      "type": "user",
      "name": "Gady Epstein",
      "handle": "@gadyepstein",
      "isVerified": false,
      "image": "https://i.pravatar.cc/150?img=8",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. Bölüm: Arama Çubuğu Alanı ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
              ),
              child: Row(
                children: [
                  // Geri Dön Butonu
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  // Arama Inputu
                  Expanded(
                    child: SizedBox(
                      height: 40, // Twitter'ın arama çubuğu biraz incedir
                      child: TextField(
                        controller: _searchController,
                        autofocus: true, // Sayfa açılınca klavye gelir
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'Twitter\'da Ara',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          fillColor: const Color(0xFFEFF3F4), // Twitter gri tonu
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30), // Tam yuvarlak kenar
                            borderSide: BorderSide.none,
                          ),
                          // Sağdaki 'X' temizleme butonu
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.cancel, size: 20, color: Colors.black),
                            onPressed: () => _searchController.clear(),
                          ),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchResultScreen(searchQuery: value),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),

            // --- 2. Bölüm: Liste (Suggestions) ---
            Expanded(
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final item = _suggestions[index];

                  if (item['type'] == 'trend') {
                    // --- Trend/Hashtag Tasarımı ---
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      title: Text(
                        item['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        item['subtitle'],
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                      trailing: Transform.rotate(
                        angle: -0.7, // Oku kuzey-batı yönüne çevirir
                        child: const Icon(Icons.arrow_upward, color: Colors.grey, size: 20),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchResultScreen(searchQuery: item['title']),
                          ),
                        );
                      },
                    );
                  } else {
                    // --- Kullanıcı Profili Tasarımı ---
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(item['image']),
                        backgroundColor: Colors.grey.shade300,
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              item['name'],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black
                              ),
                            ),
                          ),
                          if (item['isVerified']) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, color: Colors.blue, size: 16),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        item['handle'],
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                      onTap: () {},
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
