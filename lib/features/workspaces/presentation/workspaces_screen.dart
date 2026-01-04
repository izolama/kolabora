import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/components/badges.dart';
import '../../../core/ui/components/buttons.dart';
import '../../../core/ui/components/layout.dart';
import '../../../core/ui/tokens.dart';
import '../../home/presentation/home_shell.dart';
import '../domain/workspace_providers.dart';

class WorkspacesScreen extends ConsumerWidget {
  const WorkspacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(workspacesListProvider);

    return HomeShell(
      index: 2,
      child: Padding(
        padding: MediaQuery.viewPaddingOf(context) +
            const EdgeInsets.symmetric(horizontal: AppSpacing.s16)
                .copyWith(top: AppSpacing.s12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Workspaces'),
            Expanded(
              child: list.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyState(
                      title: 'Belum ada workspace',
                      subtitle: 'Buat workspace dari aplikasi yang diterima.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.s8,
                      left: AppSpacing.s4,
                      right: AppSpacing.s4,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.s8),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: AppSpacing.s4,
                          horizontal: AppSpacing.s8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s12,
                            vertical: AppSpacing.s8,
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(item.title ?? 'Workspace'),
                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.only(top: AppSpacing.s8),
                              child: StatusBadge(status: item.status),
                            ),
                            trailing: SecondaryButton(
                              label: 'Open',
                              onPressed: () =>
                                  context.push('/workspace/${item.id}'),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const LoadingState(),
                error: (error, _) =>
                    ErrorState(message: 'Gagal memuat workspaces: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
