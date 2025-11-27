import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      home: Scaffold(
        appBar: AppBar(
          
        ),
      )
    );
  }

}