import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 3 Sekme: Tümü, Onaylanmış, Bahsedenler
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- ÜST BAR (APPBAR) ---
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, color: Colors.grey), // Profil resmi placeholder
          ),
        ),
        title: const Text("Bildirimler"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: "Tümü"),
            Tab(text: "Onaylanmış"),
            Tab(text: "Bahsedenler"),
          ],
        ),
      ),

      // --- GÖVDE (LİSTE İÇERİĞİ) ---
      body: TabBarView(
        controller: _tabController,
        children: [
          // "Tümü" Sekmesi İçeriği
          _buildNotificationList(),
          // placeholder diğer sekmeler için 
          const Center(child: Text(" ")),
          const Center(child: Text(" ")),
        ],
      ),
      
      // FloatingActionButton logic handled here as it's screen specific
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  // Bildirim Listesini Oluşturan Metot
  Widget _buildNotificationList() {
    return ListView(
      children: const [
        // 1. Tip Bildirim: Sistem/Login (X Logolu)
        NotificationTile(
          icon: Icons.close, // X logosu yerine
          iconColor: Colors.black,
          title: "X hesabına 27 Oca 2026 tarihinde yeni bir cihazdan giriş yapıldı.",
          subtitle: "Bunu şimdi inceleyebilirsin.",
          isSystemNotification: true,
        ),
        
        Divider(height: 1, thickness: 0.5), // Ayırıcı çizgi

        // 2. Tip Bildirim: Beğeni (Kalp İkonlu)
        NotificationTile(
          icon: Icons.favorite,
          iconColor: Colors.pink, // Kırmızı/Pembe kalp
          title: "Hira ve diğer 2 kişi gönderini beğendi",
          subtitle: "tweet önizlemesi...", // Tweet içeriği
          hasAvatars: true, // Avatar satırı var mı?
        ),
        
        // Örnek çoğaltma (Liste dolu görünsün diye)
        Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}

// --- ÖZELLEŞTİRİLMİŞ BİLDİRİM BİLEŞENİ ---
class NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool hasAvatars;
  final bool isSystemNotification;

  const NotificationTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.hasAvatars = false,
    this.isSystemNotification = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sol İkon (Kalp veya X)
          SizedBox(
            width: 40,
            child: Icon(icon, color: iconColor, size: 28),
          ),
          
          // Sağ İçerik Alanı
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Eğer beğeni bildirimi ise küçük avatarlar görünür
                if (hasAvatars) 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        _buildSmallAvatar(),
                        const SizedBox(width: 4),
                        _buildSmallAvatar(),
                        const SizedBox(width: 4),
                        _buildSmallAvatar(),
                      ],
                    ),
                  ),
                
                // Bildirim Başlığı (Bold kısım)
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                
                // Bildirim Alt Metni (Gri kısım)
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 15, 
                        color: Colors.grey[600],
                        height: 1.4 // Satır aralığı görseldeki gibi açık olsun
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallAvatar() {
    return const CircleAvatar(
      radius: 14,
      backgroundImage: NetworkImage("https://via.placeholder.com/150"), // Placeholder
      backgroundColor: Colors.grey,
    );
  }
}
