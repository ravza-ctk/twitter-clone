import 'package:flutter/material.dart';
import '../models/tweet_model.dart';
import '../services/tweet_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../widgets/tweet_card.dart';
import 'compose_tweet_screen.dart';
import 'tweet_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final UserService _userService = UserService();
  User? _user;
  bool _isLoadingUser = true;

  // Sekme Başlıkları
  final List<String> _tabs = [
    "Gönderiler",
    "Yanıtlar",
    "Öne Çıkanlar",
    "Makaleler",
    "Medya",
    "Beğeniler"
  ];

  List<Tweet> _userTweets = [];
  bool _isLoadingTweets = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _fetchUserData();
  }

  
  Future<void> _fetchUserData() async {
    try {
      // 1. Kullanıcıyı çek
      final user = await _userService.getMyProfile();
      
      List<Tweet> tweets = [];
      
      // 2. Kullanıcı geldiyse tweetleri çek
      if (user != null && user.username.isNotEmpty) {
        try {
          tweets = await TweetService().fetchUserTweets(user.username);
        } catch (e) {
          debugPrint("Tweetler çekilirken hata: $e");
          // Hata olsa bile tweets [] olarak kalır, uygulama çökmez
        }
      }

      if (mounted) {
        setState(() {
          _user = user;
          _isLoadingUser = false;
          _userTweets = tweets;
          _isLoadingTweets = false;
        });
      }
    } catch (e) {
      debugPrint("Profil yükleme genel hatası: $e");
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
          _isLoadingTweets = false;
        });
      }
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTweet = await Navigator.push<Tweet?>(
            context,
            MaterialPageRoute(builder: (context) => const ComposeTweetScreen()),
          );

          if (newTweet != null) {
            TweetService().addTweet(newTweet);
            setState(() {
              _userTweets.insert(0, newTweet);
            });
          }
        },
        backgroundColor: const Color(0xFF1D9BF0),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            _buildAppBar(context),
            _buildProfileInfo(),
            _buildPersistentTabBar(),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // 1. Gönderiler
            Builder(
              builder: (context) {
                if (_isLoadingTweets) {
                    return const Center(child: CircularProgressIndicator());
                }

                if (_userTweets.isEmpty) {
                  return const Center(child: Text("Henüz gönderi yok"));
                }

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _userTweets.length,
                  itemBuilder: (context, index) {
                    final tweet = _userTweets[index];
                    return TweetCard(
                      tweet: tweet,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TweetDetailScreen(tweet: tweet)),
                        ).then((_) => setState(() {}));
                      },
                      onCommentPressed: (tweet) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TweetDetailScreen(tweet: tweet)),
                        ).then((_) => setState(() {}));
                      },
                      onQuoteRetweet: (t) async {
                        if (t.isRetweeted) {
                           await TweetService().toggleRetweet(t.id!);
                        } else {
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
                                      final newTweet = await Navigator.push<Tweet?>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ComposeTweetScreen(quotedTweet: t),
                                        ),
                                      );

                                      if (newTweet != null) {
                                         TweetService().addTweet(newTweet);
                                         setState(() {
                                            _userTweets.insert(0, newTweet);
                                         });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                        }
                      },
                      onLikePressed: () {
                         TweetService().toggleLike(tweet.id ?? 0);
                      },
                    );
                  },
                );
              },
            ),
            
            // 2. Yanıtlar (Lorem Ipsum İçerik)
            _buildRepliesTab(),
            
            // 3. Öne Çıkanlar (Promo)
            _buildPromoTab(
              title: "Yalnızca onaylı kullanıcılar için",
              description: "Profilinde gönderileri öne çıkarmak için Onaylı olman gerekir.",
              buttonText: "Onaylanmış hesap sahibi ol",
            ),

            // 4. Makaleler (Promo)
            _buildPromoTab(
              title: "X'te Makale yaz",
              description: "x.com'da Makale yayınladığında Makale burada gösterilir. Yalnızca Premium aboneleri Makale yayınlayabilir.",
              buttonText: "Premium'a abone ol",
            ),

            // 5. Medya (Lorem Ipsum Video Görünümü)
            _buildMediaTab(),

            // 6. Beğeniler (Lorem Ipsum İçerik)
            _buildLikesTab(),
          ],
        ),
      ),
    );
  }

  // --- TAB İÇERİKLERİ (Lorem Ipsum) ---

  // Yanıtlar Sekmesi
  Widget _buildRepliesTab() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildTweetItem(
          avatarUrl: "https://picsum.photos/id/64/150", // Rastgele portre
          name: "Lorem User",
          handle: "@loremipsum",
          time: "21 sa",
          text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
          isReply: true,
          quotedContent: Container(
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(
               border: Border.all(color: Colors.grey.shade300),
               borderRadius: BorderRadius.circular(12),
             ),
             child: const Row(
               children: [
                 CircleAvatar(radius: 10, backgroundImage: NetworkImage("https://picsum.photos/id/65/150")),
                 SizedBox(width: 5),
                 Expanded(
                   child: Text(
                     "Ut enim ad minim veniam, quis nostrud exercitation? 😂", 
                     style: TextStyle(fontWeight: FontWeight.w500),
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
               ],
             ),
          ),
          stats: _TweetStats(reply: "42", retweet: "1.2B", like: "5.6B", view: "100B"),
        ),
        const Divider(height: 1),
        _buildTweetItem(
          avatarUrl: "https://picsum.photos/id/66/150",
          name: "Dolor Sit",
          handle: "@dolorsit",
          time: "1 gün",
          text: "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident.",
          isReply: true,
          quotedContent: Container(
             margin: const EdgeInsets.only(top: 8),
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(
               border: Border.all(color: Colors.grey.shade300),
               borderRadius: BorderRadius.circular(12),
             ),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const Row(children: [
                   CircleAvatar(radius: 10, backgroundImage: NetworkImage("https://picsum.photos/id/67/150")),
                   SizedBox(width: 5),
                   Text("Amet Consectetur @amet · 05 Oca", style: TextStyle(color: Colors.grey, fontSize: 13)),
                 ]),
                 const SizedBox(height: 4),
                 const Text("Sunt in culpa qui officia deserunt mollit anim id est laborum."),
                 const SizedBox(height: 8),
                 ClipRRect(
                   borderRadius: BorderRadius.circular(8),
                   child: Image.network("https://picsum.photos/id/28/800/400", height: 150, width: double.infinity, fit: BoxFit.cover),
                 )
               ],
             ),
          ),
          stats: null,
        ),
      ],
    );
  }

  // Medya Sekmesi
  Widget _buildMediaTab() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildTweetItem(
          avatarUrl: "https://pbs.twimg.com/profile_images/1683325380441128960/yRsRRjGO_400x400.jpg",
          name: "my_username",
          handle: "@user64095",
          time: "29 Eki 25",
          text: "Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit. 🇹🇷",
          customContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("youtu.be/lorem-ipsum?si...", style: TextStyle(color: Colors.blue)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black,
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            "https://picsum.photos/id/16/800/450", // Manzara resmi
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                          child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Lorem Ipsum Dolor Sit Amet Video Başlığı", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text("YouTube", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          stats: _TweetStats(reply: "10", retweet: "5", like: "100", view: "1B"),
        ),
      ],
    );
  }

  // Beğeniler Sekmesi
  Widget _buildLikesTab() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
         _buildTweetItem(
          avatarUrl: "https://picsum.photos/id/40/150",
          name: "Ipsum User 🕯️",
          handle: "@ipsumuser",
          time: "21 sa",
          text: "Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore.\n#LoremIpsum #DolorSit #Amet",
          quotedContent: Container(
             margin: const EdgeInsets.only(top: 8),
             decoration: BoxDecoration(
               border: Border.all(color: Colors.grey.shade300),
               borderRadius: BorderRadius.circular(12),
             ),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const Padding(
                   padding: EdgeInsets.all(8.0),
                   child: Row(children: [
                     CircleAvatar(radius: 10, backgroundImage: NetworkImage("https://picsum.photos/id/41/150")),
                     SizedBox(width: 5),
                     Text("Quis Nostrud ౨ৎ", style: TextStyle(fontWeight: FontWeight.bold)),
                     SizedBox(width: 4),
                     Icon(Icons.verified, size: 14, color: Colors.blue),
                     Text(" @quisnostrud · 05 Oca", style: TextStyle(color: Colors.grey, fontSize: 13)),
                   ]),
                 ),
                 const Padding(
                   padding: EdgeInsets.symmetric(horizontal: 8.0),
                   child: Text("At vero eos et accusamus et iusto odio dignissimos ducimus."),
                 ),
                 const SizedBox(height: 8),
                 ClipRRect(
                   borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                   child: Image.network("https://picsum.photos/id/50/800/400", height: 200, width: double.infinity, fit: BoxFit.cover),
                 )
               ],
             ),
          ),
          stats: _TweetStats(reply: "200B", retweet: "50B", like: "300B", view: "1T"),
        ),
      ],
    );
  }

  // Boş Promo Sekmeleri
  Widget _buildPromoTab({required String title, required String description, required String buttonText}) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black)),
          const SizedBox(height: 12),
          Text(description, style: const TextStyle(fontSize: 15, color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: Text(buttonText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
    );
  }

  // --- YARDIMCI WIDGETLAR ---

  Widget _buildTweetItem({
    required String avatarUrl,
    required String name,
    required String handle,
    required String time,
    required String text,
    bool isReply = false,
    Widget? quotedContent,
    Widget? customContent,
    _TweetStats? stats,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundImage: NetworkImage(avatarUrl), radius: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isReply) 
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Row(children: [
                      Icon(Icons.repeat, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text("Yeniden gönderi yayınladın", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                Row(
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, size: 16, color: Colors.blue), // Herkese mavi tik verdik görsel zenginlik için
                    Text(" $handle · $time", style: const TextStyle(color: Colors.grey)),
                    const Spacer(),
                    const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 4),
                Text(text, style: const TextStyle(fontSize: 15, color: Colors.black)),
                if (customContent != null) ...[
                  const SizedBox(height: 10),
                  customContent,
                ],
                if (quotedContent != null) ...[
                  const SizedBox(height: 10),
                  quotedContent,
                ],
                if (stats != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _iconStat(Icons.chat_bubble_outline, stats.reply),
                      _iconStat(Icons.repeat, stats.retweet),
                      _iconStat(Icons.favorite_border, stats.like),
                      _iconStat(Icons.bar_chart, stats.view),
                      const Icon(Icons.share, size: 18, color: Colors.grey),
                    ],
                  )
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _iconStat(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 4),
        if (count.isNotEmpty) Text(count, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  // --- HEADER WIDGETLARI (DEĞİŞMEDİ) ---
  
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140.0,
      pinned: true,
      backgroundColor: const Color(0xFF1D9BF0),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(background: Container(color: const Color(0xFF1D9BF0))),
      actions: [
        _buildTopIcon(Icons.search),
        _buildTopIcon(Icons.more_vert),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTopIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildProfileInfo() {
    if (_isLoadingUser) {
        return const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())));
    }
    
    if (_user == null) {
         return const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text("Kullanıcı yüklenemedi"))));
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 CircleAvatar(
                  radius: 38,
                  backgroundColor: Colors.grey,
                  backgroundImage: _user!.avatarUrl != null ? NetworkImage(_user!.avatarUrl!) : null,
                  child: _user!.avatarUrl == null ? const Icon(Icons.person, size: 40) : null,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: OutlinedButton(
                     onPressed: _showEditProfileDialog,
                     style: OutlinedButton.styleFrom(
                       side: const BorderSide(color: Colors.grey),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                     ),
                     child: const Text("Profili düzenle", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
             Row(children: [
              Text(_user!.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black)),
              const SizedBox(width: 4),
              const Icon(Icons.verified, color: Colors.blue, size: 20),
            ]),
            Text("@${_user!.username}", style: const TextStyle(fontSize: 16, color: Colors.grey)),
            if (_user!.bio != null && _user!.bio!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(_user!.bio!, style: const TextStyle(fontSize: 15, color: Colors.black)),
            ],
            if (_user!.location != null && _user!.location!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(children: [const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey), const SizedBox(width: 4), Text(_user!.location!, style: const TextStyle(color: Colors.grey, fontSize: 14))]),
            ],
            if (_user!.website != null && _user!.website!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(children: [const Icon(Icons.link, size: 16, color: Colors.grey), const SizedBox(width: 4), Text(_user!.website!, style: const TextStyle(color: Colors.blue, fontSize: 14))]),
            ],
            const SizedBox(height: 12),
            const Text("Onaylanmış Hesap Sahibi Ol", style: TextStyle(color: Color(0xFF1D9BF0), fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            if (_user!.joinDate != null)
                Row(children: [const Icon(Icons.calendar_month_outlined, size: 16, color: Colors.grey), const SizedBox(width: 4), Text("Katıldı: ${_user!.joinDate}", style: const TextStyle(color: Colors.grey, fontSize: 14))]),
            const SizedBox(height: 12),
            Row(children: [
              _buildFollowCount(_user!.followingCount.toString(), "Takip edilen"),
              const SizedBox(width: 16),
              _buildFollowCount(_user!.followersCount.toString(), "Takipçi"),
            ]),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildPersistentTabBar() {
    return SliverPersistentHeader(
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFF1D9BF0),
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: Colors.black,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          unselectedLabelColor: Colors.grey,
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((String name) => Tab(text: name)).toList(),
        ),
      ),
      pinned: true,
    );
  }

  Widget _buildFollowCount(String count, String label) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 15),
        children: [TextSpan(text: "$count ", style: const TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: label, style: const TextStyle(color: Colors.grey))],
      ),
    );
  }
  void _showEditProfileDialog() {
    if (_user == null) return;

    final nameController = TextEditingController(text: _user!.name);
    final bioController = TextEditingController(text: _user!.bio);
    final locationController = TextEditingController(text: _user!.location);
    final websiteController = TextEditingController(text: _user!.website);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal", style: TextStyle(color: Colors.black))),
                const Text("Profili Düzenle", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(
                  onPressed: () async {
                    final success = await _userService.updateProfile(
                      _user!.id!,
                      nameController.text,
                      bioController.text,
                      locationController.text,
                      websiteController.text,
                    );
                    if (!context.mounted) return;
                    
                    Navigator.pop(context);
                    if (success) {
                      _fetchUserData(); // Refresh data
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Güncelleme başarısız")));
                    }
                  },
                  child: const Text("Kaydet", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "İsim"),
            ),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: "Biyografi"),
              maxLines: 3,
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: "Konum"),
            ),
            TextField(
              controller: websiteController,
              decoration: const InputDecoration(labelText: "Web Sitesi"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: _tabBar);
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

class _TweetStats {
  final String reply, retweet, like, view;
  _TweetStats({required this.reply, required this.retweet, required this.like, required this.view});
}