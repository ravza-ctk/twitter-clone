import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../screens/auth/landing_screen.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({super.key});

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  User? _user;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    // Get current user profile from backend
    final user = await _userService.getMyProfile();
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ÜST KISIM (HEADER) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profil Resmi ve 3 Nokta İkonu Satırı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 24,
                          backgroundImage: _user?.avatarUrl != null 
                              ? NetworkImage(_user!.avatarUrl!) 
                              : const NetworkImage('https://static.vecteezy.com/system/resources/thumbnails/030/504/836/small/avatar-account-flat-isolated-on-transparent-background-for-graphic-and-web-design-default-social-media-profile-photo-symbol-profile-and-people-silhouette-user-icon-vector.jpg'),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert_outlined, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // İsim ve Kullanıcı Adı
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _user?.name ?? "Kullanıcı",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black),
                        ),
                        Text(
                          "@${_user?.username ?? 'kullanici'}",
                          style: const TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Takipçi Sayıları
                  Row(
                    children: [
                      _buildFollowText(_user?.followingCount.toString() ?? "0", "Takip edilen"),
                      const SizedBox(width: 16),
                      _buildFollowText(_user?.followersCount.toString() ?? "0", "Takipçi"),
                    ],
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1), // İnce çizgi

            // --- LİSTE ELEMANLARI (SCROLL EDİLEBİLİR ALAN) ---
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(Icons.person_outline, "Profil", onTap: () {
                     Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                  }),
                  _buildMenuItem(Icons.close, "Premium"), // X logosu yerine close
                  _buildMenuItem(Icons.group_outlined, "Topluluklar"),
                  _buildMenuItem(Icons.bookmark_border, "Yer işaretleri"),
                  _buildMenuItem(Icons.list_alt, "Listeler"),
                  _buildMenuItem(Icons.mic_none_outlined, "Sohbet Odaları"),
                  _buildMenuItem(Icons.science_outlined, "İçerik Üreticisi Stüdyosu"), // Deney tüpü ikonu

                  const Divider(), // Ayarlar öncesi çizgi

                  // Açılır Menü (Ayarlar & Destek)
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent), // Çizgiyi gizlemek için
                    child: ExpansionTile(
                      title: const Text(
                        "Ayarlar & Destek",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      children: [
                        _buildMenuItem(Icons.settings_outlined, "Ayarlar ve gizlilik", isSubItem: true),
                        _buildMenuItem(Icons.help_outline, "Yardım Merkezi", isSubItem: true),
                         _buildMenuItem(Icons.logout, "Çıkış Yap", isSubItem: true, onTap: () async {
                            await _authService.logout();
                            if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context, 
                                  MaterialPageRoute(builder: (context) => const LandingScreen()), 
                                  (route) => false
                                );
                            }
                         }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- ALT KISIM (FOTER) ---
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  // Tema değiştirme kodu buraya
                },
                child: const Icon(Icons.wb_sunny_outlined, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Menü elemanı oluşturucu (Tekrarı önlemek için)
  Widget _buildMenuItem(IconData icon, String text, {bool isSubItem = false, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: isSubItem ? 16.0 : 24.0),
      leading: isSubItem 
        ? null // Alt menüde ikon yoksa null (Görselde ikon var mı? Yoksa Icon koyabilirsin)
        : Icon(icon, color: Colors.black, size: 26), 
      title: Text(
        text,
        style: TextStyle(
          fontSize: isSubItem ? 15 : 20, 
          fontWeight: isSubItem ? FontWeight.w400 : FontWeight.bold,
          color: Colors.black
        ),
      ),
      onTap: onTap ?? () {},
    );
  }

  // Takipçi yazısı oluşturucu
  Widget _buildFollowText(String count, String label) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 15, color: Colors.black),
        children: [
          TextSpan(text: "$count ", style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
