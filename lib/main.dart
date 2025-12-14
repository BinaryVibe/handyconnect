import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

// For testing
import 'signup.dart';
import 'worker_dashboard.dart';
import 'customer_dashboard.dart';
import 'login.dart';
import 'homepage.dart';

const Color kPrimaryColor = Color.fromARGB(255, 74, 46, 30);

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen(),),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen(),),
    GoRoute(path: '/customer-dashboard', builder: (context, state) => const CustomerDashboard(),),
    GoRoute(path: '/worker-dashboard', builder: (context, state) => const WorkerDashboard(),),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://afgvpnvqxzmosfogcysc.supabase.co',
    anonKey: 'sb_publishable_bLKZ8iWn8-BenfJLuq0TaA_ZVgzUItK',
  );
  runApp(const HandyConnect());
}

class HandyConnect extends StatelessWidget {
  const HandyConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      theme: ThemeData(primaryColor: kPrimaryColor),
      debugShowCheckedModeBanner: false,
      title: 'HandyConnect',
    );
  }
}
