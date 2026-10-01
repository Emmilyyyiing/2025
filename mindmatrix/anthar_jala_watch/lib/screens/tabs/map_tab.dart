import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../services/borewell_service.dart';
import '../../models/borewell_entry.dart';
import '../../utils/app_theme.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  GoogleMapController? _mapController;
  final Set<Circle> _circles = {};

  static const LatLng _defaultCenter =
      LatLng(12.9716, 77.5946); // Bengaluru

  @override
  Widget build(BuildContext context) {
    final service = context.watch<BorewellService>();

    // Build circles for each zone
    _circles.clear();
    for (final zone in service.zones) {
      final color = WaterZoneColors.forDepth(zone.avgDepthFt);
      _circles.add(Circle(
        circleId: CircleId(zone.zoneId),
        center: LatLng(
            zone.center.latitude, zone.center.longitude),
        radius: 400,
        fillColor: color.withOpacity(0.35),
        strokeColor: color.withOpacity(0.7),
        strokeWidth: 1,
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Water Stress Map',
                style: TextStyle(fontSize: 17, color: Colors.white)),
            Text('Tap a zone for details',
                style: TextStyle(
                    fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => service.fetchZones(),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
                target: _defaultCenter, zoom: 13),
            circles: _circles,
            onMapCreated: (ctrl) => _mapController = ctrl,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          // Legend
          Positioned(
            bottom: 16,
            left: 16,
            child: _Legend(),
          ),
          // Summary card
          Positioned(
            top: 12,
            right: 12,
            child: _SummaryCard(zones: service.zones.length,
                critical: service.criticalZoneCount),
          ),
          if (service.loading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: AppTheme.primary,
        onPressed: () {
          _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(_defaultCenter, 13));
        },
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Water level',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _row(const Color(0xFF1A6E3C), 'Good  (< 100 ft)'),
          _row(const Color(0xFFE6B830), 'Stress (100–250 ft)'),
          _row(const Color(0xFFC0392B), 'Critical (> 250 ft)'),
        ],
      ),
    );
  }

  Widget _row(Color color, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Row(
          children: [
            Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      );
}

class _SummaryCard extends StatelessWidget {
  final int zones;
  final int critical;

  const _SummaryCard({required this.zones, required this.critical});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stat('$zones', 'zones'),
          const SizedBox(width: 14),
          _stat('$critical', 'critical',
              color: critical > 0 ? AppTheme.danger : AppTheme.textSecondary),
        ],
      ),
    );
  }

  Widget _stat(String val, String lbl, {Color color = AppTheme.textPrimary}) =>
      Column(
        children: [
          Text(val,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(lbl,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textSecondary)),
        ],
      );
}
