import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../main_screen.dart';

class SignUpStep5 extends StatefulWidget {
  final int userId;
  const SignUpStep5({super.key, required this.userId});

  @override
  State<SignUpStep5> createState() => _SignUpStep5State();
}

class _SignUpStep5State extends State<SignUpStep5> {
  final Set<String> _selectedFollows = {};
  
  // Dummy accounts
  final List<Map<String, String>> _suggestedAccounts = [
    {'name': 'Elon Musk', 'handle': '@elonmusk', 'avatar': 'https://pbs.twimg.com/profile_images/1683325380441128960/yRsRRjGO_400x400.jpg'},
    {'name': 'NASA', 'handle': '@NASA', 'avatar': 'https://pbs.twimg.com/profile_images/1321163587679784960/0nG345_W_400x400.jpg'},
    {'name': 'Flutter', 'handle': '@FlutterDev', 'avatar': 'https://storage.googleapis.com/cms-storage-bucket/4fd0dbcc1f130a4e9639.png'},
    {'name': 'Google', 'handle': '@Google', 'avatar': 'https://lh3.googleusercontent.com/COxitq8kL0Ph0IMiJc_3F-dM5U1k7T7G5u3f9hC7L5l2f5k9_456x512'},
    {'name': 'X', 'handle': '@X', 'avatar': 'https://abs.twimg.com/sticky/default_profile_images/default_profile_400x400.png'},
  ];

  void _toggleFollow(String handle) {
    setState(() {
      if (_selectedFollows.contains(handle)) {
        _selectedFollows.remove(handle);
      } else {
        _selectedFollows.add(handle);
      }
    });
  }

  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _completeSignUp() async {
    setState(() {
      _isLoading = true;
    });

    final success = await _authService.completeRegistration(widget.userId);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Navigate to MainScreen and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bir hata oluştu. Tekrar dene.")));
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
                "En az 1 hesabı takip et",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "İlgi alanlarına göre zaman akışını kişiselleştir.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 20),
              
              Expanded(
                child: ListView.separated(
                  itemCount: _suggestedAccounts.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final account = _suggestedAccounts[index];
                    final handle = account['handle']!;
                    final isFollowing = _selectedFollows.contains(handle);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(account['avatar']!),
                      ),
                      title: Text(account['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(handle),
                      trailing: ElevatedButton(
                        onPressed: () => _toggleFollow(handle),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFollowing ? Colors.white : Colors.black,
                          foregroundColor: isFollowing ? Colors.black : Colors.white,
                          side: isFollowing ? const BorderSide(color: Colors.grey) : BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(isFollowing ? "Takip ediliyor" : "Takip et"),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: (_selectedFollows.isNotEmpty && !_isLoading) ? _completeSignUp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Text("Bitir", style: TextStyle(fontSize: 16)),
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
