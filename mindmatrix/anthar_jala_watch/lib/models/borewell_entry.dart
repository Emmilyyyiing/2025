import 'package:cloud_firestore/cloud_firestore.dart';

enum WaterYield { good, moderate, low, dry }

class BorewellEntry {
  final String id;
  final String userId;
  final double depthFt;
  final int yearDrilled;
  final WaterYield yield;
  final double? currentWaterLevelFt;
  final String? notes;
  // Anonymised: snapped to ~500m grid cell, not exact house
  final GeoPoint anonymisedLocation;
  final String zoneId; // e.g. "ward3_cell_42"
  final DateTime createdAt;

  BorewellEntry({
    required this.id,
    required this.userId,
    required this.depthFt,
    required this.yearDrilled,
    required this.yield,
    this.currentWaterLevelFt,
    this.notes,
    required this.anonymisedLocation,
    required this.zoneId,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'depthFt': depthFt,
        'yearDrilled': yearDrilled,
        'yield': yield.name,
        'currentWaterLevelFt': currentWaterLevelFt,
        'notes': notes,
        'anonymisedLocation': anonymisedLocation,
        'zoneId': zoneId,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory BorewellEntry.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return BorewellEntry(
      id: doc.id,
      userId: d['userId'] ?? '',
      depthFt: (d['depthFt'] as num).toDouble(),
      yearDrilled: d['yearDrilled'] as int,
      yield: WaterYield.values.byName(d['yield'] ?? 'moderate'),
      currentWaterLevelFt: (d['currentWaterLevelFt'] as num?)?.toDouble(),
      notes: d['notes'] as String?,
      anonymisedLocation: d['anonymisedLocation'] as GeoPoint,
      zoneId: d['zoneId'] ?? '',
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  double get stressScore {
    double score = depthFt / 500.0; // 0-1 based on depth
    if (yield == WaterYield.dry) score = (score + 1.0).clamp(0, 1);
    if (yield == WaterYield.low) score = (score + 0.5).clamp(0, 1);
    return score.clamp(0.0, 1.0);
  }
}

class ZoneSummary {
  final String zoneId;
  final String zoneName;
  final GeoPoint center;
  final double avgDepthFt;
  final int totalBorewells;
  final int criticalCount;
  final double stressScore; // 0.0 = healthy, 1.0 = critical
  final DateTime lastUpdated;

  ZoneSummary({
    required this.zoneId,
    required this.zoneName,
    required this.center,
    required this.avgDepthFt,
    required this.totalBorewells,
    required this.criticalCount,
    required this.stressScore,
    required this.lastUpdated,
  });

  factory ZoneSummary.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ZoneSummary(
      zoneId: doc.id,
      zoneName: d['zoneName'] ?? doc.id,
      center: d['center'] as GeoPoint,
      avgDepthFt: (d['avgDepthFt'] as num).toDouble(),
      totalBorewells: d['totalBorewells'] as int,
      criticalCount: d['criticalCount'] as int? ?? 0,
      stressScore: (d['stressScore'] as num).toDouble(),
      lastUpdated: (d['lastUpdated'] as Timestamp).toDate(),
    );
  }
}
