import 'package:flutter/material.dart';
import 'package:flutter_sql_supabase/auth/login_page.dart';
import 'package:flutter_sql_supabase/auth/signup_page.dart';
import 'package:flutter_sql_supabase/screen/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//from supabase documentation
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://wkehpvkzwksbfxnrtqgb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndrZWhwdmt6d2tzYmZ4bnJ0cWdiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzAxNjYzNjEsImV4cCI6MjA0NTc0MjM2MX0.r8Af-1tTp1my-s5wvNUaiVh6EwopKNx0dgU3H6oBEOo',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 74, 235, 80)),
        useMaterial3: false,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: Supabase.instance.client.auth.currentSession == null
          ? '/login'
          : '/home',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomePageScreen(),
      },
    );
  }
}
