import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'firebase_tracking_service.dart';
import 'route_service.dart';

// ══════════════════════════════════════════════════════
// TrackingScreen v2
// - Pelanggan melihat driver bergerak REALTIME dari Firebase
// - Driver snapped ke jalan (OpenRouteService)
// - Animasi smooth interpolasi antar posisi GPS
// ══════════════════════════════════════════════════════

class TrackingScreen extends StatefulWidget {
  final String serviceName;
  final Color serviceColor;
  final IconData serviceIcon;
  final String orderId;          // ID pesanan (dari Firebase)
  final String driverName;
  final String driverPhone;
  final String plateNumber;
  final LatLng userLocation;     // Lokasi jemput
  final LatLng destination;      // Lokasi tujuan

  const TrackingScreen({
    super.key,
    required this.serviceName,
    required this.serviceColor,
    required this.serviceIcon,
    required this.orderId,
    required this.userLocation,
    required this.destination,
    this.driverName = 'Budi Santoso',
    this.driverPhone = '0812-3456-7890',
    this.plateNumber = 'N 4567 RX',
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with TickerProviderStateMixin {

  final MapController _mapController = MapController();

  // ── Posisi driver (tampil di peta) ────────────────
  late LatLng _displayDriverPos;   // posisi yang dirender (smooth)
  LatLng? _targetDriverPos;        // posisi terbaru dari Firebase
  LatLng? _prevDriverPos;          // posisi sebelumnya

  // ── Route jalan dari ORS ──────────────────────────
  List<LatLng> _routePoints = [];
  List<LatLng> _drivenPath = [];   // jejak yang sudah dilalui driver

  // ── State ─────────────────────────────────────────
  bool _isLoadingRoute = true;
  bool _isFollowingDriver = true;
  bool _arrived = false;
  String _statusText = 'Mencari driver...';
  double _etaMinutes = 0;
  double _progressPercent = 0;
  double _driverHeading = 0;
  double _driverSpeedKmh = 0;

  // ── Animasi smooth driver marker ──────────────────
  late AnimationController _smoothController;
  late Animation<double> _smoothAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // ── Stream subscriptions ──────────────────────────
  StreamSubscription<DriverData>? _driverSub;
  StreamSubscription<String>? _statusSub;

  @override
  void initState() {
    super.initState();
    _displayDriverPos = widget.userLocation; // sementara sebelum dapat GPS

    // Animasi smooth perpindahan marker driver
    _smoothController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _smoothAnimation = CurvedAnimation(
      parent: _smoothController,
      curve: Curves.easeInOut,
    );

    // Animasi pulse marker user
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Load route jalan dari OpenRouteService
    _loadRoute();

    // Mulai listen GPS driver dari Firebase
    _listenDriverFromFirebase();
    _listenOrderStatus();
  }

  @override
  void dispose() {
    _smoothController.dispose();
    _pulseController.dispose();
    _driverSub?.cancel();
    _statusSub?.cancel();
    super.dispose();
  }

  // ════════════════════════════════════════════════════
  // Load route jalan dari OpenRouteService
  // ════════════════════════════════════════════════════
  Future<void> _loadRoute() async {
    setState(() => _isLoadingRoute = true);

    // Ambil route dari posisi awal driver ke lokasi user
    // (nanti bisa update start saat dapat posisi driver pertama)
    final route = await RouteService.getRoute(
      start: widget.userLocation,
      end: widget.destination,
      profile: widget.serviceName == 'GoRide' || widget.serviceName == 'GoCar'
          ? 'driving-car'
          : 'foot-walking',
    );

    setState(() {
      _routePoints = route;
      _isLoadingRoute = false;
    });
  }

  // ════════════════════════════════════════════════════
  // Listen posisi driver dari Firebase (PELANGGAN)
  // ════════════════════════════════════════════════════
  void _listenDriverFromFirebase() {
    _driverSub = FirebaseTrackingService
        .listenDriverData(widget.orderId)
        .listen((DriverData data) {
      if (!data.isValid) return;

      // Snap posisi driver ke jalan terdekat
      final snappedPos = _routePoints.isNotEmpty
          ? RouteService.snapToRoute(data.position, _routePoints)
          : data.position;

      setState(() {
        _prevDriverPos = _displayDriverPos;
        _targetDriverPos = snappedPos;
        _driverHeading = data.heading;
        _driverSpeedKmh = data.speedKmh;

        // Tambah jejak yang sudah dilalui
        _drivenPath.add(snappedPos);
        if (_drivenPath.length > 500) _drivenPath.removeAt(0);

        // Update progress
        if (_routePoints.isNotEmpty) {
          _progressPercent = RouteService.getProgressAlongRoute(
              snappedPos, _routePoints);
        }

        // Update status
        _updateStatus(snappedPos);
      });

      // Animasi smooth dari posisi lama ke posisi baru
      _animateSmoothMove();
    });
  }

  // ════════════════════════════════════════════════════
  // Animasi smooth perpindahan marker driver
  // ════════════════════════════════════════════════════
  void _animateSmoothMove() {
    if (_prevDriverPos == null || _targetDriverPos == null) return;

    final from = _prevDriverPos!;
    final to = _targetDriverPos!;

    _smoothController.reset();

    _smoothAnimation.addListener(() {
      if (!mounted) return;
      setState(() {
        _displayDriverPos = RouteService.interpolate(
          from,
          to,
          _smoothAnimation.value,
        );

        // Auto-follow kamera mengikuti driver
        if (_isFollowingDriver) {
          _mapController.move(_displayDriverPos, 16.5);
        }
      });
    });

    _smoothController.forward();
  }

  // ── Update status teks berdasarkan jarak ──────────
  void _updateStatus(LatLng driverPos) {
    final dist = _calcDistance(driverPos, widget.userLocation);

    if (dist < 0.001) {
      _statusText = '🎉 Driver sudah tiba!';
      _etaMinutes = 0;
      if (!_arrived) {
        _arrived = true;
        _showArrivalDialog();
      }
    } else if (dist < 0.005) {
      _statusText = 'Driver hampir tiba... 🏍️';
      _etaMinutes = (dist * 1000 / 8).roundToDouble(); // ~8m/s
    } else if (dist < 0.015) {
      _statusText = 'Driver sudah dekat!';
      _etaMinutes = (dist * 1000 / 8).roundToDouble();
    } else {
      _statusText = 'Driver dalam perjalanan';
      _etaMinutes = (dist * 1000 / 8).roundToDouble();
    }
  }

  void _listenOrderStatus() {
    _statusSub = FirebaseTrackingService
        .listenOrderStatus(widget.orderId)
        .listen((status) {
      if (status == 'arrived') {
        setState(() {
          _statusText = '🎉 Driver sudah tiba!';
          _arrived = true;
        });
      }
    });
  }

  double _calcDistance(LatLng a, LatLng b) {
    double dlat = a.latitude - b.latitude;
    double dlng = a.longitude - b.longitude;
    return (dlat * dlat + dlng * dlng);
  }

  String get _etaString {
    if (_etaMinutes <= 0) return 'Tiba!';
    if (_etaMinutes < 60) return '${_etaMinutes.toInt()} dtk';
    return '${(_etaMinutes / 60).toInt()} mnt';
  }

  void _showArrivalDialog() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isDismissible: false,
        builder: (ctx) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: widget.serviceColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded,
                    color: widget.serviceColor, size: 44),
              ),
              const SizedBox(height: 16),
              const Text('Driver Sudah Tiba! 🎉',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                '${widget.driverName} sedang menunggumu.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF666666), height: 1.6),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.serviceColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  child: const Text('Selesai',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── PETA ──────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _displayDriverPos,
              initialZoom: 15.5,
              onTap: (_, __) =>
                  setState(() => _isFollowingDriver = false),
            ),
            children: [
              // Tile OpenStreetMap
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.gojek',
              ),

              // ── Garis route penuh (abu-abu) ────────
              if (_routePoints.isNotEmpty)
                PolylineLayer(polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 5,
                    color: Colors.grey.shade300,
                  ),
                ]),

              // ── Garis yang sudah dilalui driver (biru) ──
              if (_drivenPath.isNotEmpty)
                PolylineLayer(polylines: [
                  Polyline(
                    points: _drivenPath,
                    strokeWidth: 5,
                    color: widget.serviceColor.withOpacity(0.8),
                    strokeCap: StrokeCap.round,
                    strokeJoin: StrokeJoin.round,
                  ),
                ]),

              // ── Markers ────────────────────────────
              MarkerLayer(markers: [
                // Marker User (pulse)
                Marker(
                  point: widget.userLocation,
                  width: 60, height: 60,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (_, child) => Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    ),
                    child: Stack(alignment: Alignment.center, children: [
                      Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          color: widget.serviceColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: widget.serviceColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [BoxShadow(
                            color: widget.serviceColor.withOpacity(0.4),
                            blurRadius: 8, spreadRadius: 2,
                          )],
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ]),
                  ),
                ),

                // Marker Driver (rotasi sesuai heading)
                Marker(
                  point: _displayDriverPos,
                  width: 56, height: 76,
                  child: Column(children: [
                    Transform.rotate(
                      angle: _driverHeading * (3.14159 / 180),
                      child: Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10, offset: const Offset(0, 3),
                          )],
                        ),
                        child: Icon(widget.serviceIcon,
                            color: widget.serviceColor, size: 26),
                      ),
                    ),
                    CustomPaint(
                      size: const Size(12, 8),
                      painter: _TrianglePainter(Colors.white),
                    ),
                  ]),
                ),

                // Marker Tujuan
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
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                        )],
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

          // ── Loading overlay kalau route belum siap ──
          if (_isLoadingRoute)
            Container(
              color: Colors.white.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: widget.serviceColor),
                    const SizedBox(height: 12),
                    const Text('Memuat rute perjalanan...',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

          // ── Top bar ───────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Row(children: [
                  // Back
                  _circleButton(
                    icon: Icons.arrow_back_rounded,
                    color: Colors.white,
                    iconColor: const Color(0xFF0A0A0A),
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),

                  // Status
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8)],
                      ),
                      child: Row(children: [
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: _arrived
                                ? Colors.green
                                : widget.serviceColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_statusText,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis),
                        ),
                        // Kecepatan driver
                        if (_driverSpeedKmh > 0)
                          Text('${_driverSpeedKmh.toStringAsFixed(0)} km/h',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: widget.serviceColor,
                                  fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Re-center
                  _circleButton(
                    icon: Icons.my_location_rounded,
                    color: _isFollowingDriver
                        ? widget.serviceColor
                        : Colors.white,
                    iconColor: _isFollowingDriver
                        ? Colors.white
                        : const Color(0xFF0A0A0A),
                    onTap: () {
                      setState(() => _isFollowingDriver = true);
                      _mapController.move(_displayDriverPos, 16.5);
                    },
                  ),
                ]),
              ),
            ),
          ),

          // ── Progress bar perjalanan ───────────────────
          Positioned(
            top: 100, left: 16, right: 16,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8)],
                ),
                child: Row(children: [
                  Icon(widget.serviceIcon,
                      color: widget.serviceColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progressPercent,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(
                            widget.serviceColor),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${(_progressPercent * 100).toInt()}%',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: widget.serviceColor)),
                ]),
              ),
            ),
          ),

          // ── Bottom card driver ───────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildDriverCard(),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.1), blurRadius: 8)],
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildDriverCard() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -4))],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // ETA card
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.serviceColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Info speed
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _driverSpeedKmh > 0
                          ? '${_driverSpeedKmh.toStringAsFixed(0)} km/h'
                          : 'Menunggu GPS...',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0A0A0A)),
                    ),
                    const Text('kecepatan driver',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF888888))),
                  ],
                ),

                // ETA
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_etaString,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: widget.serviceColor)),
                    const Text('estimasi tiba',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF888888))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Info driver
          Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: widget.serviceColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: widget.serviceColor.withOpacity(0.3), width: 2),
              ),
              child: Icon(Icons.person_rounded,
                  color: widget.serviceColor, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.driverName,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  Row(children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFFFA500), size: 14),
                    const Text(' 4.9 · ',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFF555555))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(widget.plateNumber,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: widget.serviceColor)),
                    ),
                  ]),
                ],
              ),
            ),
            // Telepon
            GestureDetector(
              onTap: _showContactOptions,
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: widget.serviceColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.phone_rounded,
                    color: widget.serviceColor, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            // Chat
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Fitur chat segera hadir! 💬'),
                  backgroundColor: widget.serviceColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded,
                    color: Color(0xFF555555), size: 20),
              ),
            ),
          ]),
          const SizedBox(height: 12),

          // Tombol bagikan & darurat
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Link lokasi disalin! 📍'),
                    backgroundColor: widget.serviceColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                icon: const Icon(Icons.share_location_rounded, size: 16),
                label: const Text('Bagikan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.serviceColor,
                  side: BorderSide(
                      color: widget.serviceColor.withOpacity(0.4),
                      width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bantuan darurat dikirim! 🚨'),
                    backgroundColor: Color(0xFFFF3B30),
                    behavior: SnackBarBehavior.floating,
                  ),
                ),
                icon: const Icon(Icons.emergency_rounded, size: 16),
                label: const Text('Darurat'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF3B30),
                  side: const BorderSide(
                      color: Color(0xFFFF3B30), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  void _showContactOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hubungi ${widget.driverName}',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.call_rounded,
                    color: Colors.green, size: 20),
              ),
              title: const Text('Telepon Driver'),
              subtitle: Text(widget.driverPhone),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.message_rounded,
                    color: Colors.blue, size: 20),
              ),
              title: const Text('WhatsApp Driver'),
              subtitle: Text(widget.driverPhone),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Segitiga bawah marker driver ──────────────────────
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