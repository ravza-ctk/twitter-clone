import 'package:flutter/material.dart';
import 'twitter_search_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. ÜST KISIM (APPBAR & SEARCH & TABS)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Avatar placeholder
          ),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TwitterSearchScreen()),
            );
          },
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const TextField(
              enabled: false, 
              decoration: InputDecoration(
                hintText: "X'te ara",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                alignLabelWithHint: true,
              ),
              textAlignVertical: TextAlignVertical.center,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          indicatorColor: Colors.blue,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: "Sana Özel"),
            Tab(text: "Gündemdekiler"),
            Tab(text: "Haberler"),
            Tab(text: "Spor"),
            Tab(text: "Eğlence"),
          ],
        ),
      ),

      // 2. GÖVDE (BODY)
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Sana Özel
          _buildForYouTab(),
          // 2. Gündemdekiler
          _buildTrendsList(),
          // 3. Haberler
          _buildNewsTab(),
          // 4. Spor
          _buildSportsTab(),
          // 5. Eğlence
          _buildEntertainmentTab(),
        ],
      ),
    );
  }

  Widget _buildForYouTab() {
     return ListView(
      padding: EdgeInsets.zero,
      children: [
        /*   
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.red[900], 
          ),
          child: const Center(
            child: Text("Promosyon / Banner Alanı", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        */
        const Divider(height: 1),
        // Trend Listesi
        _buildTrendItem("Spor", "Trend Konu Başlığı 1", "20B Tweet"),
        _buildTrendItem("Türkiye tarihinde gündemde", "#TrendHashTag", "10.5B Tweet"),
        _buildTrendItem("Spor", "Futbol Oyuncusu Adı", null),
        _buildTrendItem("Müzik", "Sanatçı Adı", "50B Tweet"),

        const Divider(thickness: 8, color: Color(0xFFF5F8FA)), 

        // Kimi Takip Etmeli
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Kimi takip etmeli", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              _buildWhoToFollowItem("Kullanıcı Adı 1", "@handle1"),
              _buildWhoToFollowItem("Kurum Adı", "@kurumhandle"),
              _buildWhoToFollowItem("Kişi Adı", "@kisihandle"),
              TextButton(onPressed: (){}, child: const Text("Daha fazlasını göster"))
            ],
          ),
        ),
          
        const Divider(thickness: 8, color: Color(0xFFF5F8FA)),

        // Tweet Akışı
        _buildTweetPost(),
        const Divider(),
        _buildTweetPost(),
      ],
    );
  }

  Widget _buildTrendsList() {
    final List<TrendModel> trends = [
      TrendModel(meta: "8 • Siyaset • Gündemdekiler", title: "Demirtaş", tweetCount: "15B Tweet"),
      TrendModel(meta: "9 • İş dünyası ve finans • Gündemdekiler", title: "#enflasyon", tweetCount: "45.2B Tweet"),
      TrendModel(meta: "10 • İş dünyası ve finans • Gündemdekiler", title: "#TÜİK", tweetCount: "22B Tweet"),
      TrendModel(meta: "11 • Siyaset • Gündemdekiler", title: "Öcalan"),
      TrendModel(meta: "12 • Türkiye tarihinde gündemde", title: "Lehim"),
      TrendModel(meta: "13 • Spor • Gündemdekiler", title: "Beceriksizler"),
      TrendModel(meta: "14 • Spor • Gündemdekiler", title: "Nhaga"),
      TrendModel(meta: "15 • Spor • Gündemdekiler", title: "Recep Durul"),
      TrendModel(meta: "16 • Spor • Gündemdekiler", title: "Araplar"),
      TrendModel(meta: "17 • Spor • Gündemdekiler", title: "Önce Lookman"),
      TrendModel(meta: "18 • Türkiye tarihinde gündemde", title: "Ahmet Türk"),
      TrendModel(meta: "19 • Türkiye tarihinde gündemde", title: "#Epstien"),
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: trends.length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.transparent),
      itemBuilder: (context, index) {
        return TrendItemTile(trend: trends[index]);
      },
    );
  }

  Widget _buildNewsTab() {
     final List<Map<String, String>> newsData = [
      {'category': 'Siyaset', 'title': 'Aile'},
      {'category': 'Siyaset', 'title': 'LGBT'},
      {'category': 'Teknoloji', 'title': 'Grok'},
      {'category': 'Siyaset', 'title': '#ÇözümKademede'},
      {'category': 'Siyaset', 'title': 'Gülben Ergen'},
    ];

    return ListView.builder(
      itemCount: newsData.length,
      itemBuilder: (context, index) {
        return _buildGenericTrendItem(
          category: newsData[index]['category']!,
          title: newsData[index]['title']!,
        );
      },
    );
  }

  Widget _buildSportsTab() {
    final List<Map<String, String>> sportsData = [
      {'category': 'Spor', 'title': 'Lemina'},
      {'category': 'Spor', 'title': 'Oulai'},
      {'category': 'Spor', 'title': 'Nhaga'},
      {'category': 'Spor', 'title': 'Olaitan'},
      {'category': 'Spor', 'title': 'Kocaelispor'},
      {'category': 'Spor', 'title': 'Nesyri'},
      {'category': 'Spor', 'title': 'Sercan'},
      {'category': 'Spor', 'title': 'Hayırlı'},
      {'category': 'Spor', 'title': 'Anadolu'},
      {'category': 'Spor', 'title': 'Forvet'},
      {'category': 'Spor', 'title': 'Ugarte'},
      {'category': 'Spor', 'title': 'Ronaldo'},
    ];

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: sportsData.length,
      itemBuilder: (context, index) {
        return _buildGenericTrendItem(
          category: sportsData[index]['category']!,
          title: sportsData[index]['title']!,
        );
      },
    );
  }

  Widget _buildEntertainmentTab() {
    return const Padding(
      padding: EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Burada görecek bir şey yok.\nHenüz...",
            style: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTrendItem(String category, String title, String? subInfo) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$category · Gündemdekiler', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const Icon(Icons.more_horiz, color: Colors.grey, size: 18),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
          if (subInfo != null) ...[
             const SizedBox(height: 2),
             Text(subInfo, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ]
        ],
      ),
      onTap: () {},
    );
  }

  // Generic Trend Item for News/Sports (User's TrendItem adaptation)
  Widget _buildGenericTrendItem({required String category, required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$category · Gündemdekiler',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(
            Icons.more_vert,
            color: Colors.grey[500],
            size: 18,
          ),
        ],
      ),
    );
  }

 
  Widget _buildWhoToFollowItem(String name, String handle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const CircleAvatar(radius: 20, backgroundColor: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: Colors.blue, size: 16) // Mavi tik
                  ],
                ),
                Text(handle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            ),
            child: const Text("Takip et", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }


  Widget _buildTweetPost() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://via.placeholder.com/150')),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black),
                          children: [
                            const TextSpan(text: "Kullanıcı Adı ", style: TextStyle(fontWeight: FontWeight.bold)),
                            const WidgetSpan(child: Icon(Icons.verified, size: 14, color: Colors.blue)), // Opsiyonel mavi tik
                            TextSpan(text: " @handle · 2s", style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.more_horiz, color: Colors.grey, size: 18),
                  ],
                ),
                const SizedBox(height: 4),

                const Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200)
                  ),
                  child: const Center(child: Icon(Icons.image, color: Colors.grey, size: 50)),
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey),
                    Icon(Icons.repeat, size: 18, color: Colors.grey),
                    Icon(Icons.favorite_border, size: 18, color: Colors.grey),
                    Icon(Icons.bar_chart, size: 18, color: Colors.grey),
                    Icon(Icons.share, size: 18, color: Colors.grey),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class TrendModel {
  final String meta; // Üstteki gri yazı (Örn: 9 • Siyaset...)
  final String title; // Kalın başlık
  final String? tweetCount; // Varsa tweet sayısı

  TrendModel({required this.meta, required this.title, this.tweetCount});
}

class TrendItemTile extends StatelessWidget {
  final TrendModel trend;

  const TrendItemTile({super.key, required this.trend});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sol Taraf: Metinler
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Text(
                    trend.meta,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2), // Başlık ile üst yazı arası boşluk
                  // Ana Başlık
                  Text(
                    trend.title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Varsa Tweet Sayısı (Görselde yok ama genelde olur, opsiyonel ekledim)
                  if (trend.tweetCount != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      trend.tweetCount!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Sağ Taraf: Üç Nokta İkonu
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                Icons.more_vert,
                color: Colors.grey[500],
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
