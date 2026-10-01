import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/borewell_service.dart';
import '../utils/app_theme.dart';
import 'tabs/map_tab.dart';
import 'tabs/log_tab.dart';
import 'tabs/recharge_tab.dart';
import 'tabs/alerts_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    MapTab(),
    LogTab(),
    RechargeTab(),
    AlertsTab(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BorewellService>().fetchZones();
    });
  }

  @override
  Widget build(BuildContext context) {
    final alerts = context.watch<BorewellService>().criticalZoneCount;
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFD4F0E0),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: AppTheme.primary),
            label: 'Map',
          ),
          const NavigationDestination(
            icon: Icon(Icons.edit_outlined),
            selectedIcon: Icon(Icons.edit, color: AppTheme.primary),
            label: 'Log',
          ),
          const NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco, color: AppTheme.primary),
            label: 'Recharge',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: alerts > 0,
              label: Text('$alerts'),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: alerts > 0,
              label: Text('$alerts'),
              child: const Icon(Icons.notifications,
                  color: AppTheme.primary),
            ),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }
}
