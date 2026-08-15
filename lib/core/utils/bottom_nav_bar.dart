import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eventee/src/account/view_models/account_view_model.dart';
import 'package:eventee/src/event/repo/create_event_service.dart';
import 'package:eventee/src/event/view_models/create_event_view_model.dart';
import 'package:eventee/src/event/views/create_event_view.dart';
import 'package:eventee/src/favourite/views/favourite_view.dart';
import 'package:flutter/material.dart';
import 'package:eventee/src/account/views/account_view.dart';
import 'package:eventee/src/home/views/home_view.dart';
import 'package:eventee/src/event/views/booked_event_history_view.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int selectedIndex = 0;
  final List<Widget> _pages = const [
    HomeView(),
    BookedEventHistoryView(),
    SizedBox.shrink(),
    FavouriteView(),
    AccountView(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<AccountViewModel>().loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[selectedIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (naviContext) =>
                  ChangeNotifierProvider<CreateEventViewModel>(
                    create: (context) => CreateEventViewModel(
                      context.read<CreateEventService>(),
                    ),
                    child: const CreateEventView(),
                  ),
            ),
          );
        },
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.black,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          if (index == 2) return;

          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          Icon(Icons.home, color: Colors.white, size: 30),
          Icon(Icons.book, color: Colors.white, size: 30),
          Icon(
            Icons.add,
            color: Colors.transparent,
            size: 30,
          ), // Transparent icon placeholder
          Icon(Icons.bookmark, color: Colors.white, size: 30),
          Icon(Icons.person, color: Colors.white, size: 30),
        ],
      ),
    );
  }
}
