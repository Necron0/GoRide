import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════
// OtpScreen
// Halaman verifikasi OTP.
//
// Konsep Navigasi yang dipakai:
//   - MENERIMA DATA dari LoginScreen via ModalRoute.of()
//     (sesuai materi: "Terima Data saat pop / push")
//   - Navigator.pop(context) → kembali ke LoginScreen
//   - Navigator.pushNamedAndRemoveUntil() → ke HomeScreen
//     sambil menghapus semua stack sebelumnya
// ══════════════════════════════════════════════════════

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // 4 controller untuk 4 kotak OTP
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ── Widget: Satu Kotak OTP ────────────────────────────
  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 62,
      height: 66,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0077FF)),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFFF0F6FF),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFFCCDDFF), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Color(0xFF0077FF), width: 2),
          ),
        ),
        // Auto-fokus ke kotak berikutnya
        onChanged: (val) {
          if (val.isNotEmpty && index < 3) {
            _focusNodes[index + 1].requestFocus();
          }
          // Jika hapus, kembali ke kotak sebelumnya
          if (val.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── Menerima Data dari LoginScreen ───────────────
    // Data dikirim melalui arguments saat Navigator.pushNamed()
    final args = ModalRoute.of(context)?.settings.arguments
        as Map<String, dynamic>?;
    final String phone = args?['phone'] ?? 'nomor tidak ditemukan';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // ── Navigator.pop() ──────────────────────────
        // Kembali ke LoginScreen
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
              const SizedBox(height: 16),

              // ── Judul ─────────────────────────────────
              const Text('Verify OTP',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0A0A0A))),
              const SizedBox(height: 8),

              // ── Tampilkan data yang diterima dari LoginScreen ──
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF888888),
                      height: 1.6),
                  children: [
                    const TextSpan(
                        text: 'Enter the 4-digit code sent to\n'),
                    TextSpan(
                      // Data nomor HP yang diterima dari LoginScreen
                      text: phone,
                      style: const TextStyle(
                          color: Color(0xFF0077FF),
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // ── 4 Kotak OTP ───────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, _buildOtpBox),
              ),
              const SizedBox(height: 28),

              // ── Tombol Verify ──────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // ── Navigasi ke HomeScreen ──────────
                    // pushNamedAndRemoveUntil → hapus semua stack
                    // agar user tidak bisa back ke OTP/Login
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  child: const Text('Verify & Continue',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 20),

              // ── Link Resend ───────────────────────────
              Center(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                        fontSize: 13, color: Color(0xFF888888)),
                    children: [
                      TextSpan(text: "Didn't receive code? "),
                      TextSpan(
                        text: 'Resend OTP',
                        style: TextStyle(
                            color: Color(0xFF0077FF),
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Info Box: Konsep Navigasi ─────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFCCDDFF), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 16, color: Color(0xFF0077FF)),
                        SizedBox(width: 6),
                        Text('Data diterima dari LoginScreen:',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0055CC))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'phone: "$phone"',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0077FF),
                          fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'via ModalRoute.of(context)?.settings.arguments',
                      style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF888888),
                          fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}