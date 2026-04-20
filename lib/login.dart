import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════
// LoginScreen - dengan validasi autentikasi
// ══════════════════════════════════════════════════════

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasInteracted = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // ── Validasi nomor HP ─────────────────────────────
  String? _validatePhone(String value) {
    if (value.isEmpty) {
      return 'Nomor HP tidak boleh kosong';
    }
    // Hapus spasi dan tanda hubung
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return 'Nomor HP hanya boleh berisi angka';
    }
    if (cleaned.length < 8) {
      return 'Nomor HP minimal 8 digit';
    }
    if (cleaned.length > 13) {
      return 'Nomor HP maksimal 13 digit';
    }
    return null;
  }

  void _onPhoneChanged(String value) {
    if (_hasInteracted) {
      setState(() {
        _errorMessage = _validatePhone(value);
      });
    }
  }

  Future<void> _handleContinue() async {
    setState(() {
      _hasInteracted = true;
      _errorMessage = _validatePhone(_phoneController.text.trim());
    });

    if (_errorMessage != null) {
      _shakeController.forward(from: 0);
      return;
    }

    setState(() => _isLoading = true);

    // Simulasi loading / network call
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() => _isLoading = false);

    if (!mounted) return;

    Navigator.pushNamed(
      context,
      '/otp',
      arguments: {'phone': '+62 ${_phoneController.text.trim()}'},
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isValid = _errorMessage == null &&
        _phoneController.text.isNotEmpty &&
        _hasInteracted;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0A0A0A)),
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

              // ── Logo ─────────────────────────────────
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

              const Text('Log in',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0A0A0A))),
              const SizedBox(height: 6),
              const Text('Enter your phone number to continue',
                  style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
              const SizedBox(height: 28),

              // ── Input Nomor HP dengan validasi ────────
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  final double shakeOffset =
                      _shakeController.isAnimating
                          ? 8 *
                              (0.5 -
                                  (_shakeAnimation.value - 0.5).abs())
                          : 0;
                  return Transform.translate(
                    offset: Offset(shakeOffset, 0),
                    child: child,
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _errorMessage != null
                              ? const Color(0xFFFF3B30)
                              : isValid
                                  ? const Color(0xFF34C759)
                                  : const Color(0xFFDDEEFF),
                          width: _errorMessage != null || isValid ? 2 : 1.5,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        color: _errorMessage != null
                            ? const Color(0xFFFFF5F5)
                            : isValid
                                ? const Color(0xFFF0FFF5)
                                : const Color(0xFFF5F9FF),
                      ),
                      child: Row(
                        children: [
                          // Prefix +62
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      color: _errorMessage != null
                                          ? const Color(0xFFFFCCCC)
                                          : const Color(0xFFDDEEFF),
                                      width: 1.5)),
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
                              onChanged: (v) {
                                setState(() => _hasInteracted = true);
                                _onPhoneChanged(v);
                              },
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                              decoration: const InputDecoration(
                                hintText: '812-3456-7890',
                                hintStyle:
                                    TextStyle(color: Color(0xFFBBCCDD)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 16),
                              ),
                            ),
                          ),
                          // Status icon
                          if (_hasInteracted)
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: _errorMessage != null
                                    ? const Icon(Icons.error_rounded,
                                        color: Color(0xFFFF3B30),
                                        size: 20,
                                        key: ValueKey('error'))
                                    : const Icon(Icons.check_circle_rounded,
                                        color: Color(0xFF34C759),
                                        size: 20,
                                        key: ValueKey('valid')),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // ── Pesan Error ─────────────────────
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: _errorMessage != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8, left: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded,
                                      size: 14,
                                      color: Color(0xFFFF3B30)),
                                  const SizedBox(width: 4),
                                  Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFFF3B30),
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Tombol Continue ───────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077FF),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFF0077FF).withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text('Continue',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                  ),
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