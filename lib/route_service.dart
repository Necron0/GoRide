import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// ══════════════════════════════════════════════════════
// RouteService - OpenRouteService API
// Gratis: 500 request/hari
// Daftar API key di: https://openrouteservice.org/
// ══════════════════════════════════════════════════════

class RouteService {
  // ⚠️ GANTI dengan API key kamu dari openrouteservice.org
  static const String _apiKey = 'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjI0YzIyYTUyZTA2ZTQ5MWRiM2UzNGFkNjg0NDEwZDIyIiwiaCI6Im11cm11cjY0In0=';
  static const String _baseUrl = 'https://api.openrouteservice.org';

  // Cache route agar tidak hit API terus
  static List<LatLng>? _cachedRoute;
  static LatLng? _cachedStart;
  static LatLng? _cachedEnd;

  // ════════════════════════════════════════════════════
  // Ambil route jalan dari A ke B
  // Profile: driving-car, cycling-regular, foot-walking
  // ════════════════════════════════════════════════════
  static Future<List<LatLng>> getRoute({
    required LatLng start,
    required LatLng end,
    String profile = 'driving-car',
  }) async {
    // Pakai cache kalau start/end sama
    if (_cachedRoute != null &&
        _cachedStart == start &&
        _cachedEnd == end) {
      return _cachedRoute!;
    }

    try {
      final uri = Uri.parse(
        '$_baseUrl/v2/directions/$profile'
        '?api_key=$_apiKey'
        '&start=${start.longitude},${start.latitude}'
        '&end=${end.longitude},${end.latitude}',
      );

      final response = await http.get(uri, headers: {
        'Accept': 'application/json, application/geo+json',
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        // Fallback: garis lurus kalau API gagal
        return _straightLine(start, end);
      }

      final data = jsonDecode(response.body);
      final coords = data['features'][0]['geometry']['coordinates'] as List;

      final route = coords
          .map((c) => LatLng(
                (c[1] as num).toDouble(),
                (c[0] as num).toDouble(),
              ))
          .toList();

      // Simpan cache
      _cachedRoute = route;
      _cachedStart = start;
      _cachedEnd = end;

      return route;
    } catch (e) {
      // Fallback kalau tidak ada internet / API error
      return _straightLine(start, end);
    }
  }

  // ════════════════════════════════════════════════════
  // Snap posisi driver ke titik terdekat di route
  // Ini yang bikin driver "ngikutin jalan" bukan melayang
  // ════════════════════════════════════════════════════
  static LatLng snapToRoute(LatLng driverPos, List<LatLng> route) {
    if (route.isEmpty) return driverPos;

    LatLng closest = route.first;
    double minDist = double.infinity;

    for (int i = 0; i < route.length - 1; i++) {
      // Proyeksikan driver ke segmen jalan
      final snapped = _projectPointToSegment(
        driverPos,
        route[i],
        route[i + 1],
      );
      final dist = _distance(driverPos, snapped);
      if (dist < minDist) {
        minDist = dist;
        closest = snapped;
      }
    }

    // Kalau driver > 50m dari route, pakai posisi asli
    // (mungkin driver belok ke jalan lain)
    return minDist < 0.0005 ? closest : driverPos;
  }

  // ════════════════════════════════════════════════════
  // Animasi smooth: interpolasi posisi antara dua titik
  // Panggil ini tiap frame untuk gerakan halus
  // ════════════════════════════════════════════════════
  static LatLng interpolate(LatLng from, LatLng to, double t) {
    // t = 0.0 (di from) sampai 1.0 (di to)
    t = t.clamp(0.0, 1.0);
    return LatLng(
      from.latitude + (to.latitude - from.latitude) * t,
      from.longitude + (to.longitude - from.longitude) * t,
    );
  }

  // ════════════════════════════════════════════════════
  // Hitung indeks posisi driver di sepanjang route
  // Untuk tahu sudah lewat berapa % dari perjalanan
  // ════════════════════════════════════════════════════
  static double getProgressAlongRoute(
      LatLng driverPos, List<LatLng> route) {
    if (route.length < 2) return 0.0;

    double totalDist = 0;
    double distToDriver = 0;
    double minDist = double.infinity;
    int closestIdx = 0;

    for (int i = 0; i < route.length - 1; i++) {
      totalDist += _distance(route[i], route[i + 1]);
      final d = _distance(driverPos, route[i]);
      if (d < minDist) {
        minDist = d;
        closestIdx = i;
      }
    }

    for (int i = 0; i < closestIdx; i++) {
      distToDriver += _distance(route[i], route[i + 1]);
    }

    return totalDist > 0 ? (distToDriver / totalDist).clamp(0.0, 1.0) : 0.0;
  }

  // ── Helper: Proyeksi titik ke segmen garis ────────
  static LatLng _projectPointToSegment(
      LatLng point, LatLng segStart, LatLng segEnd) {
    double dx = segEnd.longitude - segStart.longitude;
    double dy = segEnd.latitude - segStart.latitude;
    double lenSq = dx * dx + dy * dy;

    if (lenSq == 0) return segStart;

    double t = ((point.longitude - segStart.longitude) * dx +
            (point.latitude - segStart.latitude) * dy) /
        lenSq;

    t = t.clamp(0.0, 1.0);

    return LatLng(
      segStart.latitude + t * dy,
      segStart.longitude + t * dx,
    );
  }

  // ── Helper: Jarak antara dua LatLng (approx) ─────
  static double _distance(LatLng a, LatLng b) {
    double dlat = a.latitude - b.latitude;
    double dlng = a.longitude - b.longitude;
    return dlat * dlat + dlng * dlng;
  }

  // ── Fallback: garis lurus kalau API gagal ─────────
  static List<LatLng> _straightLine(LatLng start, LatLng end) {
    // Buat 20 titik interpolasi supaya tetap smooth
    return List.generate(
      20,
      (i) => interpolate(start, end, i / 19),
    );
  }
}
