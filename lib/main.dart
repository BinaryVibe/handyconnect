import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'signup.dart'; // For testing
import 'worker_dashboard.dart';
import 'customer_dashboard.dart';
import 'login.dart';

const Color kPrimaryColor = Color.fromARGB(
  255,
  74,
  46,
  30,
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
    return MaterialApp(
      theme: ThemeData(
        primaryColor: kPrimaryColor,
      ),
      debugShowCheckedModeBanner: false,
      title: 'HandyConnect',
      home: const LoginScreen(),
    );
  }
}
