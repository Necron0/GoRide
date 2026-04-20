import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════
// RideDetailScreen - dengan pilihan sebelum pesan
// ══════════════════════════════════════════════════════

class RideDetailScreen extends StatefulWidget {
  final String serviceName;
  final IconData serviceIcon;
  final Color serviceColor;
  final String? fromLocation;
  final String? toLocation;
  final String? price;

  const RideDetailScreen({
    super.key,
    required this.serviceName,
    required this.serviceIcon,
    required this.serviceColor,
    this.fromLocation,
    this.toLocation,
    this.price,
  });

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  // ── State pilihan ─────────────────────────────────
  String _selectedVehicle = 'Standard';
  String _selectedPayment = 'GoPay';
  String _notes = '';
  bool _isBooking = false;
  bool _isBooked = false;

  // ── Data opsi kendaraan ───────────────────────────
  late List<Map<String, dynamic>> _vehicleOptions;

  // ── Data opsi pembayaran ──────────────────────────
  final List<Map<String, dynamic>> _paymentOptions = [
    {
      'label': 'GoPay',
      'icon': Icons.account_balance_wallet_rounded,
      'color': const Color(0xFF0077FF),
      'badge': 'Saldo: Rp 150.000',
    },
    {
      'label': 'Cash',
      'icon': Icons.payments_rounded,
      'color': const Color(0xFF00AA55),
      'badge': null,
    },
    {
      'label': 'Kartu',
      'icon': Icons.credit_card_rounded,
      'color': const Color(0xFF9055FF),
      'badge': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _buildVehicleOptions();
  }

  void _buildVehicleOptions() {
    if (widget.serviceName == 'GoRide') {
      _vehicleOptions = [
        {
          'label': 'Standard',
          'desc': 'Motor biasa',
          'icon': Icons.directions_bike_rounded,
          'price': 'Rp 10.000',
          'eta': '3 mnt',
        },
        {
          'label': 'Premium',
          'desc': 'Motor matic terbaru',
          'icon': Icons.electric_moped_rounded,
          'price': 'Rp 14.000',
          'eta': '5 mnt',
        },
      ];
    } else if (widget.serviceName == 'GoCar') {
      _vehicleOptions = [
        {
          'label': 'Standard',
          'desc': 'Mobil ekonomis',
          'icon': Icons.directions_car_rounded,
          'price': 'Rp 25.000',
          'eta': '5 mnt',
        },
        {
          'label': 'Premium',
          'desc': 'Mobil nyaman & AC',
          'icon': Icons.airport_shuttle_rounded,
          'price': 'Rp 40.000',
          'eta': '8 mnt',
        },
        {
          'label': 'GoCar XL',
          'desc': 'SUV 6 penumpang',
          'icon': Icons.rv_hookup_rounded,
          'price': 'Rp 55.000',
          'eta': '10 mnt',
        },
      ];
    } else if (widget.serviceName == 'GoFood') {
      _vehicleOptions = [
        {
          'label': 'Reguler',
          'desc': 'Estimasi 30-45 mnt',
          'icon': Icons.fastfood_rounded,
          'price': 'Ongkir Rp 8.000',
          'eta': '35 mnt',
        },
        {
          'label': 'Express',
          'desc': 'Estimasi 15-20 mnt',
          'icon': Icons.delivery_dining_rounded,
          'price': 'Ongkir Rp 15.000',
          'eta': '18 mnt',
        },
      ];
    } else {
      _vehicleOptions = [
        {
          'label': 'Reguler',
          'desc': 'Paket standar',
          'icon': Icons.local_shipping_rounded,
          'price': 'Rp 12.000',
          'eta': '45 mnt',
        },
        {
          'label': 'Express',
          'desc': 'Kirim lebih cepat',
          'icon': Icons.flash_on_rounded,
          'price': 'Rp 20.000',
          'eta': '20 mnt',
        },
      ];
    }
  }

  String get _selectedPrice {
    final v = _vehicleOptions.firstWhere(
        (e) => e['label'] == _selectedVehicle,
        orElse: () => _vehicleOptions.first);
    return widget.price ?? v['price'] as String;
  }

  String get _selectedEta {
    final v = _vehicleOptions.firstWhere(
        (e) => e['label'] == _selectedVehicle,
        orElse: () => _vehicleOptions.first);
    return v['eta'] as String;
  }

  Future<void> _handleBook() async {
    // ── Dialog Konfirmasi ─────────────────────────
    final confirmed = await _showConfirmDialog();
    if (confirmed != true) return;

    setState(() => _isBooking = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {
      _isBooking = false;
      _isBooked = true;
    });

    // Kembali ke home setelah 2 detik
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.pop(context);
  }

  // ── Dialog: Konfirmasi Pesanan ────────────────────
  Future<bool?> _showConfirmDialog() {
    // Buat teks ringkasan sesuai layanan
    final String serviceDesc = () {
      switch (widget.serviceName) {
        case 'GoFood':
          return 'Pesanan makanan';
        case 'GoSend':
          return 'Pengiriman paket';
        default:
          return 'Perjalanan';
      }
    }();

    final String destination = widget.toLocation != null
        ? 'ke ${widget.toLocation}'
        : '';

    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Ikon layanan
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: widget.serviceColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.serviceIcon,
                  color: widget.serviceColor, size: 32),
            ),
            const SizedBox(height: 16),

