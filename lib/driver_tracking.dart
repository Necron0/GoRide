import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'firebase_tracking_service.dart';
import 'route_service.dart';

// ══════════════════════════════════════════════════════
// DriverTrackingScreen
// Tampilan untuk DRIVER — upload GPS ke Firebase
// Pelanggan bisa lihat posisi driver di TrackingScreen
// ══════════════════════════════════════════════════════

class DriverTrackingScreen extends StatefulWidget {
  final String orderId;
  final Color serviceColor;
  final IconData serviceIcon;
  final String passengerName;
  final LatLng pickupLocation;
  final LatLng destination;

  const DriverTrackingScreen({
    super.key,
    required this.orderId,
    required this.serviceColor,
    required this.serviceIcon,
    required this.pickupLocation,
    required this.destination,
    this.passengerName = 'Pelanggan',
  });

  @override
  State<DriverTrackingScreen> createState() => _DriverTrackingScreenState();
}

class _DriverTrackingScreenState extends State<DriverTrackingScreen>
    with SingleTickerProviderStateMixin {

  final MapController _mapController = MapController();

  LatLng _myPos = const LatLng(0, 0);
  List<LatLng> _routePoints = [];
  bool _isTracking = false;
  bool _isLoadingRoute = true;
  bool _arrivedAtPickup = false;
  bool _tripStarted = false;
  double _speedKmh = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _init();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    FirebaseTrackingService.stopDriverTracking();
    super.dispose();
  }

  Future<void> _init() async {
    // Ambil posisi GPS driver saat ini
    final pos = await FirebaseTrackingService.getCurrentPosition();
    if (pos != null && mounted) {
      setState(() => _myPos = pos);
      _mapController.move(pos, 15.5);
    }

    // Load route ke lokasi jemput dulu
    final route = await RouteService.getRoute(
      start: _myPos.latitude != 0 ? _myPos : widget.pickupLocation,
      end: widget.pickupLocation,
    );

    if (mounted) {
      setState(() {
        _routePoints = route;
        _isLoadingRoute = false;
      });
    }
  }

  Future<void> _startTracking() async {
    setState(() => _isTracking = true);

    // Update status di Firebase
    await FirebaseTrackingService.updateOrderStatus(
        widget.orderId, 'on_the_way');

    // Mulai upload GPS ke Firebase
    await FirebaseTrackingService.startDriverTracking(widget.orderId);

    // Listen posisi sendiri untuk update UI driver
    _listenOwnPosition();
  }

  void _listenOwnPosition() {
    FirebaseTrackingService
        .listenDriverData(widget.orderId)
        .listen((data) {
      if (!mounted || !data.isValid) return;
      setState(() {
        _myPos = data.position;
        _speedKmh = data.speedKmh;
        _mapController.move(_myPos, 16.0);
      });
    });
  }

  void _stopTracking() {
    FirebaseTrackingService.stopDriverTracking();
    setState(() => _isTracking = false);
  }

  Future<void> _arrivedAtPickupAction() async {
    await FirebaseTrackingService.updateOrderStatus(
        widget.orderId, 'arrived');
    setState(() => _arrivedAtPickup = true);

    // Update route ke tujuan
    final route = await RouteService.getRoute(
      start: widget.pickupLocation,
      end: widget.destination,
    );
    if (mounted) setState(() => _routePoints = route);
  }

  Future<void> _startTrip() async {
    await FirebaseTrackingService.updateOrderStatus(
        widget.orderId, 'on_trip');
    setState(() => _tripStarted = true);
  }

  Future<void> _finishTrip() async {
    FirebaseTrackingService.stopDriverTracking();
    await FirebaseTrackingService.updateOrderStatus(
        widget.orderId, 'completed');

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Perjalanan Selesai! 🎉',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Terima kasih, perjalanan telah selesai.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── PETA ────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.pickupLocation,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.gojek',
              ),

              // Route
              if (_routePoints.isNotEmpty)
                PolylineLayer(polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 5,
                    color: widget.serviceColor.withOpacity(0.8),
                    strokeCap: StrokeCap.round,
                  ),
                ]),

              MarkerLayer(markers: [
                // Posisi driver (saya)
                if (_myPos.latitude != 0)
                  Marker(
                    point: _myPos,
                    width: 56, height: 76,
                    child: AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (_, child) => Column(children: [
                        Transform.scale(
                          scale: _pulseAnim.value,
                          child: Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              color: widget.serviceColor,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(
                                color: widget.serviceColor.withOpacity(0.4),
                                blurRadius: 12, spreadRadius: 3,
                              )],
                            ),
                            child: Icon(widget.serviceIcon,
                                color: Colors.white, size: 26),
                          ),
                        ),
                        CustomPaint(
                          size: const Size(12, 8),
                          painter: _TrianglePainter(widget.serviceColor),
                        ),
                      ]),
                    ),
                  ),

                // Pickup location
                Marker(
                  point: widget.pickupLocation,
                  width: 50, height: 60,
                  child: Column(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                        )],
                      ),
                      child: const Icon(Icons.person_pin_circle_rounded,
                          color: Colors.white, size: 22),
                    ),
                    Container(width: 2, height: 14, color: Colors.green),
                  ]),
                ),

                // Tujuan
                Marker(
                  point: widget.destination,
                  width: 40, height: 50,
                  child: Column(children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.flag_rounded,
                          color: Colors.white, size: 18),
                    ),
                    Container(
                        width: 2, height: 10,
                        color: const Color(0xFFFF3B30)),
                  ]),
                ),
              ]),
            ],
          ),

          // Loading
          if (_isLoadingRoute)
            Container(
              color: Colors.white.withOpacity(0.7),
              child: Center(
                child: CircularProgressIndicator(
                    color: widget.serviceColor),
              ),
            ),

          // ── Top bar ──────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        )],
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Color(0xFF0A0A0A), size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        )],
                      ),
                      child: Row(children: [
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: _isTracking
                                ? Colors.green
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isTracking
                              ? (_tripStarted
                                  ? 'Perjalanan dimulai 🚀'
                                  : _arrivedAtPickup
                                      ? 'Menunggu penumpang naik'
                                      : 'Menuju lokasi jemput')
                              : 'GPS belum aktif',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        if (_speedKmh > 0) ...[
                          const Spacer(),
                          Text('${_speedKmh.toStringAsFixed(0)} km/h',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: widget.serviceColor,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ]),
                    ),
                  ),
                ]),
              ),
            ),
          ),

          // ── Bottom panel driver ───────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildDriverPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20, offset: Offset(0, -4))],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Info penumpang
          Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: widget.serviceColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_rounded,
                  color: widget.serviceColor, size: 26),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.passengerName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                Text(
                  _tripStarted
                      ? '🏁 Menuju tujuan'
                      : _arrivedAtPickup
                          ? '⏳ Menunggu naik'
                          : '📍 Menuju lokasi jemput',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF666666)),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 16),

          // Order ID info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F9FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFFDDEEFF), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Order ID',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF888888))),
                Text(
                  widget.orderId,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: widget.serviceColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Tombol aksi berdasarkan status ───────────
          if (!_isTracking)
            // Mulai tracking GPS
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: _startTracking,
                icon: const Icon(Icons.gps_fixed_rounded),
                label: const Text('Aktifkan GPS & Mulai',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.serviceColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
              ),
            )
          else if (!_arrivedAtPickup)
            // Sudah tracking, belum sampai jemput
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _stopTracking,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF3B30),
                    side: const BorderSide(
                        color: Color(0xFFFF3B30), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  child: const Text('Batalkan',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _arrivedAtPickupAction,
                  icon: const Icon(Icons.location_on_rounded, size: 18),
                  label: const Text('Sudah Tiba di Jemput',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                ),
              ),
            ])
          else if (!_tripStarted)
            // Sudah di lokasi jemput, tunggu penumpang naik
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: _startTrip,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Penumpang Sudah Naik - Mulai Trip',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.serviceColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
              ),
            )
          else
            // Trip berjalan, tombol selesai
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: _finishTrip,
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Selesaikan Perjalanan',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AA55),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final paint = ui.Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}
