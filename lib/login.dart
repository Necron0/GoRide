import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════
// LoginScreen
// Halaman login dengan input nomor HP.
//
// Konsep Navigasi yang dipakai:
//   - Navigator.pop(context)  → kembali ke OnboardingScreen
//   - Navigator.push() dengan mengirim DATA (nomor HP)
//     ke OtpScreen menggunakan konstruktor parameter.
// ══════════════════════════════════════════════════════

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // ── Navigator.pop() ──────────────────────────
        // Tombol back → kembali ke halaman sebelumnya (OnboardingScreen)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Color(0xFF0A0A0A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Logo ──────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                        color: Color(0xFF0077FF), shape: BoxShape.circle),
                    child: const Icon(Icons.directions_bike_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text('goride',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0A0A0A),
                          letterSpacing: -0.5)),
                ],
              ),
              const SizedBox(height: 32),

              // ── Judul ─────────────────────────────────
              const Text('Log in',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0A0A0A))),
              const SizedBox(height: 6),
              const Text('Enter your phone number to continue',
                  style:
                      TextStyle(fontSize: 14, color: Color(0xFF888888))),
              const SizedBox(height: 28),

              // ── Input Nomor HP ────────────────────────
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color(0xFFDDEEFF), width: 1.5),
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFFF5F9FF),
                ),
                child: Row(
                  children: [
                    // Prefix +62
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 16),
                      decoration: const BoxDecoration(
                        border: Border(
                            right: BorderSide(
                                color: Color(0xFFDDEEFF), width: 1.5)),
                      ),
                      child: const Text('+62',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0077FF))),
                    ),
                    // Field nomor
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          hintText: '812-3456-7890',
                          hintStyle: TextStyle(color: Color(0xFFBBCCDD)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Tombol Continue ───────────────────────
              // Mengirim DATA nomor HP ke OtpScreen
              // menggunakan Navigator.push() + constructor argument
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final phone = _phoneController.text.trim();
                    if (phone.isEmpty) return;

                    // ── Navigasi dengan Mengirim Data ──
                    // Kirim data 'phone' ke OtpScreen via constructor
                    Navigator.pushNamed(
                      context,
                      '/otp',
                      // Mengirim argumen berupa Map ke halaman OTP
                      arguments: {'phone': '+62 $phone'},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  child: const Text('Continue',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),

              const Spacer(),

              // ── Link ke Sign Up ───────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/signup'),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF888888)),
                      children: [
                        TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Sign up',
                          style: TextStyle(
                              color: Color(0xFF0077FF),
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}