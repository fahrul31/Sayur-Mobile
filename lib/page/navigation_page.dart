import 'package:flutter/material.dart';
import 'package:green_finance/page/components/custom_button_nav.dart';
import 'package:green_finance/page/screens/home_screen.dart';
import 'package:green_finance/page/screens/input/input_screen.dart';
import 'package:green_finance/page/screens/account_screen.dart';
import 'package:green_finance/page/screens/recap/recap_screen.dart';
import 'package:green_finance/page/screens/report/report_screen.dart';

class NavigationPage extends StatefulWidget {
  static const routeName = '/navigation_page';

  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _bottomNavIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    InputScreen(),
    ReportScreen(),
    RecapScreen(),
    AccountScreen(),
  ];

  void _onBottomNavTapped(int index) {
    setState(() => _bottomNavIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _bottomNavIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }
}
