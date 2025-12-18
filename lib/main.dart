import 'package:flutter/material.dart';
import 'package:handyconnect/screens/profile_screen.dart';
import 'package:handyconnect/screens/worker_services_page.dart';
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
import 'screens/book_service_screen.dart';

// --- NEW IMPORTS: Password Reset Flow ---
import 'screens/forgot_password.dart';
import 'screens/update_password_screen.dart';

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

    // --- NEW ROUTE: Request Password Reset ---
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // --- NEW ROUTE: Set New Password (Opened via Email Link) ---
    GoRoute(
      path: '/update-password',
      builder: (context, state) => const UpdatePasswordScreen(),
    ),

    // -----------------------------------------------------------
    ShellRoute(
      builder: (context, state, child) {
        return WorkerDashboard(child: child);
      },
      routes: [
        // For pages in the navigation bar
        GoRoute(
          path: '/w-dashboard/services',
          builder: (context, state) => const WorkerServicesPage(),
          routes: [
            GoRoute(
              path: 'w-details',
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
        ),

        GoRoute(
          path: '/w-dashboard/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/w-dashboard/history',
          builder: (context, state) => const Placeholder(),
        ),
        GoRoute(
          path: '/w-dashboard/messages',
          builder: (context, state) => const Placeholder(),
        ),
      ],
    ),

    // --- Worker Details & Booking Route ---
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://afgvpnvqxzmosfogcysc.supabase.co',
    anonKey: 'sb_publishable_bLKZ8iWn8-BenfJLuq0TaA_ZVgzUItK',
  );

  // --- PASSWORD RECOVERY LISTENER ---
  // This listens for the specific event when a user clicks a "Reset Password"
  // email link. Supabase logs them in temporarily, and we redirect them
  // immediately to the "Update Password" screen.
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final AuthChangeEvent event = data.event;
    if (event == AuthChangeEvent.passwordRecovery) {
      _router.go('/update-password');
    }
  });
  // ----------------------------------

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
