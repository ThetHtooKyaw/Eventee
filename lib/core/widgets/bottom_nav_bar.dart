import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eventee/core/themes/app_color.dart';
import 'package:flutter/material.dart';
import 'package:eventee/src/account/views/account_view.dart';
import 'package:eventee/src/home/views/home_view.dart';
import 'package:eventee/src/booking/views/booking_history_view.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int selectedIndex = 0;
  late List<Widget> _pages;
  late HomeView home;
  late BookingHistoryView booking;
  late AccountView account;

  @override
  void initState() {
    super.initState();
    home = HomeView();
    booking = BookingHistoryView();
    account = AccountView();
    _pages = [home, booking, account];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.black,
        animationDuration: Duration(milliseconds: 500),

        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        items: const [
          Icon(Icons.home, color: AppColor.white, size: 30),
          Icon(Icons.book, color: AppColor.white, size: 30),
          Icon(Icons.person, color: AppColor.white, size: 30),
        ],
      ),
    );
  }
}
