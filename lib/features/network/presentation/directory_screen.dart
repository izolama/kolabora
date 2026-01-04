import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/components/cards.dart';
import '../../../core/ui/components/inputs.dart';
import '../../../core/ui/components/layout.dart';
import '../../../core/ui/tokens.dart';
import '../../home/presentation/home_shell.dart';
import '../../profile/domain/profile.dart';
import '../../profile/domain/profile_providers.dart';

class NetworkDirectoryScreen extends ConsumerStatefulWidget {
  const NetworkDirectoryScreen({super.key});

  @override
  ConsumerState<NetworkDirectoryScreen> createState() =>
      _NetworkDirectoryScreenState();
}

class _NetworkDirectoryScreenState
    extends ConsumerState<NetworkDirectoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(profileDirectoryProvider);
    final query = _searchController.text.toLowerCase();

    return HomeShell(
      index: 1,
      child: Padding(
        padding: MediaQuery.viewPaddingOf(context) +
            const EdgeInsets.only(top: AppSpacing.s12, left: AppSpacing.s16, right: AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSearchField(
              controller: _searchController,
              hintText: 'Cari owner atau vendor',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.s12),
            Expanded(
              child: profilesAsync.when(
                data: (profiles) {
                  final filtered = profiles
                      .where(
                        (p) =>
                            p.displayName.toLowerCase().contains(query) ||
                            (p.bio ?? '').toLowerCase().contains(query),
                      )
                      .toList();
                  if (filtered.isEmpty) {
                    return const EmptyState(
                      title: 'Belum ada profil',
                      subtitle:
                          'Coba kata kunci lain atau undang kolaborator langsung.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.only(top: AppSpacing.s4),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.s8),
                    itemBuilder: (context, index) {
                      final profile = filtered[index];
                      return ProfileCard(
                        profile: profile,
                        onTap: () => context.push('/profile/${profile.id}'),
                      );
                    },
                  );
                },
                loading: () => const LoadingState(),
                error:
                    (error, _) =>
                        ErrorState(message: 'Gagal memuat profil: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
