import 'package:flutter/material.dart';
import 'RideDetail.dart';

// ══════════════════════════════════════════════════════
// HomeScreen
// Halaman utama setelah login/signup.
//
// Konsep Navigasi yang dipakai:
//   - Navigator.push() → ke RideDetailScreen dengan DATA
//     (contoh mengirim data produk seperti di materi PDF)
//   - BottomNavigationBar untuk navigasi tab
// ══════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Data layanan yang tersedia
  final List<Map<String, dynamic>> _services = [
    {'icon': Icons.directions_bike_rounded, 'label': 'GoRide', 'color': const Color(0xFF0077FF)},
    {'icon': Icons.directions_car_rounded, 'label': 'GoCar', 'color': const Color(0xFF0055CC)},
    {'icon': Icons.fastfood_rounded, 'label': 'GoFood', 'color': const Color(0xFFFF6B00)},
    {'icon': Icons.local_shipping_rounded, 'label': 'GoSend', 'color': const Color(0xFF00AA55)},
  ];

  // Data promo / penawaran
  final List<Map<String, dynamic>> _promos = [
    {
      'title': 'Diskon 50%',
      'subtitle': 'Perjalanan pertamamu!\nKode: GORIDE50',
      'icon': Icons.local_offer_rounded,
      'gradient': [const Color(0xFF0055CC), const Color(0xFF0099FF)],
    },
    {
      'title': 'Gratis Ongkir',
      'subtitle': 'GoFood min. order 30rb.\nKode: FOOD2025',
      'icon': Icons.fastfood_rounded,
      'gradient': [const Color(0xFFFF6B00), const Color(0xFFFFAA00)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──────────────────────────────────
            _buildTopBar(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Greeting ────────────────────────────
                    const Text('Good morning! 👋',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0A0A0A))),
                    const SizedBox(height: 4),
                    const Text('Where are you going today?',
                        style: TextStyle(
                            fontSize: 14, color: Color(0xFF888888))),
                    const SizedBox(height: 20),

                    // ── Search Bar ──────────────────────────
                    _buildSearchBar(),
                    const SizedBox(height: 24),

                    // ── Services Grid ───────────────────────
                    const Text('Services',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0A0A0A))),
                    const SizedBox(height: 14),
                    _buildServicesGrid(),
                    const SizedBox(height: 24),

                    // ── Promo Banner ────────────────────────
                    const Text('Promo untuk kamu',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0A0A0A))),
                    const SizedBox(height: 14),
                    ..._promos.map((promo) => _buildPromoBanner(promo)),

                    const SizedBox(height: 24),

                    // ── Riwayat Perjalanan ──────────────────
                    const Text('Perjalanan Terakhir',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0A0A0A))),
                    const SizedBox(height: 14),
                    _buildRideHistory(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Navigation Bar ─────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: const Color(0xFF0077FF),
        unselectedItemColor: const Color(0xFFBBBBBB),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded), label: 'Activity'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inbox_rounded), label: 'Inbox'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  // ── Widget: Top Bar ───────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
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
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0A0A0A),
                      letterSpacing: -0.5)),
            ],
          ),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFE8F2FF),
            child: Icon(Icons.person_rounded,
                color: Color(0xFF0077FF), size: 20),
          ),
        ],
      ),
    );
  }

  // ── Widget: Search Bar ────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFFDDEEFF), width: 1.5),
      ),
      child: const Row(
        children: [
          Icon(Icons.search_rounded, color: Color(0xFF0077FF), size: 20),
          SizedBox(width: 10),
          Text('Search destination',
              style: TextStyle(
                  color: Color(0xFFBBCCDD),
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Widget: Grid Layanan ──────────────────────────────
  Widget _buildServicesGrid() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 8,
      childAspectRatio: 0.82,
      children: _services.map((service) {
        return GestureDetector(
          onTap: () {
            // ── Navigator.push() dengan Mengirim Data ──
            // Mengirim nama layanan ke RideDetailScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RideDetailScreen(
                  serviceName: service['label'],
                  serviceIcon: service['icon'],
                  serviceColor: service['color'],
                ),
              ),
            );
          },
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: (service['color'] as Color).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(service['icon'] as IconData,
                    color: service['color'] as Color, size: 26),
              ),
              const SizedBox(height: 6),
              Text(service['label'] as String,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF555555))),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Widget: Promo Banner ──────────────────────────────
  Widget _buildPromoBanner(Map<String, dynamic> promo) {
    final gradients = promo['gradient'] as List<Color>;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: gradients,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(promo['title'] as String,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(promo['subtitle'] as String,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.5)),
              ],
            ),
          ),
          Icon(promo['icon'] as IconData,
              color: Colors.white38, size: 44),
        ],
      ),
    );
  }

  // ── Widget: Riwayat Perjalanan ────────────────────────
  Widget _buildRideHistory() {
    final List<Map<String, String>> history = [
      {
        'from': 'Kampus Universitas',
        'to': 'Stasiun Jember',
        'date': 'Kemarin, 14:30',
        'price': 'Rp 12.000',
      },
      {
        'from': 'Rumah Sakit Umum',
        'to': 'Pasar Tanjung',
        'date': 'Senin, 09:15',
        'price': 'Rp 8.500',
      },
    ];

    return Column(
      children: history.map((ride) {
        return GestureDetector(
          onTap: () {
            // ── Navigator.push() dengan Data ──────────
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RideDetailScreen(
                  serviceName: 'GoRide',
                  serviceIcon: Icons.directions_bike_rounded,
                  serviceColor: const Color(0xFF0077FF),
                  fromLocation: ride['from'],
                  toLocation: ride['to'],
                  price: ride['price'],
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFFDDEEFF), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.directions_bike_rounded,
                      color: Color(0xFF0077FF), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${ride['from']} → ${ride['to']}',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0A0A0A)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text(ride['date']!,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888888))),
                    ],
                  ),
                ),
                Text(ride['price']!,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0077FF))),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}