            // Judul konfirmasi
            const Text(
              'Konfirmasi Pesanan',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A0A0A)),
            ),
            const SizedBox(height: 6),
            Text(
              'Yakin ingin memesan?',
              style: TextStyle(
                  fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 20),

            // Ringkasan detail pesanan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F9FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: const Color(0xFFDDEEFF), width: 1.5),
              ),
              child: Column(
                children: [
                  _confirmRow(
                    Icons.directions_rounded,
                    '$serviceDesc $_selectedVehicle'
                        '${destination.isNotEmpty ? ' $destination' : ''}',
                  ),
                  const SizedBox(height: 10),
                  _confirmRow(
                    Icons.account_balance_wallet_rounded,
                    'Bayar via $_selectedPayment',
                  ),
                  const SizedBox(height: 10),
                  _confirmRow(
                    Icons.access_time_rounded,
                    'Estimasi tiba: $_selectedEta',
                  ),
                  if (_notes.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _confirmRow(
                      Icons.notes_rounded,
                      'Catatan: $_notes',
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(
                        color: widget.serviceColor.withOpacity(0.15),
                        thickness: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0A0A0A))),
                      Text(
                        _selectedPrice,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: widget.serviceColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Ya / Batal
            Row(
              children: [
                // Batal
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF888888),
                      side: const BorderSide(
                          color: Color(0xFFDDDDDD), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    child: const Text('Batal',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                // Ya, Pesan
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.serviceColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    child: Text(
                      'Ya, Pesan ${widget.serviceName}',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper: Baris di dalam konfirmasi ─────────────
  Widget _confirmRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: widget.serviceColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                  height: 1.4)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isBooked) return _buildSuccessScreen();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.serviceName,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0A0A0A))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0A0A0A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Lokasi ────────────────────────────
                if (widget.fromLocation != null && widget.toLocation != null)
                  _buildLocationCard(),

                // ── Pilih Tipe Kendaraan/Layanan ──────
                const SizedBox(height: 20),
                _buildSectionTitle(
                  widget.serviceName == 'GoFood'
                      ? 'Pilih Pengiriman'
                      : 'Pilih Tipe',
                ),
                const SizedBox(height: 12),
                _buildVehicleSelector(),

                // ── Metode Pembayaran ──────────────────
                const SizedBox(height: 20),
                _buildSectionTitle('Metode Pembayaran'),
                const SizedBox(height: 12),
                _buildPaymentSelector(),

                // ── Catatan untuk driver ───────────────
                const SizedBox(height: 20),
                _buildSectionTitle('Catatan (opsional)'),
                const SizedBox(height: 12),
                _buildNotesField(),

                // ── Ringkasan Harga ────────────────────
                const SizedBox(height: 20),
                _buildPriceSummary(),
              ],
            ),
          ),

          // ── Tombol Pesan (floating bottom) ────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBookButton(),
          ),
        ],
      ),
    );
  }

  // ── Widget: Section Title ─────────────────────────
  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A0A0A)));
  }

  // ── Widget: Lokasi Card ───────────────────────────
  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDEEFF), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.circle, color: Colors.green, size: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Text(widget.fromLocation!,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 5),
            child: SizedBox(
                height: 14,
                child: VerticalDivider(
                    color: Color(0xFFBBBBBB), thickness: 1.5)),
          ),
          Row(
            children: [
              Icon(Icons.location_on_rounded,
                  color: widget.serviceColor, size: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Text(widget.toLocation!,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Widget: Vehicle Selector ──────────────────────
  Widget _buildVehicleSelector() {
    return Column(
      children: _vehicleOptions.map((opt) {
        final bool selected = _selectedVehicle == opt['label'];
        return GestureDetector(
          onTap: () => setState(() => _selectedVehicle = opt['label']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected
                  ? widget.serviceColor.withOpacity(0.07)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? widget.serviceColor
                    : const Color(0xFFDDEEFF),
                width: selected ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? widget.serviceColor.withOpacity(0.12)
                        : const Color(0xFFF0F6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(opt['icon'] as IconData,
                      color: selected
                          ? widget.serviceColor
                          : const Color(0xFF888888),
                      size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opt['label'] as String,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? widget.serviceColor
                                  : const Color(0xFF0A0A0A))),
                      Text(opt['desc'] as String,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888888))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(opt['price'] as String,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: selected
                                ? widget.serviceColor
                                : const Color(0xFF0A0A0A))),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 11,
                            color: const Color(0xFF888888)),
                        const SizedBox(width: 3),
                        Text(opt['eta'] as String,
                            style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF888888))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? widget.serviceColor
                          : const Color(0xFFCCCCCC),
                      width: 2,
                    ),
                    color: selected
                        ? widget.serviceColor
                        : Colors.transparent,
                  ),
                  child: selected
                      ? const Icon(Icons.check,
                          color: Colors.white, size: 12)
                      : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Widget: Payment Selector ──────────────────────
  Widget _buildPaymentSelector() {
    return Row(
      children: _paymentOptions.map((opt) {
        final bool selected = _selectedPayment == opt['label'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPayment = opt['label']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(
                  right:
                      opt == _paymentOptions.last ? 0 : 8),
              padding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: selected
                    ? (opt['color'] as Color).withOpacity(0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? opt['color'] as Color
                      : const Color(0xFFDDEEFF),
                  width: selected ? 2 : 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(opt['icon'] as IconData,
                      color: selected
                          ? opt['color'] as Color
                          : const Color(0xFF888888),
                      size: 24),
                  const SizedBox(height: 6),
                  Text(opt['label'] as String,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? opt['color'] as Color
                              : const Color(0xFF555555))),
                  if (opt['badge'] != null && selected)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        opt['badge'] as String,
                        style: TextStyle(
                            fontSize: 9,
                            color: (opt['color'] as Color)
                                .withOpacity(0.7),
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Widget: Notes Field ───────────────────────────
  Widget _buildNotesField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDEEFF), width: 1.5),
      ),
      child: TextField(
        maxLines: 2,
        onChanged: (v) => setState(() => _notes = v),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: widget.serviceName == 'GoFood'
              ? 'Catatan untuk resto / rider...'
              : 'Catatan untuk driver (opsional)...',
          hintStyle: const TextStyle(color: Color(0xFFBBCCDD)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ── Widget: Price Summary ─────────────────────────
  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDEEFF), width: 1.5),
      ),
      child: Column(
        children: [
          _priceRow('Tipe', _selectedVehicle),
          const SizedBox(height: 8),
          _priceRow('Pembayaran', _selectedPayment),
          const SizedBox(height: 8),
          _priceRow('Estimasi waktu', _selectedEta),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
                color: widget.serviceColor.withOpacity(0.2),
                thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              Text(_selectedPrice,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: widget.serviceColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF888888))),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0A0A0A))),
      ],
    );
  }

  // ── Widget: Book Button ───────────────────────────
  Widget _buildBookButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Info singkat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 14, color: widget.serviceColor),
                  const SizedBox(width: 4),
                  Text(_selectedEta,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: widget.serviceColor)),
                ],
              ),
              Text(_selectedPrice,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: widget.serviceColor)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isBooking ? null : _handleBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.serviceColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    widget.serviceColor.withOpacity(0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
              ),
              child: _isBooking
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        ),
                        SizedBox(width: 12),
                        Text('Mencari driver...',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                      ],
                    )
                  : Text(
                      'Pesan ${widget.serviceName} Sekarang',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget: Success Screen ────────────────────────
  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: widget.serviceColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle_rounded,
                      color: widget.serviceColor, size: 56),
                ),
                const SizedBox(height: 24),
                const Text('Pesanan Diterima!',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text(
                  '${widget.serviceName} $_selectedVehicle sedang dalam perjalanan.\nEstimasi $_selectedEta',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                      height: 1.6),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: widget.serviceColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.account_balance_wallet_rounded,
                          size: 16, color: widget.serviceColor),
                      const SizedBox(width: 8),
                      Text('Bayar via $_selectedPayment · $_selectedPrice',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: widget.serviceColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}