import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/borewell_entry.dart';
import '../models/water_alert.dart';

class BorewellService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<ZoneSummary> _zones = [];
  List<BorewellEntry> _recentEntries = [];
  List<WaterAlert> _alerts = [];
  bool _loading = false;

  List<ZoneSummary> get zones => _zones;
  List<BorewellEntry> get recentEntries => _recentEntries;
  List<WaterAlert> get alerts => _alerts;
  bool get loading => _loading;

  int get criticalZoneCount =>
      _zones.where((z) => z.stressScore > 0.6).length;

  /// Fetch all zone summaries for heatmap rendering
  Future<void> fetchZones() async {
    _loading = true;
    notifyListeners();
    final snap = await _db.collection('zones').get();
    _zones = snap.docs.map((d) => ZoneSummary.fromFirestore(d)).toList();
    _loading = false;
    notifyListeners();
  }

  /// Listen to recent borewell entries (last 20)
  Stream<List<BorewellEntry>> recentEntriesStream() {
    return _db
        .collection('borewells')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((s) => s.docs.map((d) => BorewellEntry.fromFirestore(d)).toList());
  }

  /// Listen to alerts for a zone
  Stream<List<WaterAlert>> alertsStream(String zoneId) {
    return _db
        .collection('alerts')
        .where('zoneId', isEqualTo: zoneId)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((s) => s.docs.map((d) => WaterAlert.fromFirestore(d)).toList());
  }

  /// Submit a new borewell log
  Future<void> submitBorewell({
    required String userId,
    required double depthFt,
    required int yearDrilled,
    required WaterYield yield,
    double? currentWaterLevelFt,
    String? notes,
    required Position position,
  }) async {
    // Anonymise location: snap to 500m grid
    final anonLocation = _snapToGrid(position.latitude, position.longitude);
    final zoneId = _zoneIdFromLatLng(anonLocation.$1, anonLocation.$2);

    final entry = BorewellEntry(
      id: '',
      userId: userId,
      depthFt: depthFt,
      yearDrilled: yearDrilled,
      yield: yield,
      currentWaterLevelFt: currentWaterLevelFt,
      notes: notes,
      anonymisedLocation: GeoPoint(anonLocation.$1, anonLocation.$2),
      zoneId: zoneId,
      createdAt: DateTime.now(),
    );

    // Write to borewells collection
    await _db.collection('borewells').add(entry.toFirestore());

    // Update zone aggregate (Cloud Function also does this server-side)
    await _updateZoneAggregate(zoneId, entry);
    notifyListeners();
  }

  /// Snap lat/lng to nearest 500m grid cell (~0.005 degrees)
  (double, double) _snapToGrid(double lat, double lng) {
    const gridSize = 0.005; // ~500m
    final snappedLat = (lat / gridSize).round() * gridSize;
    final snappedLng = (lng / gridSize).round() * gridSize;
    return (snappedLat, snappedLng);
  }

  String _zoneIdFromLatLng(double lat, double lng) {
    // Encode grid cell as zone ID string
    final latStr = lat.toStringAsFixed(3).replaceAll('.', '_');
    final lngStr = lng.toStringAsFixed(3).replaceAll('.', '_');
    return 'zone_${latStr}_$lngStr';
  }

  Future<void> _updateZoneAggregate(
      String zoneId, BorewellEntry newEntry) async {
    final zoneRef = _db.collection('zones').doc(zoneId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(zoneRef);
      if (!snap.exists) {
        tx.set(zoneRef, {
          'zoneName': zoneId,
          'center': newEntry.anonymisedLocation,
          'avgDepthFt': newEntry.depthFt,
          'totalBorewells': 1,
          'criticalCount': newEntry.depthFt >= 250 ? 1 : 0,
          'stressScore': newEntry.stressScore,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        final data = snap.data()!;
        final total = (data['totalBorewells'] as int) + 1;
        final prevAvg = (data['avgDepthFt'] as num).toDouble();
        final newAvg = ((prevAvg * (total - 1)) + newEntry.depthFt) / total;
        final critCount = (data['criticalCount'] as int? ?? 0) +
            (newEntry.depthFt >= 250 ? 1 : 0);
        tx.update(zoneRef, {
          'avgDepthFt': newAvg,
          'totalBorewells': total,
          'criticalCount': critCount,
          'stressScore': (newAvg / 500.0).clamp(0.0, 1.0),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  /// Get current GPS location with permission handling
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw 'Location services are disabled.';

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) throw 'Location permission denied.';
    }
    if (perm == LocationPermission.deniedForever) {
      throw 'Location permission permanently denied. Enable it in Settings.';
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  double distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0;
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final dPhi = (lat2 - lat1) * pi / 180;
    final dLam = (lon2 - lon1) * pi / 180;
    final a = sin(dPhi / 2) * sin(dPhi / 2) +
        cos(phi1) * cos(phi2) * sin(dLam / 2) * sin(dLam / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }
}
