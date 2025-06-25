import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({required this.navigationShell, super.key});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'How are you feeling?';
      case 1:
        return 'Mood History';
      case 2:
        return 'Mood Statistics';
      default:
        return 'Mood Journal';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleForIndex(navigationShell.currentIndex)),
        centerTitle: false,

        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,

        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey.shade600,
        elevation: 4,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
