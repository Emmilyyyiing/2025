import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/borewell_entry.dart';
import '../../services/borewell_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/water_depth_scale.dart';

class LogTab extends StatefulWidget {
  const LogTab({super.key});

  @override
  State<LogTab> createState() => _LogTabState();
}

class _LogTabState extends State<LogTab> {
  final _formKey = GlobalKey<FormState>();
  final _depthCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _levelCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  WaterYield? _selectedYield;
  bool _loading = false;
  bool _submitted = false;
  String? _error;

  @override
  void dispose() {
    _depthCtrl.dispose();
    _yearCtrl.dispose();
    _levelCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedYield == null) {
      setState(() => _error = 'Please select water yield.');
      return;
    }
    setState(() { _loading = true; _error = null; });

    try {
      final service = context.read<BorewellService>();
      final auth = context.read<AuthService>();
      final position = await service.getCurrentLocation();

      await service.submitBorewell(
        userId: auth.currentUser!.uid,
        depthFt: double.parse(_depthCtrl.text),
        yearDrilled: int.parse(_yearCtrl.text),
        yield: _selectedYield!,
        currentWaterLevelFt: _levelCtrl.text.isNotEmpty
            ? double.tryParse(_levelCtrl.text)
            : null,
        notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
        position: position,
      );
      setState(() { _submitted = true; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _reset() {
    _depthCtrl.clear();
    _yearCtrl.clear();
    _levelCtrl.clear();
    _notesCtrl.clear();
    setState(() {
      _selectedYield = null;
      _submitted = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Borewell')),
      body: _submitted ? _SuccessView(onReset: _reset) : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'Borewell details',
            children: [
              TextFormField(
                controller: _depthCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total borewell depth (feet)',
                  prefixIcon: Icon(Icons.straighten_outlined),
                  suffixText: 'ft',
                ),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Enter a valid depth';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _yearCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Year drilled',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1980 || n > 2026) {
                    return 'Enter a year between 1980 and 2026';
                  }
                  return null;
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Current water status',
            children: [
              DropdownButtonFormField<WaterYield>(
                value: _selectedYield,
                decoration: const InputDecoration(
                  labelText: 'Current water yield',
                  prefixIcon: Icon(Icons.water_drop_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                      value: WaterYield.good,
                      child: Text('Good (3+ inches)')),
                  DropdownMenuItem(
                      value: WaterYield.moderate,
                      child: Text('Moderate (1–2 inches)')),
                  DropdownMenuItem(
                      value: WaterYield.low,
                      child: Text('Low (< 1 inch)')),
                  DropdownMenuItem(
                      value: WaterYield.dry,
                      child: Text('Dry — no water')),
                ],
                onChanged: (v) => setState(() => _selectedYield = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _levelCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Water level depth (optional)',
                  hintText: 'How deep is water from surface?',
                  prefixIcon: Icon(Icons.vertical_align_bottom_outlined),
                  suffixText: 'ft',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText:
                      'Any seasonal changes, colour, smell, etc.',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const WaterDepthScale(),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE1F5EE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppTheme.primary.withOpacity(0.2), width: 0.5),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline, color: AppTheme.primary, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your exact address is never stored or shown. Only your neighbourhood zone appears on the community map.',
                    style: TextStyle(
                        color: AppTheme.primaryDark, fontSize: 12, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style: const TextStyle(
                    color: AppTheme.danger, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loading ? null : _submit,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.send_outlined, size: 18),
            label: Text(_loading ? 'Submitting...' : 'Submit borewell data'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppTheme.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.3)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final VoidCallback onReset;
  const _SuccessView({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                  color: Color(0xFFD4F0E0), shape: BoxShape.circle),
              child: const Icon(Icons.check,
                  color: AppTheme.primary, size: 38),
            ),
            const SizedBox(height: 20),
            const Text('Submitted!',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Thank you for contributing. The community heatmap will update shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.add_outlined, size: 18),
              label: const Text('Log another borewell'),
            ),
          ],
        ),
      ),
    );
  }
}
