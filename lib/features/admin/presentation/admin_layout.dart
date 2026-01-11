import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _calculateSelectedIndex(context),
            onDestinationSelected: (int index) {
              switch (index) {
                case 0:
                  context.go('/admin');
                  break;
                case 1:
                  context.go('/admin/equipment');
                  break;
                case 2:
                  context.go('/'); // Back to App
                  break;
              }
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('لوحة التحكم'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.construction_outlined),
                selectedIcon: Icon(Icons.construction),
                label: Text('المعدات'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.exit_to_app),
                label: Text('خروج'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/admin/equipment')) {
      return 1;
    }
    if (location == '/admin') {
      return 0;
    }
    return 0;
  }
}
