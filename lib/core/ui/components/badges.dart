import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status; // open | closed | ongoing | completed

  Color _color(BuildContext context) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'ongoing':
        return Colors.green.shade100;
      case 'completed':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _textColor(BuildContext context) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'ongoing':
        return Colors.green.shade900;
      case 'completed':
        return Colors.blue.shade900;
      default:
        return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label =
        status.isEmpty ? '' : '${status[0].toUpperCase()}${status.substring(1).toLowerCase()}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _color(context),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: _textColor(context), letterSpacing: 0.3),
      ),
    );
  }
}

class TypeBadge extends StatelessWidget {
  const TypeBadge({super.key, required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final label = type
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1))
        .join(' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
