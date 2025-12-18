import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Color Constants
const Color kPrimaryColor = Color.fromARGB(255, 74, 46, 30);
const Color kFieldColor = Color(0xFFE9DFD8);
const Color kBackgroundColor = Color(0xFFF7F2EF);
const Color listTileColor = Color(0xFFad8042);
const Color secondaryTextColor = Color(0xFFBFAB67);
const Color tagsBgColor = Color(0xFFBFC882);
const Color professionColor = Color(0xFFede0d4);
const Color nameColor = Color(0xFFe6ccb2);

// Worker Dashboard Screen
class WorkerDashboard extends StatefulWidget {
  final Widget child;
  const WorkerDashboard({super.key, required this.child});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  String get location => GoRouterState.of(context).uri.toString();

  int _indexFromLocation(String location) {
    if (location.startsWith('/w-dashboard/services')) return 0;
    if (location.startsWith('/w-dashboard/history')) return 1;
    if (location.startsWith('/w-dashboard/messages')) return 2;
    if (location.startsWith('/w-dashboard/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return Scaffold(
            backgroundColor: kBackgroundColor,
            body: widget.child,
            bottomNavigationBar: _buildBottomNavigationBar(),
          );
        }

        return Scaffold(
          backgroundColor: kBackgroundColor,
          body: Row(
            children: [
              _buildNavigationRail(),
              Expanded(child: widget.child),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationRail() {
    // final location = GoRouterState.of(context).uri.toString();
    return NavigationRail(
      selectedIndex: _indexFromLocation(location),
      backgroundColor: kPrimaryColor,
      onDestinationSelected: goAtIndex,
      selectedIconTheme: IconThemeData(color: tagsBgColor),
      unselectedIconTheme: const IconThemeData(color: Colors.white),
      selectedLabelTextStyle: TextStyle(color: tagsBgColor),
      unselectedLabelTextStyle: const TextStyle(color: Colors.white),
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.work),
          label: Text('Services'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.history),
          label: Text('History'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.chat),
          label: Text('Messages'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    // final location = GoRouterState.of(context).uri.toString();
    return BottomNavigationBar(
      currentIndex: _indexFromLocation(location),
      backgroundColor: kPrimaryColor,
      onTap: goAtIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: tagsBgColor,
      unselectedItemColor: Colors.white,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Services'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  void goAtIndex(int index) {
    switch (index) {
      case 0:
        context.go('/w-dashboard/services');
        break;
      case 1:
        context.go('/w-dashboard/history');
        break;
      case 2:
        context.go('/w-dashboard/messages');
        break;
      case 3:
        context.go('/w-dashboard/profile');
        break;
    }
    setState(() {
      
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
