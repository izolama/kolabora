import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/components/cards.dart';
import '../../../core/ui/components/inputs.dart';
import '../../../core/ui/components/layout.dart';
import '../../../core/ui/tokens.dart';
import '../../home/presentation/home_shell.dart';
import '../../network/domain/field_providers.dart';
import '../domain/feed_filters.dart';
import '../domain/feed_providers.dart';

final feedFiltersProvider = StateProvider<FeedFilters>(
  (ref) => const FeedFilters(),
);

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(feedFiltersProvider);
    final feed = ref.watch(feedProvider(filters));
    final search = _searchController.text.toLowerCase();

    return HomeShell(
      index: 0,
      showFab: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.viewPaddingOf(context).top + 4),
          // const SectionHeader(title: 'Intent feed'),
          _FeedFiltersBar(
            filters: filters,
            controller: _searchController,
            onSearchChanged: () => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.s4),
          feed.when(
            data: (posts) {
              final filtered = posts.where((p) {
                final matchesSearch = p.title.toLowerCase().contains(search) ||
                    p.description.toLowerCase().contains(search);
                final matchesType =
                    filters.type == null || p.type == filters.type;
                final matchesStatus =
                    !filters.openOnly || p.status.toLowerCase() == 'open';
                final matchesField = filters.fieldId == null ||
                    p.fields.contains(filters.fieldId);
                return matchesSearch && matchesType && matchesStatus && matchesField;
              }).toList();
              if (filtered.isEmpty) {
                return const Expanded(
                  child: EmptyState(
                    title: 'No intents found',
                    subtitle: 'Try adjusting filters or share your intent.',
                  ),
                );
              }
              return Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: AppSpacing.s4),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final post = filtered[index];
                    return PostCard(
                      post: post,
                      onView:
                          () => context.push('/post/${post.id}', extra: post),
                      onPrimaryAction:
                          () => context.push('/post/${post.id}', extra: post),
                      primaryLabel: 'Apply',
                    );
                  },
                ),
              );
            },
            loading: () => const Expanded(child: LoadingState()),
            error:
                (error, _) => Expanded(
                  child: ErrorState(
                    message: 'Failed to load feed: $error',
                    action: TextButton(
                      onPressed:
                          () =>
                              ref
                                  .read(feedProvider(filters).notifier)
                                  .refresh(),
                      child: const Text('Retry'),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _FeedFiltersBar extends ConsumerWidget {
  const _FeedFiltersBar({
    required this.filters,
    required this.controller,
    required this.onSearchChanged,
  });

  final FeedFilters filters;
  final TextEditingController controller;
  final VoidCallback onSearchChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fields = ref.watch(fieldsProvider);
    return Column(
      children: [
        AppSearchField(
          controller: controller,
          hintText: 'Search intents',
          onChanged: (_) => onSearchChanged(),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(
            bottom: 6,
            left: AppSpacing.s16,
            right: AppSpacing.s16,
          ),
          child: Row(
            children:
                [
                  _TypeChip(label: 'All', value: null, filters: filters),
                  FilterChip(
                    label: const Text('Open only'),
                    selected: filters.openOnly,
                    onSelected:
                        (value) =>
                            ref
                                .read(feedFiltersProvider.notifier)
                                .state = filters.copyWith(openOnly: value),
                  ),
                  _TypeChip(
                    label: 'Looking Vendor',
                    value: 'looking_vendor',
                    filters: filters,
                  ),
                  _TypeChip(
                    label: 'Open Project',
                    value: 'open_project',
                    filters: filters,
                  ),
                  _TypeChip(
                    label: 'Collaboration',
                    value: 'collaboration',
                    filters: filters,
                  ),
                  _TypeChip(
                    label: 'Offer Service',
                    value: 'offer_service',
                    filters: filters,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  fields.when(
                    data:
                        (items) => Row(
                          children:
                              items
                                  .map(
                                    (f) => Padding(
                                      padding: const EdgeInsets.only(
                                        right: AppSpacing.s8,
                                      ),
                                      child: FilterChip(
                                        label: Text(f.name),
                                        selected: filters.fieldId == f.id,
                                        onSelected: (value) {
                                          ref
                                              .read(
                                                feedFiltersProvider.notifier,
                                              )
                                              .state = filters.copyWith(
                                            fieldId: value ? f.id : null,
                                            clearField: !value,
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                    loading:
                        () => const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    error: (error, _) => Text('Fields error: $error'),
                  ),
                ].map((chip) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.s8),
                    child: chip,
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}

class _TypeChip extends ConsumerWidget {
  const _TypeChip({
    required this.label,
    required this.value,
    required this.filters,
  });

  final String label;
  final String? value;
  final FeedFilters filters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = filters.type == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        ref.read(feedFiltersProvider.notifier).state =
            filters.copyWith(type: value, clearType: value == null);
      },
    );
  }
}
