import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/components/buttons.dart';
import '../../../core/ui/tokens.dart';

class OnboardingRoleScreen extends StatefulWidget {
  const OnboardingRoleScreen({super.key});

  @override
  State<OnboardingRoleScreen> createState() => _OnboardingRoleScreenState();
}

class _OnboardingRoleScreenState extends State<OnboardingRoleScreen> {
  String _role = 'owner';

  @override
  Widget build(BuildContext context) {
    final cards = [
      _RoleCardData(
        title: 'Business Owner',
        description: 'Open projects and invite vetted vendors to collaborate.',
        value: 'owner',
      ),
      _RoleCardData(
        title: 'Vendor / Partner',
        description: 'Offer services and respond to owner intents.',
        value: 'vendor',
      ),
      _RoleCardData(
        title: 'Both',
        description: 'Run projects and offer services in one workspace.',
        value: 'both',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nivora adalah jaringan privat untuk owner dan vendor. Pilih peran awal Anda.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.s24),
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    final item = cards[index];
                    final selected = _role == item.value;
                    return _RoleCard(
                      data: item,
                      selected: selected,
                      onTap: () => setState(() => _role = item.value),
                    );
                  },
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.s12),
                  itemCount: cards.length,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              PrimaryButton(
                label: 'Lanjutkan',
                onPressed: () => context.go('/feed'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCardData {
  _RoleCardData({
    required this.title,
    required this.description,
    required this.value,
  });
  final String title;
  final String description;
  final String value;
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _RoleCardData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.surfaceVariant : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(data.description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
