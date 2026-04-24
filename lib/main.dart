import 'package:flutter/material.dart';
import 'package:projek_akhir/auth/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projek_akhir/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables dari file .env
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  await NotificationService().init();


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

