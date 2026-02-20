import 'package:flutter/material.dart';
import '../models/tweet_model.dart';
import '../models/user_model.dart';
import '../services/search_service.dart';
import '../widgets/tweet_card.dart';
import 'person_detail_screen.dart';
import 'tweet_detail_screen.dart';

class SearchResultScreen extends StatefulWidget {
  final String searchQuery;

  const SearchResultScreen({super.key, required this.searchQuery});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}



class _SearchResultScreenState extends State<SearchResultScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  
  List<Tweet> _tweets = [];
  List<User> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    _searchController.text = widget.searchQuery;
    _performSearch();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _performSearch();
    }
  }

  Future<void> _performSearch() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _tweets = [];
      _users = [];
    });

    try {
      if (_tabController.index == 3) { // Kişiler
        final users = await _searchService.searchUsers(_searchController.text);
        setState(() {
          _users = users;
        });
      } else { // Diğerleri (Tweetler)
        // 0: Popüler, 1: Medya, 2: En Son, 4: Listeler
        // Backend şu an sadece genel arama ve kategori destekliyor.
        // Hepsine tweet araması yapalım şimdilik.
        final tweets = await _searchService.searchTweets(_searchController.text);
        setState(() {
          _tweets = tweets;
        });
      }
    } catch (e) {
      debugPrint("Arama hatası: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              filled: true,
              fillColor: const Color(0xFFEFF3F4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              hintText: 'Twitter\'da Ara',
              hintStyle: TextStyle(color: Colors.grey.shade600),
              suffixIcon: IconButton(
                icon: const Icon(Icons.cancel, size: 20, color: Colors.black),
                onPressed: () {
                    _searchController.clear();
                    setState(() {
                        _tweets = [];
                        _users = [];
                    });
                },
              ),
            ),
            style: const TextStyle(color: Colors.black),
            onSubmitted: (value) => _performSearch(),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Popüler"),
            Tab(text: "Medya"),
            Tab(text: "En Son"),
            Tab(text: "Kişiler"),
            Tab(text: "Listeler"),
          ],
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
            controller: _tabController,
            children: [
              _buildTweetList(), // Popüler
              _buildTweetList(), // Medya
              _buildTweetList(), // En Son
              _buildUserList(),  // Kişiler
              const Center(child: Text("Liste bulunamadı")), // Listeler
            ],
          ),
    );
  }

  Widget _buildTweetList() {
    if (_tweets.isEmpty) {
      return const Center(child: Text("Tweet bulunamadı"));
    }
    return ListView.builder(
      itemCount: _tweets.length,
      itemBuilder: (context, index) {
        final tweet = _tweets[index];
        return TweetCard(
          tweet: tweet,
          onTap: () {
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TweetDetailScreen(tweet: tweet)),
            );
          },
          onLikePressed: () {}, // Implement later
          onCommentPressed: (t) {},
          onQuoteRetweet: (t) {},
        );
      },
    );
  }

  Widget _buildUserList() {
    if (_users.isEmpty) {
      return const Center(child: Text("Kullanıcı bulunamadı"));
    }
    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null ? const Icon(Icons.person) : null,
          ),
          title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("@${user.username}"),
          onTap: () {
             Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PersonDetailScreen(
                  name: user.name,
                  username: user.username,
                  avatarUrl: user.avatarUrl,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
