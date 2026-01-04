import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/components/badges.dart';
import '../../../core/ui/components/layout.dart';
import '../../../core/ui/tokens.dart';
import '../../../core/ui/components/buttons.dart';
import '../../auth/domain/auth_state.dart';
import '../../home/presentation/home_shell.dart';
import '../domain/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.userIdOverride});

  final String? userIdOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final targetId = userIdOverride ?? user.id;
    final profile = ref.watch(profileProvider(targetId));

    return HomeShell(
      index: 3,
      child: profile.when(
        data: (profile) {
          if (profile == null) {
            return Center(
              child: userIdOverride != null
                  ? const Text('Profile not found')
                  : TextButton(
                      onPressed: () => context.push('/profile/setup'),
                      child: const Text('Set up your profile'),
                    ),
            );
          }
          return ListView(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    child: Text(profile.displayName.isNotEmpty
                        ? profile.displayName[0]
                        : '?'),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.displayName,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      StatusBadge(status: profile.role),
                      if (profile.location != null)
                        Text(profile.location!,
                            style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.push('/profile/setup'),
                    icon: const Icon(Icons.edit_outlined),
                  )
                ],
              ),
              const SizedBox(height: AppSpacing.s16),
              Text(profile.bio ?? 'No bio yet'),
              const SizedBox(height: AppSpacing.s12),
              Wrap(
                spacing: AppSpacing.s8,
                runSpacing: AppSpacing.s8,
                children: profile.fields
                    .map((f) => Chip(label: Text(f)))
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.s24),
              const SectionHeader(title: 'Project history'),
              Card(
                child: ListTile(
                  title: const Text('No projects yet'),
                  subtitle:
                      const Text('Accepted applications will show up here.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              const SectionHeader(title: 'Endorsements'),
              Card(
                child: ListTile(
                  title: const Text('No endorsements yet'),
                  subtitle: const Text('Close a project to add endorsements.'),
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              PrimaryButton(
                label: 'Logout',
                onPressed: () async {
                  await ref.read(authStateProvider.notifier).signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          );
        },
        loading: () => const LoadingState(),
        error: (error, _) => ErrorState(
          message: 'Could not load profile: $error',
          action: TextButton(
            onPressed: () => ref.refresh(profileProvider(user.id)),
            child: const Text('Retry'),
          ),
        ),
      ),
    );
  }
}
