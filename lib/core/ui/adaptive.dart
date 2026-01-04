import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'responsive.dart';
import 'tokens.dart';

class AdaptiveDestination {
  const AdaptiveDestination({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.body,
    required this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
    this.fab,
    this.appBar,
    this.maxContentWidth = 1100,
  });

  final Widget body;
  final List<AdaptiveDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget? fab;
  final PreferredSizeWidget? appBar;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final size = context.deviceSize;
    if (size == DeviceSize.desktop || size == DeviceSize.tablet) {
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.selected,
              leading: const Padding(
                padding: EdgeInsets.all(AppSpacing.s12),
                child: Icon(Icons.business_center_outlined),
              ),
              destinations: destinations
                  .map(
                    (d) => NavigationRailDestination(
                      icon: Icon(d.icon),
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: body,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: fab,
      );
    }

    // Mobile: bottom nav
    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: fab,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icon),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

Future<T?> showAdaptiveDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  if (Platform.isIOS) {
    return showCupertinoDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => CupertinoAlertDialog(
        content: builder(ctx),
      ),
    );
  }
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => AlertDialog(
      content: builder(ctx),
    ),
  );
}

class AdaptiveSwitch extends StatelessWidget {
  const AdaptiveSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoSwitch(value: value, onChanged: onChanged);
    }
    return Switch(value: value, onChanged: onChanged);
  }
}

class AdaptiveActivityIndicator extends StatelessWidget {
  const AdaptiveActivityIndicator({super.key, this.size = 20});
  final double size;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoActivityIndicator(radius: size / 2);
    }
    return SizedBox(
      height: size,
      width: size,
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
