import 'package:flutter/material.dart';
import '../services/tweet_service.dart';
import '../models/tweet_model.dart';
import '../widgets/tweet_card.dart';
import '../widgets/side_drawer.dart';
import 'tweet_detail_screen.dart';
import 'compose_tweet_screen.dart'; // Compose ekranını import ettik

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 1. TabController'ı başlat (vsync: this için SingleTickerProviderStateMixin lazım)
    _tabController = TabController(length: 2, vsync: this);
    
    // 2. Sayfa açılınca verileri API'den çek
    TweetService().fetchFeed();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Tweet Listesini Oluşturan Yardımcı Widget
  Widget _buildTweetList() {
    return ValueListenableBuilder<bool>(
      valueListenable: TweetService().isLoading,
      builder: (context, loading, child) {
        // İlk yüklemede dönen çember göster (Sadece liste boşsa)
        if (loading && TweetService().tweets.value.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ValueListenableBuilder<List<Tweet>>(
          valueListenable: TweetService().tweets,
          builder: (context, tweetList, child) {
            
            if (tweetList.isEmpty && !loading) {
              return const Center(child: Text("Henüz tweet yok. İlk tweeti sen at!"));
            }

            return RefreshIndicator(
              // Aşağı çekince yenileme özelliği
              onRefresh: () async {
                await TweetService().fetchFeed();
              },
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: tweetList.length,
                itemBuilder: (context, index) {
                  final tweet = tweetList[index];

                  return TweetCard(
                    tweet: tweet,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TweetDetailScreen(tweet: tweet),
                        ),
                      );
                    },
                    // Like İşlemi
                    onLikePressed: () {
                      if (tweet.id != null) {
                        TweetService().toggleLike(tweet.id!);
                      }
                    },
                    // Yorum (Detaya git)
                    onCommentPressed: (t) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TweetDetailScreen(tweet: t),
                        ),
                      );
                    },
                    // Retweet / Alıntıla
                    onQuoteRetweet: (t) async {
                      if (t.isRetweeted) {
                        // Zaten retweet edilmişse, geri al
                        await TweetService().toggleRetweet(t.id!);
                      } else {
                        // Seçenekleri Göster
                        showModalBottomSheet(
                          context: context,
                          builder: (modalContext) {
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.repeat, size: 28),
                                    title: const Text('Yeniden Gönder',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                                    onTap: () async {
                                      Navigator.pop(modalContext);
                                      await TweetService().toggleRetweet(t.id!);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.create_outlined, size: 28),
                                    title: const Text('Alıntıyla Gönder',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                                    onTap: () async {
                                      Navigator.pop(modalContext);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ComposeTweetScreen(quotedTweet: t),
                                        ),
                                      ).then((_) {
                                        TweetService().fetchFeed();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideDrawer(),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: true,
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false, 
              centerTitle: true,

              // 1. SOL ÜST: Profil İkonu
              leadingWidth: 56,
              leading: Padding(
                padding: const EdgeInsets.all(9.0),
                child: GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Icons.person, color: Colors.black, size: 24),
                  ),
                ),
              ),

              // 2. ORTA: Logo
              title: SizedBox(
                height: 32,
                child: Image.network(
                  'https://img.freepik.com/premium-vektor/twitter-yeni-x-logo-tasarimi-vektoru_1340851-70.jpg',
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => const Icon(Icons.close, color: Colors.black, size: 28),
                ),
              ),

              // 3. SAĞ ÜST: Ayarlar vs.
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.black),
                  onPressed: () {},
                ),
              ],

              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.blue,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: "Sana özel"),
                  Tab(text: "Takip edilenler"),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Her iki tab için de tweet listesini çağırıyoruz
            _buildTweetList(),
            _buildTweetList(), // İlerde buraya 'Following' servisi bağlanabilir
          ],
        ),
      ),
    );
  }
}