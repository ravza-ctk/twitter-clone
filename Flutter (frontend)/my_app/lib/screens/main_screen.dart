import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'notification_screen.dart';
import 'messages_screen.dart';
import 'compose_tweet_screen.dart';
import '../services/tweet_service.dart';
import '../models/tweet_model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SearchScreen(),
    Center(child: Text('Grok Screen')), // Placeholder for Grok/Slash
    NotificationScreen(),
    MessagesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar removed as it is now part of HomeScreen (SliverAppBar)
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: _selectedIndex == 4
          ? null
          : FloatingActionButton(
                onPressed: () async {
                final newTweet = await Navigator.push<Tweet?>(
                  context,
                  MaterialPageRoute(builder: (context) => const ComposeTweetScreen()),
                );

                if (newTweet != null) {
                  TweetService().addTweet(newTweet);
                }
              },
              shape: const CircleBorder(),
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 0 ? Icons.home : Icons.home_outlined),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '',
          ),
           const BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outline_blank), // Placeholder for Slash/Grok
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 3 ? Icons.notifications : Icons.notifications_none),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 4 ? Icons.mail : Icons.mail_outline),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
