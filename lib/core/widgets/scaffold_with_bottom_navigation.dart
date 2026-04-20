import 'package:academic_planner_fe/core/widgets/default_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;
  const ScaffoldWithBottomNav({super.key, required this.child});

  static const List<String> _routes = [
    '/',
    '/terms',
    '/courses',
    "/goals",
    '/graph',
  ];

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _routes.indexOf(location);
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      appBar: DefaultAppBar(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.plus),
            label: "Terms",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.bookOpen),
            label: "Courses",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.bullseye),
            label: "Goals",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.chartLine),
            label: "Graph",
          ),
        ],
        currentIndex: _getCurrentIndex(context),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        selectedLabelStyle: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
        ),
        unselectedItemColor: Theme.of(context).colorScheme.tertiary,
        unselectedLabelStyle: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
        ),
        onTap: (index) => context.go(_routes[index]),
      ),
    );
  }
}
