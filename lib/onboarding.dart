import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════
// OnboardingScreen
// Halaman pertama yang ditampilkan saat aplikasi dibuka.
// Navigasi ke LoginScreen atau SignUpScreen menggunakan
// Named Routes → Navigator.pushNamed()
// ══════════════════════════════════════════════════════

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Data konten tiap halaman onboarding
  final List<Map<String, String>> _pages = [
    {
      'title': 'Welcome to GoRide!',
      'subtitle':
          'Your go-to ride app for a hassle-free journey. We\'re here to take you anywhere!',
      'icon': 'bike',
    },
    {
      'title': 'Fast & Safe Rides',
      'subtitle':
          'Book a ride in seconds. Our verified drivers ensure your safety and comfort.',
      'icon': 'shield',
    },
    {
      'title': 'Track in Real-Time',
      'subtitle':
          'Follow your driver live on the map. Know exactly when they\'ll arrive.',
      'icon': 'location',
    },
  ];

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLogo(),
                  _buildLangButton(),
                ],
              ),
            ),

            // ── PageView Ilustrasi ───────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPageContent(_pages[index]);
                },
              ),
            ),

            // ── Dot Indicator ────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF0077FF)
                          : const Color(0xFFB3D4FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // ── Teks Consent ─────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                      fontSize: 11, color: Color(0xFF888888), height: 1.6),
                  children: [
                    TextSpan(
                        text:
                            'By continuing, I consent to my personal data processing\naccording to GoRide\'s '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                          color: Color(0xFF0077FF),
                          fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: ' & '),
                    TextSpan(
                      text: 'Privacy Notice',
                      style: TextStyle(
                          color: Color(0xFF0077FF),
                          fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
            ),

            // ── Tombol Login & Sign Up ───────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Column(
                children: [
                  // Tombol Log In → Navigator.pushNamed ke '/login'
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        // ── Named Route Navigation ──
                        Navigator.pushNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0077FF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      child: const Text('Log in',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tombol Sign Up → Navigator.pushNamed ke '/signup'
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        // ── Named Route Navigation ──
                        Navigator.pushNamed(context, '/signup');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0077FF),
                        side: const BorderSide(
                            color: Color(0xFF0077FF), width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      child: const Text("I'm new, sign me up",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ── Home Indicator ────────────────────────────
            Center(
              child: Container(
                width: 80,
                height: 4,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCCCCC),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Widget: Logo GoRide ───────────────────────────────
  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
              color: Color(0xFF0077FF), shape: BoxShape.circle),
          child: const Icon(Icons.directions_bike_rounded,
              color: Colors.white, size: 18),
        ),
        const SizedBox(width: 8),
        const Text('goride',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0A0A0A),
                letterSpacing: -0.5)),
      ],
    );
  }

  // ── Widget: Tombol Bahasa ─────────────────────────────
  Widget _buildLangButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.language_rounded, size: 14, color: Color(0xFF555555)),
          SizedBox(width: 4),
          Text('English',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF555555))),
        ],
      ),
    );
  }

  // ── Widget: Konten Tiap Halaman ───────────────────────
  Widget _buildPageContent(Map<String, String> data) {
    IconData icon;
    switch (data['icon']) {
      case 'shield':
        icon = Icons.shield_rounded;
        break;
      case 'location':
        icon = Icons.location_on_rounded;
        break;
      default:
        icon = Icons.directions_bike_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Area ilustrasi
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F2FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      size: 90,
                      color: const Color(0xFF0077FF).withOpacity(0.8)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0077FF).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      data['title']!,
                      style: const TextStyle(
                          color: Color(0xFF0055CC),
                          fontWeight: FontWeight.w700,
                          fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(data['title']!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A0A0A))),
          const SizedBox(height: 10),
          Text(data['subtitle']!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF555555),
                  height: 1.6,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}