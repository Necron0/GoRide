import 'package:flutter/material.dart';
import 'onboarding.dart';
import 'login.dart';
import 'otp.dart';
import 'signup.dart';
import 'home.dart';

void main() {
  runApp(const GoRideApp());
}

class GoRideApp extends StatelessWidget {
  const GoRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoRide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0077FF)),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),

      // ──────────────────────────────────────────────
      // Named Routes (Pertemuan 05 - Navigasi Flutter)
      // Definisikan semua rute di MaterialApp agar
      // lebih rapi untuk aplikasi besar.
      // ──────────────────────────────────────────────
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/otp': (context) => const OtpScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}