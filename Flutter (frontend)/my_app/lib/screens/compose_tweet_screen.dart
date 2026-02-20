import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ID okumak için
import '../models/tweet_model.dart';
import '../services/tweet_service.dart';

class ComposeTweetScreen extends StatefulWidget {
  final Tweet? quotedTweet;
  const ComposeTweetScreen({super.key, this.quotedTweet});

  @override
  State<ComposeTweetScreen> createState() => _ComposeTweetScreenState();
}

class _ComposeTweetScreenState extends State<ComposeTweetScreen> {
  final TextEditingController _tweetController = TextEditingController();
  bool _isPosting = false; // Tweet gönderilirken butonu kilitlemek için

  @override
  void dispose() {
    _tweetController.dispose();
    super.dispose();
  }

  // GERÇEK API İŞLEMİ
  Future<void> _postTweet() async {
  if (_tweetController.text.trim().isEmpty) return;

  setState(() => _isPosting = true);

  try {
    final prefs = await SharedPreferences.getInstance();
    final int? currentUserId = prefs.getInt('userId');

    if (currentUserId == null) throw Exception("Oturum bulunamadı.");

    // DEĞİŞİKLİK BURADA: Artık success (bool) değil, newTweet (Tweet nesnesi) bekliyoruz
    final Tweet? newTweet = await TweetService().createTweet(
      userId: currentUserId,
      content: _tweetController.text,
    );

    if (newTweet != null && mounted) {
      // BAŞARILI! Geriye dönerken YENİ TWEETİ de götür.
      Navigator.pop(context, newTweet); 
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tweet gönderildi!"), backgroundColor: Colors.green),
      );
    }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Hata oluştu: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Butonun aktif olma şartı: metin boş olmayacak ve o an gönderim yapılmıyor olacak
    final bool canPost = _tweetController.text.isNotEmpty && !_isPosting;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: ElevatedButton(
              onPressed: canPost ? _postTweet : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                disabledBackgroundColor: Colors.blue.withValues(alpha: 0.5),
              ),
              child: _isPosting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Post', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView( // Klavye açıldığında taşma olmaması için
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=3'),
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _tweetController,
                      decoration: const InputDecoration(
                        hintText: "What's happening?",
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      onChanged: (value) {
                        setState(() {});
                      },
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }