import 'package:flutter/material.dart';
import 'peersScreen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  final List<Widget> pages = [
    PeersScreen(),
    Scaffold(body: Center(child: Text("المجموعات"))),
    Scaffold(body: Center(child: Text("الملفات"))),
    Scaffold(body: Center(child: Text("حسابي"))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFFF8A8C8),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "الأقران"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "المجموعات"),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: "الملفات"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "حسابي"),
        ],
      ),
    );
  }
}

