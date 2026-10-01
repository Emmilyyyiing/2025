import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class WaterDepthScale extends StatelessWidget {
  const WaterDepthScale({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Water depth guide',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary)),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient bar
              Container(
                width: 20,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1A6E3C),
                      Color(0xFFE6B830),
                      Color(0xFFC0392B),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Labels
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ScaleItem(
                      color: const Color(0xFF1A6E3C),
                      label: 'Healthy',
                      depth: '< 100 ft',
                      desc: 'Good recharge. Seasonal rains restore the table.',
                    ),
                    const SizedBox(height: 20),
                    _ScaleItem(
                      color: const Color(0xFFE6B830),
                      label: 'Stressed',
                      depth: '100–250 ft',
                      desc: 'Monitor weekly. Start recharge activities.',
                    ),
                    const SizedBox(height: 20),
                    _ScaleItem(
                      color: const Color(0xFFC0392B),
                      label: 'Critical',
                      depth: '> 250 ft',
                      desc: 'Recharge urgently. Stop new borewell drilling.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScaleItem extends StatelessWidget {
  final Color color;
  final String label;
  final String depth;
  final String desc;

  const _ScaleItem({
    required this.color,
    required this.label,
    required this.depth,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 3),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontFamily: 'Roboto'),
                  children: [
                    TextSpan(
                        text: label,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: color,
                            fontSize: 13)),
                    TextSpan(
                        text: '  $depth',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(desc,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
