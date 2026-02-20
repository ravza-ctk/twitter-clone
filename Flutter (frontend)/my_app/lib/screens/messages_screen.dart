import 'package:flutter/material.dart';
import 'message_requests_screen.dart';
import 'search_users_page.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  // Seçili olan sekmenin indeksi (Varsayılan 0: All)
  int _selectedIndex = 0;

  // Sekme isimleri (Ekran görüntüsündeki gibi)
  final List<String> _tabs = ["All", "Unread", "Groups", "Requests"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Üst Başlık (Header)
            _buildHeader(),
            
            // 2. Arama Çubuğu
            _buildSearchBar(),
            
            // 3. Filtreleme Sekmeleri (All, Unread, Groups...)
            _buildFilterTabs(),
            
            // 4. Değişen İçerik Alanı
            Expanded(
              child: _buildBodyContent(),
            ),
          ],
        ),
      ),
      // Yeni Mesaj Butonu (FAB)
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1D9BF0), // Twitter Mavisi
        child: const Icon(Icons.mail_outline, color: Colors.white),
      ),
    );
  }

  // --- WIDGET PARÇALARI ---

  // 1. Header: Profil, Başlık, Ayarlar
  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'), // Örnek resim
            radius: 16,
          ),
          Text(
            "Sohbet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Icon(Icons.settings_outlined, color: Colors.black),
        ],
      ),
    );
  }

  // 2. Arama Çubuğu
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SearchUsersPage(),
            ),
          );
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200], // Hafif gri arka plan
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, color: Colors.grey, size: 20),
              SizedBox(width: 8),
              Text("Ara", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  // 3. Filtreleme Sekmeleri (Burası asıl istediğin kısım)
  Widget _buildFilterTabs() {
    return Container(
      height: 60, // Yükseklik sınırı
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final bool isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () {
              if (index == 3) {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MessageRequestsPage()),
                );
                return;
              }
              setState(() {
                _selectedIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                // Seçiliyse Siyah, değilse Beyaz
                color: isSelected ? Colors.black : Colors.white,
                // Seçili değilse gri çerçeve
                border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    // Seçiliyse Beyaz yazı, değilse Siyah
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 4. İçerik Mantığı (Switch Case)
  Widget _buildBodyContent() {
    switch (_selectedIndex) {
      case 0: // All
        return _buildChatList();
      case 1: // Unread
        return _buildEmptyState(
          title: "Tümünü okudun!",
          subtitle: "Okunmamış sohbetler burada gösterilecek",
        );
      case 2: // Groups
        return _buildEmptyState(
          title: "Henüz grup sohbeti yok",
          subtitle: "Bir grup sohbeti oluştur ve uçtan uca şifrelemeyi kullanarak sohbet etmeye başla",
        );
      case 3: // Requests
        return _buildEmptyState(
          title: "İstek yok",
          subtitle: "Mesaj istekleri burada görünecek",
        );
      default:
        return Container();
    }
  }

  // Örnek Sohbet Listesi (Görsel 1'deki gibi)
  Widget _buildChatList() {
    return ListView(
      children: const [
        _ChatTile(
            name: "Codie Sanchez",
            isVerified: true,
            message: ".",
            time: "Şimdi",
            image: "https://i.pravatar.cc/150?img=32"),
        _ChatTile(
            name: "non aesthetic things",
            isVerified: true,
            message: ".",
            time: "1 dk",
            image: "https://i.pravatar.cc/150?img=47"),
      ],
    );
  }

  // Boş Durum Tasarımı (Görsel 2 ve 3'teki gibi)
  Widget _buildEmptyState({required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Sola hizalı
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.4),
          ),
        ],
      ),
    );
  }
}

// Yardımcı Widget: Tekil Sohbet Satırı
class _ChatTile extends StatelessWidget {
  final String name;
  final bool isVerified;
  final String message;
  final String time;
  final String image;

  const _ChatTile({
    required this.name,
    required this.isVerified,
    required this.message,
    required this.time,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              name: name,
              avatarUrl: image,
            ),
          ),
        );
      },
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(image),
      ),
      title: Row(
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          if (isVerified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, color: Colors.blue, size: 16),
          ],
          const Spacer(),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
      subtitle: Text(message, style: const TextStyle(color: Colors.grey)),
    );
  }
}
