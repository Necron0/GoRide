import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

// ══════════════════════════════════════════════════════
// FirebaseTrackingService
// - Driver: upload GPS tiap 2 detik ke Firebase
// - Pelanggan: listen perubahan GPS driver dari Firebase
// ══════════════════════════════════════════════════════

class FirebaseTrackingService {
  static final FirebaseDatabase _db = FirebaseDatabase.instance;

  // ── PATH di Firebase: /rides/{orderId}/driver_location ──
  static DatabaseReference _driverRef(String orderId) =>
      _db.ref('rides/$orderId/driver_location');

  static DatabaseReference _orderRef(String orderId) =>
      _db.ref('rides/$orderId');

  // ════════════════════════════════════════════════════
  // DRIVER SIDE: Upload GPS ke Firebase
  // ════════════════════════════════════════════════════

  static StreamSubscription<Position>? _gpsSubscription;

  /// Mulai upload GPS driver ke Firebase secara realtime
  static Future<void> startDriverTracking(String orderId) async {
    // Minta permission GPS
    bool hasPermission = await _requestLocationPermission();
    if (!hasPermission) return;

    // Stream GPS dari device, update setiap 2 detik / 5 meter
    _gpsSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // update kalau bergerak > 5 meter
      ),
    ).listen((Position position) {
      _uploadDriverLocation(orderId, position);
    });
  }

  /// Upload satu posisi GPS ke Firebase
  static Future<void> _uploadDriverLocation(
      String orderId, Position position) async {
    await _driverRef(orderId).set({
      'lat': position.latitude,
      'lng': position.longitude,
      'heading': position.heading,      // arah hadap (derajat)
      'speed': position.speed,          // kecepatan m/s
      'accuracy': position.accuracy,    // akurasi GPS meter
      'timestamp': ServerValue.timestamp,
    });
  }

  /// Hentikan upload GPS driver
  static void stopDriverTracking() {
    _gpsSubscription?.cancel();
    _gpsSubscription = null;
  }

  // ════════════════════════════════════════════════════
  // PELANGGAN SIDE: Listen GPS driver dari Firebase
  // ════════════════════════════════════════════════════

  /// Stream posisi driver yang didengarkan pelanggan
  static Stream<LatLng> listenDriverLocation(String orderId) {
    return _driverRef(orderId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return const LatLng(0, 0);
      return LatLng(
        (data['lat'] as num).toDouble(),
        (data['lng'] as num).toDouble(),
      );
    });
  }

  /// Stream data lengkap driver (termasuk heading, speed)
  static Stream<DriverData> listenDriverData(String orderId) {
    return _driverRef(orderId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return DriverData.empty();
      return DriverData(
        position: LatLng(
          (data['lat'] as num).toDouble(),
          (data['lng'] as num).toDouble(),
        ),
        heading: (data['heading'] as num?)?.toDouble() ?? 0,
        speed: (data['speed'] as num?)?.toDouble() ?? 0,
        timestamp: data['timestamp'] as int? ?? 0,
      );
    });
  }

  // ════════════════════════════════════════════════════
  // ORDER STATUS: Update & listen status pesanan
  // ════════════════════════════════════════════════════

  static Future<void> updateOrderStatus(
      String orderId, String status) async {
    await _orderRef(orderId).update({'status': status});
  }

  static Stream<String> listenOrderStatus(String orderId) {
    return _orderRef(orderId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      return data?['status'] as String? ?? 'waiting';
    });
  }

  // ════════════════════════════════════════════════════
  // HELPER: Request permission GPS
  // ════════════════════════════════════════════════════

  static Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return false;
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Ambil posisi GPS saat ini (sekali)
  static Future<LatLng?> getCurrentPosition() async {
    bool hasPermission = await _requestLocationPermission();
    if (!hasPermission) return null;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      return null;
    }
  }
}

// ── Model data driver ─────────────────────────────────
class DriverData {
  final LatLng position;
  final double heading;
  final double speed;
  final int timestamp;

  const DriverData({
    required this.position,
    required this.heading,
    required this.speed,
    required this.timestamp,
  });

  factory DriverData.empty() => const DriverData(
        position: LatLng(0, 0),
        heading: 0,
        speed: 0,
        timestamp: 0,
      );

  bool get isValid => position.latitude != 0 && position.longitude != 0;

  /// Kecepatan dalam km/h
  double get speedKmh => speed * 3.6;
}
