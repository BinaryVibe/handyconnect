import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

// --- Screen Imports ---
import 'screens/homepage.dart';
import 'screens/login.dart';
import 'screens/signup.dart';
import 'screens/role_selection.dart';
import 'screens/customer_dashboard.dart';
import 'screens/worker_dashboard.dart';
import 'screens/worker_details.dart';

// 🛑 THIS WAS MISSING: Import the new Booking Screen
import 'screens/book_service_screen.dart'; 

// --- Model Imports ---
import 'models/worker.dart';

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
    
    // --- Worker Details & Booking Route ---
    GoRoute(
      path: '/c-dashboard/w-details',
      builder: (context, state) {
        // We expect a 'Worker' object to be passed in 'extra'
        Worker worker = state.extra as Worker;
        return WorkerDetailScreen(worker: worker);
      },
      routes: [
        // This is the sub-route for booking
        GoRoute(
          path: 'book-service', 
          builder: (context, state) {
            Worker worker = state.extra as Worker;
            return BookServiceScreen(worker: worker);
          },
        ),
      ],
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
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