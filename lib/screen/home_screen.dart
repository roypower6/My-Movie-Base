import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:my_movie_base/screen/favorites_screen.dart';
import 'package:my_movie_base/screen/movie_list_screen.dart';
import 'package:my_movie_base/screen/search_screen.dart';
import 'package:my_movie_base/screen/setting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<GButton> tabs = [
    const GButton(
      icon: Icons.movie_outlined,
      text: '영화',
      iconActiveColor: Colors.blue,
      textColor: Colors.blue,
      iconColor: Colors.grey,
    ),
    const GButton(
      icon: Icons.favorite_outline,
      text: '관심 목록',
      iconActiveColor: Colors.red,
      textColor: Colors.red,
      iconColor: Colors.grey,
    ),
    const GButton(
      icon: Icons.search_rounded,
      text: '영화 검색',
      iconActiveColor: Colors.green,
      textColor: Colors.green,
      iconColor: Colors.grey,
    ),
    const GButton(
      icon: Icons.settings,
      text: '앱 정보',
      iconActiveColor: Colors.orange,
      textColor: Colors.orange,
      iconColor: Colors.grey,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          MovieListScreen(),
          FavoritesScreen(),
          SearchScreen(),
          SettingScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: GNav(
              tabs: tabs,
              selectedIndex: _currentIndex,
              onTabChange: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              gap: 8,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[850]!,
              activeColor: Colors.white,
              curve: Curves.fastOutSlowIn,
              tabBorderRadius: 16,
            ),
          ),
        ),
      ),
    );
  }
}
