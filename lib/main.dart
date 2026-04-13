import 'package:flutter/material.dart';
import 'package:projek_akhir/auth/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://rlajhimefhrjnemazsui.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJsYWpoaW1lZmhyam5lbWF6c3VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU4MzAyNjYsImV4cCI6MjA5MTQwNjI2Nn0.K65-JlfeXZl4oIqdVSjmzo2Q6TIoD0S715CJbJ-eKSQ',
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
