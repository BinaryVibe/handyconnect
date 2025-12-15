import 'package:flutter/material.dart';
import 'package:handyconnect/role_selection.dart';
import 'package:handyconnect/worker_details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

// For testing
import 'signup.dart';
import 'src/models/worker.dart';
import 'worker_dashboard.dart';
import 'customer_dashboard.dart';
import 'login.dart';
import 'homepage.dart';

const Color kPrimaryColor = Color.fromARGB(255, 74, 46, 30);

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
    GoRoute(
      path: '/signup/select-role',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/c-dashboard',
      builder: (context, state) => const CustomerDashboard(),
    ),
    GoRoute(
      path: '/w-dashboard',
      builder: (context, state) => const WorkerDashboard(),
    ),
    GoRoute(
      path: '/c-dashboard/w-details',
      builder: (context, state) {
        Worker worker = state.extra as Worker;
        return WorkerDetailScreen(worker: worker);
      },
    ),
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
