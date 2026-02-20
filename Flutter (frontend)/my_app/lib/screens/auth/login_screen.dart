import 'package:flutter/material.dart';
import '../../services/auth_service.dart'; // 1. BU SATIR EKLENDİ

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 0: Username, 1: Password
  int _currentStep = 0;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Servisi buraya tanımlıyoruz
  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isButtonEnabled = false;
  bool _isLoading = false; // Yükleniyor durumu eklendi

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      if (_currentStep == 0) {
        _isButtonEnabled = _usernameController.text.isNotEmpty;
      } else {
        _isButtonEnabled = _passwordController.text.isNotEmpty;
      }
    });
  }

  void _handleNext() {
    if (_currentStep == 0) {
      // Şifre Ekranına Geç
      setState(() {
        _currentStep = 1;
        _isButtonEnabled = false; 
      });
    } else {
      // Giriş Yapma İşlemi (Burayı güncelledik)
      _handleLogin();
    }
  }

  // GERÇEK GİRİŞ FONKSİYONU
  Future<void> _handleLogin() async {
    // 1. Klavyeyi kapat
    FocusScope.of(context).unfocus();

    // 2. Yükleniyor işaretini aç
    setState(() {
      _isLoading = true;
    });

    // 3. Servise istek at
    bool success = await _authService.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    // 4. Ekran kapandıysa işlem yapma (Güvenlik)
    if (!mounted) return;

    // 5. Yükleniyor işaretini kapat
    setState(() {
      _isLoading = false;
    });

    // 6. Sonuca göre yönlendir
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Giriş Başarılı!"),
          backgroundColor: Colors.green,
        ),
      );
      // Ana sayfaya git ve geri gelmeyi engelle
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Giriş başarısız! Kullanıcı adı veya şifre hatalı."),
          backgroundColor: Colors.red,
        ),
      );
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
          icon: const Icon(Icons.close, color: Colors.black, size: 28),
          onPressed: () {
            if (_currentStep == 1) {
              setState(() {
                _currentStep = 0;
                _updateButtonState();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          "X", // Logo yerine X harfi
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: -1.0,
          ),
        ),
        centerTitle: true,
      ),
      
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            Text(
              _currentStep == 0
                  ? "Başlamak için ilk önce telefon numaranı, e-posta adresini veya @kullanıcıadını gir"
                  : "Şifreni gir",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 30),

            // Adım 0: Kullanıcı Adı
            if (_currentStep == 0)
              TextField(
                controller: _usernameController,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: "Telefon numarası, e-posta veya kullanıcı adı",
                  hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ),

            // Adım 1: Şifre
            if (_currentStep == 1) ...[
              // Salt okunur Kullanıcı Adı gösterimi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _usernameController.text.isEmpty ? "kullanici_adi" : _usernameController.text,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                ),
              ),
              
              const SizedBox(height: 20),

              // Şifre Alanı
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                autofocus: true,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  labelText: "Şifre",
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  floatingLabelStyle: const TextStyle(color: Colors.blue),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 30, top: 10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                "Şifreni mi unuttun?",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            
            // GİRİŞ / İLERİ BUTONU
            ElevatedButton(
              // Eğer loading varsa butonu devre dışı bırak (null), değilse _handleNext
              onPressed: (_isButtonEnabled && !_isLoading) ? _handleNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                disabledBackgroundColor: Colors.grey.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: _isLoading 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  )
                : Text(
                    _currentStep == 0 ? "İleri" : "Giriş yap",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}