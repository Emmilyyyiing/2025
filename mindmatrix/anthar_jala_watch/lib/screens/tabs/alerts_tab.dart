import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/water_alert.dart';
import '../../utils/app_theme.dart';

class AlertsTab extends StatelessWidget {
  const AlertsTab({super.key});

  // In production, these come from Firestore via BorewellService.alertsStream()
  // Here we show representative static data for the prototype
  List<WaterAlert> get _mockAlerts => [
        WaterAlert(
          id: '1',
          zoneId: 'north_fields',
          zoneName: 'North Fields',
          severity: AlertSeverity.critical,
          title: 'Critical: North Fields zone',
          message:
              'Water table has dropped 18 ft since March. 7 borewells now yield under 1 inch. Immediate recharge action needed.',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        WaterAlert(
          id: '2',
          zoneId: 'main_street',
          zoneName: 'Main Street',
          severity: AlertSeverity.warning,
          title: 'Warning: Main Street area',
          message:
              'Average depth has reached 240 ft — approaching the critical threshold. Monitor borewell yield weekly.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        WaterAlert(
          id: '3',
          zoneId: 'ward3',
          zoneName: 'Ward 3',
          severity: AlertSeverity.info,
          title: 'Rain forecast: good recharge opportunity',
          message:
              'IMD forecasts 40 mm rainfall in the next 72 hours. Activate your recharge structures before it rains.',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AIRecommendation(),
          const SizedBox(height: 16),
          const Text('Active alerts',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 10),
          ..._mockAlerts.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AlertCard(alert: a),
              )),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final WaterAlert alert;
  const _AlertCard({required this.alert});

  Color get _borderColor {
    switch (alert.severity) {
      case AlertSeverity.critical:
        return AppTheme.danger;
      case AlertSeverity.warning:
        return AppTheme.secondary;
      case AlertSeverity.info:
        return const Color(0xFF378ADD);
    }
  }

  Color get _bgColor {
    switch (alert.severity) {
      case AlertSeverity.critical:
        return const Color(0xFFFCEBEB);
      case AlertSeverity.warning:
        return const Color(0xFFFAEEDA);
      case AlertSeverity.info:
        return const Color(0xFFE6F1FB);
    }
  }

  IconData get _icon {
    switch (alert.severity) {
      case AlertSeverity.critical:
        return Icons.warning_amber_rounded;
      case AlertSeverity.warning:
        return Icons.access_time_outlined;
      case AlertSeverity.info:
        return Icons.cloud_outlined;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    return DateFormat('dd MMM, h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border(
            left: BorderSide(color: _borderColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon, color: _borderColor, size: 17),
              const SizedBox(width: 6),
              Expanded(
                child: Text(alert.title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _borderColor)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(alert.message,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                  height: 1.5)),
          const SizedBox(height: 6),
          Text(_timeAgo(alert.createdAt),
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _AIRecommendation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                    color: Color(0xFFD4F0E0), shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome,
                    color: AppTheme.primary, size: 16),
              ),
              const SizedBox(width: 10),
              const Text('AI insight',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Based on 142 borewell logs in your area, water stress peaks in April–May. Starting recharge activities in February can prevent up to 60% of critical failures.',
            style: TextStyle(fontSize: 13, height: 1.6,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          const Text('Recommendation for red laterite soil:',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          _bullet('Build recharge pits before the monsoon (June).'),
          _bullet('Clean existing pits to remove silt from last season.'),
          _bullet('Coordinate with neighbours — cluster pits work better.'),
        ],
      ),
    );
  }

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• ',
                style: TextStyle(color: AppTheme.primary, fontSize: 13)),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 13, height: 1.4,
                      color: AppTheme.textPrimary)),
            ),
          ],
        ),
      );
}
