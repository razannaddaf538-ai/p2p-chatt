import 'package:flutter/material.dart';
import 'peers_screen.dart';
import 'app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> pages = [
    PeersScreen(),
    const Center(child: Text('المجموعات')),
    const Center(child: Text('الملفات')),
    const Center(child: Text('حسابي')),
  ];

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: changePage,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'الأقران',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'المجموعات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'الملفات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
