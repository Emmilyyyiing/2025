import 'package:cloud_firestore/cloud_firestore.dart';

enum AlertSeverity { info, warning, critical }

class WaterAlert {
  final String id;
  final String zoneId;
  final String zoneName;
  final AlertSeverity severity;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  WaterAlert({
    required this.id,
    required this.zoneId,
    required this.zoneName,
    required this.severity,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  factory WaterAlert.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return WaterAlert(
      id: doc.id,
      zoneId: d['zoneId'] ?? '',
      zoneName: d['zoneName'] ?? '',
      severity: AlertSeverity.values.byName(d['severity'] ?? 'info'),
      title: d['title'] ?? '',
      message: d['message'] ?? '',
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      isRead: d['isRead'] as bool? ?? false,
    );
  }
}
