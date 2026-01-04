import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/adaptive.dart' as ui;
import '../../../core/ui/components/badges.dart';
import '../../../core/ui/components/buttons.dart';
import '../../../core/ui/components/layout.dart';
import '../../../core/ui/tokens.dart';
import '../../auth/domain/auth_state.dart';
import '../domain/workspace_message.dart';
import '../domain/workspace_providers.dart';

class WorkspaceScreen extends ConsumerStatefulWidget {
  const WorkspaceScreen({super.key, required this.workspaceId});

  final String workspaceId;

  @override
  ConsumerState<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends ConsumerState<WorkspaceScreen> {
  final _messageController = TextEditingController();
  bool _isClosing = false;
  int _rating = 5;
  final _endorsementController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    _endorsementController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    await ref
        .read(messagesProvider(widget.workspaceId).notifier)
        .send(user.id, text);
    _messageController.clear();
  }

  Future<void> _closeWorkspace() async {
    await ui.showAdaptiveDialog<void>(
      context: context,
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Close project',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.s12),
            Text('Share an optional rating and comment for your collaborator.'),
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: List.generate(
                5,
                (i) => IconButton(
                  icon: Icon(
                    i < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber[600],
                  ),
                  onPressed: () => setState(() => _rating = i + 1),
                ),
              ),
            ),
            TextField(
              controller: _endorsementController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Leave a short endorsement (optional)',
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            PrimaryButton(
              label: 'Confirm close',
              onPressed: () async {
                setState(() => _isClosing = true);
                await ref
                    .read(workspaceProvider(widget.workspaceId).notifier)
                    .close();
                final userId = ref.read(authStateProvider).valueOrNull?.id;
                final ws =
                    ref.read(workspaceProvider(widget.workspaceId)).value;
                if (userId != null && ws != null) {
                  final target = ws.members.firstWhere(
                    (m) => m.memberId != userId,
                    orElse: () => ws.members.first,
                  );
                  await ref
                      .read(workspaceProvider(widget.workspaceId).notifier)
                      .endorse(
                        toUserId: target.memberId,
                        rating: _rating,
                        comment: _endorsementController.text.trim(),
                      );
                }
                if (mounted) {
                  Navigator.of(ctx).pop();
                  setState(() => _isClosing = false);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(workspaceProvider(widget.workspaceId));
    final messages = ref.watch(messagesProvider(widget.workspaceId));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Workspace',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!_isClosing)
                      TextButton.icon(
                        onPressed: _closeWorkspace,
                        icon: const Icon(Icons.flag_outlined),
                        label: const Text('Close'),
                      ),
                  ],
                ),
              ),
              const TabBar(
                tabs: [
                  Tab(text: 'Discussion'),
                  Tab(text: 'Files'),
                  Tab(text: 'Progress'),
                ],
              ),
              workspace.when(
                data: (ws) {
                  if (ws == null) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSpacing.s16),
                      child: Text('Workspace not found'),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StatusBadge(status: ws.status),
                            const SizedBox(height: AppSpacing.s8),
                            Wrap(
                              spacing: AppSpacing.s8,
                              children: ws.members
                                  .map((m) =>
                                      Chip(label: Text('${m.role}: ${m.memberId}')))
                                  .toList(),
                            ),
                          ],
                        ),
                        if (_isClosing) const ui.AdaptiveActivityIndicator(),
                      ],
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.s16),
                  child: ui.AdaptiveActivityIndicator(),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: Text('Error loading workspace: $error'),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _DiscussionTab(
                      messages: messages,
                      messageController: _messageController,
                      onSend: _send,
                    ),
                    const _FilesTab(),
                    const _ProgressTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscussionTab extends ConsumerWidget {
  const _DiscussionTab({
    required this.messages,
    required this.messageController,
    required this.onSend,
  });

  final AsyncValue<List<WorkspaceMessage>> messages;
  final TextEditingController messageController;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: messages.when(
            data:
                (msgs) => ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: AppSpacing.s8,
                  ),
                  itemCount: msgs.length,
                  itemBuilder: (context, index) {
                    final msg = msgs[index];
                    return ListTile(
                      title: Text(msg.message),
                      subtitle: Text(msg.senderId),
                      trailing: Text(
                        '${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
                      ),
                    );
                  },
                ),
            loading: () => const LoadingState(),
            error: (error, _) => ErrorState(message: 'Could not load: $error'),
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s8,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    hintText: 'Share progress with the workspace',
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.send), onPressed: onSend),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilesTab extends StatelessWidget {
  const _FilesTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: EmptyState(
        title: 'Files',
        subtitle: 'Upload project files via Supabase Storage (coming soon).',
      ),
    );
  }
}

class _ProgressTab extends StatelessWidget {
  const _ProgressTab();

  @override
  Widget build(BuildContext context) {
    final steps = ['Kickoff', 'Milestone', 'QA', 'Delivery'];
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.s16),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(
            index == 0
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
          ),
          title: Text(steps[index]),
          subtitle: const Text('Track progress with your partner'),
        );
      },
    );
  }
}
