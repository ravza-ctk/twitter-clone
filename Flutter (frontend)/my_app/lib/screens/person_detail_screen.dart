import 'package:flutter/material.dart';

class PersonDetailScreen extends StatefulWidget {
  final String name;
  final String username;
  final String? avatarUrl;

  const PersonDetailScreen({
    super.key,
    required this.name,
    required this.username,
    this.avatarUrl,
  });

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  final List<String> _tabs = [
    "Gönderiler",
    "Yanıtlar",
    "Medya",
    "Beğeniler"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          children: const [
            Center(child: Text("Gönderiler")),
            Center(child: Text("Yanıtlar")),
            Center(child: Text("Medya")),
            Center(child: Text("Beğeniler")),
          ],
        ),
      ),
    );
  }

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
    );
  }

  Widget _buildProfileInfo() {
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
                  backgroundImage: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty ? NetworkImage(widget.avatarUrl!) : null,
                  child: (widget.avatarUrl == null || widget.avatarUrl!.isEmpty) ? const Icon(Icons.person, size: 40) : null,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: OutlinedButton(
                     onPressed: () {},
                     style: OutlinedButton.styleFrom(
                       side: const BorderSide(color: Colors.black),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                       backgroundColor: Colors.black,
                       foregroundColor: Colors.white,
                     ),
                     child: const Text("Takip et", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black)),
            Text(widget.username, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 12),
            const Row(children: [Icon(Icons.calendar_month_outlined, size: 16, color: Colors.grey), SizedBox(width: 4), Text("Katıldı: Ocak 2026", style: TextStyle(color: Colors.grey, fontSize: 14))]),
            const SizedBox(height: 12),
            Row(children: [
              _buildFollowCount("120", "Takip edilen"),
              const SizedBox(width: 16),
              _buildFollowCount("45", "Takipçi"),
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
