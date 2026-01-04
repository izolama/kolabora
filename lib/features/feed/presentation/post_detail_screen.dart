import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/adaptive.dart';
import '../../../core/ui/components/badges.dart';
import '../../../core/ui/components/buttons.dart';
import '../../../core/ui/components/layout.dart';
import '../../../core/ui/tokens.dart';
import '../../auth/domain/auth_state.dart';
import '../../profile/domain/profile_providers.dart';
import '../../projects/domain/application_providers.dart';
import '../domain/feed_providers.dart';
import '../domain/post.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  const PostDetailScreen({super.key, required this.postId, this.initialPost});

  final String postId;
  final Post? initialPost;

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _applicationMessageController = TextEditingController();
  final _discussionController = TextEditingController();
  final List<String> _discussionMessages = [];

  @override
  void dispose() {
    _applicationMessageController.dispose();
    _discussionController.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    final text = _applicationMessageController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tulis pesan aplikasi terlebih dulu')),
      );
      return;
    }

    await ref
        .read(applicationsProvider(widget.postId).notifier)
        .submit(applicantId: user.id, message: text);
    _applicationMessageController.clear();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Application sent')));
    }
  }

  void _postReply() {
    final text = _discussionController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _discussionMessages.add(text);
      _discussionController.clear();
    });
  }

  Future<void> _invite() async {
    final currentUserId = ref.read(authStateProvider).valueOrNull?.id;
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final sheetHeight = MediaQuery.of(ctx).size.height * 0.55;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SafeArea(
            child: SizedBox(
              height: sheetHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                  vertical: AppSpacing.s16,
                ),
                child: Consumer(
                  builder: (context, ref, _) {
                    final profilesAsync = ref.watch(profileDirectoryProvider);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Undang vendor/partner',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Text(
                          'Pilih profil untuk dikirimi undangan kolaborasi.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        Expanded(
                          child: profilesAsync.when(
                            data: (profiles) {
                              final filtered =
                                  profiles
                                      .where((p) => p.id != currentUserId)
                                      .toList();
                              if (filtered.isEmpty) {
                                return const Center(
                                  child: Text('Belum ada profil lain'),
                                );
                              }
                              return ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder:
                                    (_, __) =>
                                        const SizedBox(height: AppSpacing.s8),
                                itemBuilder: (context, index) {
                                  final p = filtered[index];
                                  final initials =
                                      p.displayName.isNotEmpty
                                          ? p.displayName[0].toUpperCase()
                                          : '?';
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text(initials),
                                    ),
                                    title: Text(p.displayName),
                                    subtitle: Text(p.role),
                                    onTap: () async {
                                      Navigator.of(ctx).pop();
                                      await ref
                                          .read(
                                            applicationsProvider(
                                              widget.postId,
                                            ).notifier,
                                          )
                                          .invite(p.id);
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Undangan dikirim ke ${p.displayName}',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  );
                                },
                              );
                            },
                            loading:
                                () => const Center(
                                  child: AdaptiveActivityIndicator(),
                                ),
                            error:
                                (error, _) => Center(
                                  child: Text('Gagal memuat profil: $error'),
                                ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final post =
        widget.initialPost != null
            ? AsyncValue<Post?>.data(widget.initialPost)
            : ref.watch(postDetailProvider(widget.postId));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s12,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/feed');
                      }
                    },
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Text(
                    'details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: post.when(
                data: (post) {
                  if (post == null) {
                    return const Center(child: Text('Post not found'));
                  }
                  final authorProfile = ref.watch(
                    profileProvider(post.authorId),
                  );
                  final applications = ref.watch(
                    applicationsProvider(widget.postId),
                  );

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            TypeBadge(type: post.type),
                            const SizedBox(width: AppSpacing.s8),
                            StatusBadge(status: post.status),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        authorProfile.when(
                          data: (p) {
                            final name = p?.displayName ?? 'Author';
                            final initials =
                                name.isNotEmpty
                                    ? name.trim()[0].toUpperCase()
                                    : '?';
                            return InkWell(
                              onTap:
                                  () => context.push(
                                    '/profile/${p?.id ?? post.authorId}',
                                  ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    child: Text(initials),
                                  ),
                                  const SizedBox(width: AppSpacing.s8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                      if (p?.role != null)
                                        Text(
                                          p!.role,
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.labelSmall,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Text(
                          post.title,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: AppSpacing.s8),
                        Text(post.description),
                        const SizedBox(height: AppSpacing.s12),
                        Wrap(
                          spacing: AppSpacing.s12,
                          runSpacing: AppSpacing.s8,
                          children: [
                            Chip(label: Text('Timeline: ${post.timeline}')),
                            Chip(label: Text('Comp: ${post.compensationType}')),
                            if (post.fields.isNotEmpty)
                              Chip(label: Text(post.fields.join(', '))),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pesan aplikasi',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge,
                            ),
                            const SizedBox(height: AppSpacing.s8),
                            TextField(
                              controller: _applicationMessageController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Ceritakan kecocokan dan langkah selanjutnya',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s12),
                            Row(
                              children: [
                                PrimaryButton(
                                  label: 'Apply',
                                  onPressed: _apply,
                                ),
                                const SizedBox(width: AppSpacing.s12),
                                SecondaryButton(
                                  label: 'Invite',
                                  onPressed: _invite,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s24),
                        const SectionHeader(title: 'Applications'),
                        applications.when(
                          data:
                              (apps) =>
                                  apps.isEmpty
                                      ? const EmptyState(
                                        title: 'Belum ada aplikasi',
                                        subtitle:
                                            'Undang partner atau tunggu vendor melamar.',
                                      )
                                      : Column(
                                        children:
                                            apps
                                                .map(
                                                  (app) => Card(
                                                    child: ListTile(
                                                      title: Text(app.message),
                                                      subtitle: Text(
                                                        'Applicant: ${app.applicantId} • ${app.status}',
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                      ),
                          loading:
                              () => const Padding(
                                padding: EdgeInsets.all(AppSpacing.s8),
                                child: AdaptiveActivityIndicator(),
                              ),
                          error: (error, _) => Text('Could not load: $error'),
                        ),
                        const SizedBox(height: AppSpacing.s24),
                        const SectionHeader(title: 'Discussion'),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.s12),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _discussionController,
                                  maxLines: 4,
                                  decoration: const InputDecoration(
                                    hintText: 'Share your fit and next steps',
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: PrimaryButton(
                                    label: 'Post reply',
                                    onPressed: _postReply,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        if (_discussionMessages.isEmpty)
                          const EmptyState(
                            title: 'Belum ada diskusi',
                            subtitle:
                                'Mulai thread dengan membagikan langkah berikutnya.',
                          )
                        else
                          Column(
                            children:
                                _discussionMessages
                                    .map(
                                      (msg) => ListTile(
                                        leading: const Icon(
                                          Icons.forum_outlined,
                                        ),
                                        title: Text(msg),
                                      ),
                                    )
                                    .toList(),
                          ),
                        const SizedBox(height: AppSpacing.s16),
                      ],
                    ),
                  );
                },
                loading: () => const LoadingState(),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
