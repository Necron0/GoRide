import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════
// SignUpScreen
// Halaman pendaftaran akun baru.
//
// Konsep Navigasi yang dipakai:
//   - Navigator.pop(context) → kembali ke OnboardingScreen
//   - Navigator.pushNamedAndRemoveUntil() → ke HomeScreen
// ══════════════════════════════════════════════════════

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Color(0xFF0A0A0A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
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
                          color: Color(0xFF0077FF),
                          shape: BoxShape.circle),
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
                const Text('Create Account',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0A0A0A))),
                const SizedBox(height: 6),
                const Text('Join GoRide and ride anywhere!',
                    style: TextStyle(
                        fontSize: 14, color: Color(0xFF888888))),
                const SizedBox(height: 28),

                // ── Form Fields ───────────────────────────
                _buildField(
                  label: 'Full Name',
                  hint: 'Masukkan nama lengkap',
                  icon: Icons.person_outline_rounded,
                  controller: _nameController,
                  type: TextInputType.name,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 14),
                _buildField(
                  label: 'Phone Number',
                  hint: '812-3456-7890',
                  icon: Icons.phone_outlined,
                  controller: _phoneController,
                  type: TextInputType.phone,
                  validator: (val) => val == null || val.isEmpty
                      ? 'Nomor HP wajib diisi'
                      : null,
                  prefix: '+62',
                ),
                const SizedBox(height: 14),
                _buildField(
                  label: 'Email',
                  hint: 'contoh@email.com',
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  type: TextInputType.emailAddress,
                  validator: (val) => val == null || !val.contains('@')
                      ? 'Email tidak valid'
                      : null,
                ),
                const SizedBox(height: 28),

                // ── Tombol Daftar ──────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // ── Navigasi ke Home ──────────────
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    child: const Text('Create Account',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Link ke Login ─────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                            fontSize: 13, color: Color(0xFF888888)),
                        children: [
                          TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Log in',
                            style: TextStyle(
                                color: Color(0xFF0077FF),
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Widget: Form Field ────────────────────────────────
  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required TextInputType type,
    String? Function(String?)? validator,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF444444))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border:
                Border.all(color: const Color(0xFFDDEEFF), width: 1.5),
            borderRadius: BorderRadius.circular(14),
            color: const Color(0xFFF5F9FF),
          ),
          child: Row(
            children: [
              if (prefix != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                        right: BorderSide(
                            color: Color(0xFFDDEEFF), width: 1.5)),
                  ),
                  child: Text(prefix,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0077FF))),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(icon,
                      color: const Color(0xFF0077FF), size: 20),
                ),
              ],
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: type,
                  validator: validator,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle:
                        const TextStyle(color: Color(0xFFBBCCDD)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}