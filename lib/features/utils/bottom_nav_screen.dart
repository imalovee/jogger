import 'package:flutter/material.dart';
import 'package:jogging_app/features/screans/profle_screen.dart';
import 'package:jogging_app/shared/app_colors.dart';


import '../screans/home_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {


    var screens = [
       HomeScreen(),
      ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
          onTap: (int index){
            setState(() {
              selectedIndex = index;
            });
          },
          currentIndex: selectedIndex,
          selectedItemColor: AppColors.appColor,
          unselectedItemColor: Colors.grey,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list, ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, ),
              label: 'Profile',
            ),
          ]),
    );
  }
}