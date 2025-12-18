import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';

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
class Dashboard extends StatefulWidget {
  final Widget child;
  const Dashboard({super.key, required this.child});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final UserHandler _userHandler = UserHandler();

  late final Future<bool> _isWorkerFuture;

  String get location => GoRouterState.of(context).uri.toString();

  @override
  void initState() {
    super.initState();
    _isWorkerFuture = _loadIsWorker();
  }

  Future<bool> _loadIsWorker() async {
    final role = await _userHandler.getValue('role');
    return role == 'worker';
  }

  int _indexFromLocation(String location, bool isWorker) {
    if (isWorker) {
      if (location.startsWith('/w-dashboard/services')) return 0;
      if (location.startsWith('/w-dashboard/history')) return 1;
      if (location.startsWith('/messages')) return 2;
      if (location.startsWith('/profile')) return 3;
    } else {
      if (location.startsWith('/c-dashboard/home')) return 0;
      if (location.startsWith('/c-dashboard/bookings')) return 1;
      if (location.startsWith('/messages')) return 2;
      if (location.startsWith('/profile')) return 3;
    }
    return 0;
  }

  void goAtIndex(int index, bool isWorker) {
    final urls = isWorker
        ? [
            '/w-dashboard/services',
            '/w-dashboard/history',
            '/messages',
            '/profile',
          ]
        : [
            '/c-dashboard/home',
            '/c-dashboard/bookings',
            '/messages',
            '/profile',
          ];

    context.go(urls[index]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isWorkerFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isWorker = snapshot.data!;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            if (isMobile) {
              return Scaffold(
                backgroundColor: kBackgroundColor,
                body: widget.child,
                bottomNavigationBar: _buildBottomNavigationBar(isWorker),
              );
            }

            return Scaffold(
              backgroundColor: kBackgroundColor,
              body: Row(
                children: [
                  _buildNavigationRail(isWorker),
                  Expanded(child: widget.child),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNavigationRail(bool isWorker) {
    final labels = _labels(isWorker);

    return NavigationRail(
      selectedIndex: _indexFromLocation(location, isWorker),
      backgroundColor: kPrimaryColor,
      onDestinationSelected: (i) => goAtIndex(i, isWorker),
      selectedIconTheme: IconThemeData(color: tagsBgColor),
      unselectedIconTheme: const IconThemeData(color: Colors.white),
      selectedLabelTextStyle: TextStyle(color: tagsBgColor),
      unselectedLabelTextStyle: const TextStyle(color: Colors.white),
      labelType: NavigationRailLabelType.all,
      destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.work, color: Colors.white,),
          label: Text(labels[0]),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.history, color: Colors.white,),
          label: Text(labels[1]),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.chat, color: Colors.white,),
          label: Text(labels[2]),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person, color: Colors.white,),
          label: Text(labels[3]),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(bool isWorker) {
    final labels = _labels(isWorker);

    return BottomNavigationBar(
      currentIndex: _indexFromLocation(location, isWorker),
      backgroundColor: kPrimaryColor,
      onTap: (i) => goAtIndex(i, isWorker),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: tagsBgColor,
      unselectedItemColor: Colors.white,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.work, color: Colors.white,), label: labels[0]),
        BottomNavigationBarItem(icon: Icon(Icons.history, color: Colors.white,), label: labels[1]),
        BottomNavigationBarItem(icon: Icon(Icons.chat, color: Colors.white,), label: labels[2]),
        BottomNavigationBarItem(icon: Icon(Icons.person, color: Colors.white,), label: labels[3]),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<String> _labels(bool isWorker) => [
    isWorker ? 'Services' : 'Home',
    isWorker ? 'History' : 'Bookings',
    'Messages',
    'Profile',
  ];
}
