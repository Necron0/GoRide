import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════
// RideDetailScreen
// Halaman detail layanan / perjalanan.
//
// Konsep Navigasi yang dipakai (sesuai materi PDF):
//   "Contoh Halaman Menerima Data"
//   - Menerima data melalui parameter konstruktor
//     (serviceName, serviceIcon, serviceColor, dll.)
//   - Navigator.pop(context) → kembali ke HomeScreen
//
// Ini adalah implementasi dari slide PDF hal. 8-9:
//   class DetailPage extends StatelessWidget {
//     final String productName;
//     DetailPage({required this.productName});
//   }
// ══════════════════════════════════════════════════════

class RideDetailScreen extends StatelessWidget {
  // ── Menerima Data dari Halaman Sebelumnya ────────────
  final String serviceName;
  final IconData serviceIcon;
  final Color serviceColor;
  final String? fromLocation;
  final String? toLocation;
  final String? price;

  const RideDetailScreen({
    super.key,
    required this.serviceName,   // Data wajib: nama layanan
    required this.serviceIcon,   // Data wajib: ikon layanan
    required this.serviceColor,  // Data wajib: warna layanan
    this.fromLocation,           // Opsional: lokasi asal
    this.toLocation,             // Opsional: lokasi tujuan
    this.price,                  // Opsional: harga
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          serviceName,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0A0A0A)),
        ),
        // ── Navigator.pop() ──────────────────────────
        // Kembali ke HomeScreen
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Color(0xFF0A0A0A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Data yang Diterima (Info Box) ─────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: serviceColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: serviceColor.withOpacity(0.3), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: serviceColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(serviceIcon,
                              color: serviceColor, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(serviceName,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: serviceColor)),
                            Text(
                              'Data diterima dari HomeScreen',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: serviceColor.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Detail Perjalanan ─────────────────────
              if (fromLocation != null && toLocation != null) ...[
                const Text('Detail Perjalanan',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A0A0A))),
                const SizedBox(height: 14),
                _buildLocationCard(),
                const SizedBox(height: 16),
              ],

              // ── Input Tujuan (jika belum ada data) ────
              if (fromLocation == null) ...[
                const Text('Masukkan Tujuan',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A0A0A))),
                const SizedBox(height: 14),
                _buildLocationInput(
                    'Lokasi penjemputan', Icons.circle, Colors.green),
                const SizedBox(height: 10),
                _buildLocationInput(
                    'Tujuan', Icons.location_on_rounded, serviceColor),
                const SizedBox(height: 24),
              ],

              // ── Info Navigasi (Edukasi) ───────────────
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
                        Icon(Icons.code_rounded,
                            size: 16, color: Color(0xFF0077FF)),
                        SizedBox(width: 6),
                        Text('Konsep Navigasi (Materi PDF)',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0055CC))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _infoRow('Layanan', serviceName),
                    if (fromLocation != null)
                      _infoRow('Dari', fromLocation!),
                    if (toLocation != null)
                      _infoRow('Ke', toLocation!),
                    if (price != null) _infoRow('Harga', price!),
                    const SizedBox(height: 8),
                    const Text(
                      'RideDetailScreen(\n'
                      '  serviceName: "$serviceName", // ← data dikirim\n'
                      ')',
                      style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF0077FF),
                          fontFamily: 'monospace',
                          height: 1.6),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── Tombol Pesan Sekarang ─────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$serviceName dipesan!'),
                        backgroundColor: serviceColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: serviceColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  child: Text('Pesan $serviceName Sekarang',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 12),

              // ── Tombol Kembali ────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    // ── Navigator.pop() ───────────────────
                    // Kembali ke halaman sebelumnya (HomeScreen)
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: serviceColor,
                    side: BorderSide(color: serviceColor, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  child: const Text('Kembali',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widget: Kartu Lokasi ──────────────────────────────
  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDEEFF), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.circle, color: Colors.green, size: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Text(fromLocation!,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: SizedBox(
              height: 18,
              child: VerticalDivider(
                  color: Color(0xFFBBBBBB), thickness: 1.5),
            ),
          ),
          Row(
            children: [
              Icon(Icons.location_on_rounded,
                  color: serviceColor, size: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Text(toLocation!,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              if (price != null)
                Text(price!,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: serviceColor)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Widget: Input Lokasi ──────────────────────────────
  Widget _buildLocationInput(
      String hint, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: const Color(0xFFDDEEFF), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 12),
          Text(hint,
              style: const TextStyle(
                  color: Color(0xFFBBCCDD),
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Widget: Info Row ──────────────────────────────────
  Widget _infoRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$key: ',
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF888888),
                  fontFamily: 'monospace')),
          Text('"$value"',
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF0077FF),
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}