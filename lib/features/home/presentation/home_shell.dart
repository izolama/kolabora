import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/adaptive.dart';
import '../../../core/ui/tokens.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({
    super.key,
    required this.index,
    required this.child,
    this.showFab = false,
  });

  final int index;
  final Widget child;
  final bool showFab;

  List<AdaptiveDestination> get _destinations => const [
        AdaptiveDestination(
          label: 'Feed',
          icon: Icons.view_agenda_outlined,
          route: '/feed',
        ),
        AdaptiveDestination(
          label: 'Network',
          icon: Icons.group_outlined,
          route: '/network',
        ),
        AdaptiveDestination(
          label: 'Workspaces',
          icon: Icons.workspaces_outline,
          route: '/workspaces',
        ),
        AdaptiveDestination(
          label: 'Profile',
          icon: Icons.person_outline,
          route: '/profile',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      currentIndex: index,
      destinations: _destinations,
      onDestinationSelected: (i) {
        context.go(_destinations[i].route);
      },
      fab: showFab
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/create'),
              icon: const Icon(Icons.add),
              label: const Text('Create'),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
        child: child,
      ),
    );
  }
}
