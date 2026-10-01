import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class RechargeTab extends StatelessWidget {
  const RechargeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recharge Guide')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _infoBox(),
          const SizedBox(height: 16),
          _RechargeCard(
            icon: Icons.terrain_outlined,
            title: 'Recharge pit',
            difficulty: 'Easy · DIY',
            difficultyColor: AppTheme.primary,
            steps: const [
              'Dig a 3 × 3 ft pit, 4 ft deep near your borewell.',
              'Layer the bottom with gravel (1 ft), then coarse sand (1 ft), then charcoal (6 inches).',
              'Cover the top with a wire mesh to prevent debris.',
              'Ensure water from your roof or courtyard drains into it during rain.',
            ],
            tip: 'One recharge pit can replenish ~50,000 litres per rain season.',
            diagramWidget: _RechargePitDiagram(),
          ),
          const SizedBox(height: 12),
          _RechargeCard(
            icon: Icons.home_outlined,
            title: 'Rooftop rainwater harvesting',
            difficulty: 'Moderate',
            difficultyColor: AppTheme.secondary,
            steps: const [
              'Collect all roof drainpipes into one main pipe.',
              'Install a first-flush diverter (discards first 20 litres of dirty water).',
              'Connect to a storage tank with sand/gravel filter.',
              'Overflow from the tank should drain into a soakpit or recharge well.',
            ],
            tip: 'A 1,000 sq ft roof can collect 60,000 litres per year in Bangalore rainfall.',
          ),
          const SizedBox(height: 12),
          _RechargeCard(
            icon: Icons.arrow_downward_outlined,
            title: 'Borewell recharge shaft',
            difficulty: 'Advanced',
            difficultyColor: Colors.orange,
            steps: const [
              'Drill a 6-inch diameter hole adjacent to your existing borewell, 20–30 ft deep.',
              'Insert a PVC pipe with holes perforated every 6 inches.',
              'Pack the annular space with gravel.',
              'Place a sand-gravel filter basket at the top to block silt.',
              'Route rooftop or courtyard runoff into this shaft during monsoon.',
            ],
            tip: 'This method directly recharges the same aquifer your borewell draws from.',
          ),
          const SizedBox(height: 20),
          _CommunityTracker(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _infoBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE1F5EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppTheme.primary.withOpacity(0.2), width: 0.5),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.eco_outlined, color: AppTheme.primary, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Why recharge?',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryDark,
                        fontSize: 14)),
                SizedBox(height: 4),
                Text(
                  'Every litre you recharge goes back into the same aquifer your community depends on. Recharge is 10× cheaper than drilling a new borewell.',
                  style: TextStyle(
                      color: AppTheme.primaryDark,
                      fontSize: 12,
                      height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RechargeCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String difficulty;
  final Color difficultyColor;
  final List<String> steps;
  final String tip;
  final Widget? diagramWidget;

  const _RechargeCard({
    required this.icon,
    required this.title,
    required this.difficulty,
    required this.difficultyColor,
    required this.steps,
    required this.tip,
    this.diagramWidget,
  });

  @override
  State<_RechargeCard> createState() => _RechargeCardState();
}

class _RechargeCardState extends State<_RechargeCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4F0E0),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon,
                        color: AppTheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                widget.difficultyColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(widget.difficulty,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: widget.difficultyColor,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                      _expanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.diagramWidget != null) ...[
                    widget.diagramWidget!,
                    const SizedBox(height: 14),
                  ],
                  const Text('Steps',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  ...widget.steps.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.only(
                                  top: 1, right: 10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFD4F0E0),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text('${e.key + 1}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.primary,
                                        fontWeight:
                                            FontWeight.bold)),
                              ),
                            ),
                            Expanded(
                              child: Text(e.value,
                                  style: const TextStyle(
                                      fontSize: 13, height: 1.5,
                                      color: AppTheme.textPrimary)),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAEEDA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            color: AppTheme.secondary, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(widget.tip,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF854F0B),
                                  height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RechargePitDiagram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5ED),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(painter: _PitPainter()),
    );
  }
}

class _PitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    // Gravel layer
    canvas.drawRect(
      Rect.fromLTWH(cx - 50, 20, 100, 25),
      Paint()..color = const Color(0xFF9FE1CB),
    );
    _label(canvas, 'Gravel', cx, 33, const Color(0xFF085041));
    // Sand layer
    canvas.drawRect(
      Rect.fromLTWH(cx - 50, 47, 100, 22),
      Paint()..color = const Color(0xFF5DCAA5),
    );
    _label(canvas, 'Sand', cx, 59, const Color(0xFF085041));
    // Charcoal layer
    canvas.drawRect(
      Rect.fromLTWH(cx - 50, 71, 100, 20),
      Paint()..color = const Color(0xFF1D9E75),
    );
    _label(canvas, 'Charcoal', cx, 83, Colors.white);
    // Arrows
    final arrowPaint = Paint()
      ..color = const Color(0xFF378ADD)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 80, 10), Offset(cx - 55, 10), arrowPaint);
    canvas.drawLine(Offset(cx - 55, 10), Offset(cx - 55, 20), arrowPaint);
    _label(canvas, 'Rain →', cx - 80, 8, const Color(0xFF185FA5), size: 9);
    canvas.drawLine(Offset(cx + 55, 91), Offset(cx + 55, 108), arrowPaint);
    _label(canvas, '↓ Aquifer', cx + 60, 100, const Color(0xFF185FA5),
        size: 9, align: TextAlign.left);
  }

  void _label(Canvas canvas, String text, double x, double y, Color color,
      {double size = 10, TextAlign align = TextAlign.center}) {
    final tp = TextPainter(
      text: TextSpan(
          text: text, style: TextStyle(fontSize: size, color: color)),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout();
    tp.paint(canvas,
        Offset(x - (align == TextAlign.center ? tp.width / 2 : 0), y - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CommunityTracker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Community recharge goal',
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 6),
          const Text('Ward 3 · This season',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('34 / 50 recharge pits built',
                  style: TextStyle(fontSize: 13)),
              Text('68%',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.68,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '16 more pits needed to meet the monsoon recharge goal.',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                height: 1.4),
          ),
        ],
      ),
    );
  }
}
