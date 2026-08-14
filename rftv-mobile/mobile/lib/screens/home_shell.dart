import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import 'home_tab.dart';
import 'live_tv_screen.dart';
import 'radio_screen.dart';
import 'donate_screen.dart';
import 'profile_screen.dart';

/// Hosts the 5 bottom-nav destinations (Home, Live TV, Radio, Donate, Profile)
/// under one persistent bottom bar, matching the mockup's navigation.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = [
    HomeTab(),
    LiveTvScreen(),
    RadioScreen(),
    DonateScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: RfBottomNav(currentIndex: _index, onTap: (i) => setState(() => _index = i)),
    );
  }
}
