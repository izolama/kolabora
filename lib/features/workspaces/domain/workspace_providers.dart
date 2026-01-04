import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/workspace_repository.dart';
import 'workspace.dart';
import 'workspace_message.dart';
import '../../auth/domain/auth_state.dart';

class WorkspaceNotifier
    extends AutoDisposeFamilyAsyncNotifier<Workspace?, String> {
  late String _workspaceId;

  @override
  Future<Workspace?> build(String workspaceId) async {
    _workspaceId = workspaceId;
    final repo = ref.watch(workspaceRepositoryProvider);
    return repo.fetchWorkspace(workspaceId);
  }

  Future<void> close() async {
    final repo = ref.read(workspaceRepositoryProvider);
    final updated = await repo.close(_workspaceId);
    state = AsyncData(updated);
  }

  Future<void> endorse({
    required String toUserId,
    int? rating,
    String? comment,
  }) async {
    final repo = ref.read(workspaceRepositoryProvider);
    final fromUserId = ref.read(_currentUserIdProvider);
    if (fromUserId == null) return;
    await repo.endorse(
      workspaceId: _workspaceId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      rating: rating,
      comment: comment,
    );
  }
}

final workspaceProvider =
    AutoDisposeAsyncNotifierProviderFamily<WorkspaceNotifier, Workspace?, String>(
        WorkspaceNotifier.new);

class WorkspacesListNotifier
    extends AutoDisposeAsyncNotifier<List<Workspace>> {
  @override
  Future<List<Workspace>> build() async {
    final user = ref.watch(authStateProvider).valueOrNull;
    if (user == null) return [];
    final repo = ref.watch(workspaceRepositoryProvider);
    return repo.listForUser(user.id);
  }
}

final workspacesListProvider = AutoDisposeAsyncNotifierProvider<
    WorkspacesListNotifier, List<Workspace>>(WorkspacesListNotifier.new);

class MessagesNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<WorkspaceMessage>, String> {
  late String _workspaceId;

  @override
  Future<List<WorkspaceMessage>> build(String workspaceId) async {
    _workspaceId = workspaceId;
    final repo = ref.watch(workspaceRepositoryProvider);
    return repo.fetchMessages(workspaceId);
  }

  Future<void> send(String senderId, String message) async {
    final repo = ref.read(workspaceRepositoryProvider);
    final created = await repo.addMessage(
      workspaceId: _workspaceId,
      senderId: senderId,
      message: message,
    );
    final current = state.value ?? [];
    state = AsyncData([...current, created]);
  }
}

final messagesProvider =
    AutoDisposeAsyncNotifierProviderFamily<MessagesNotifier,
        List<WorkspaceMessage>, String>(MessagesNotifier.new);

final _currentUserIdProvider = Provider<String?>((ref) {
  final auth = ref.watch(authStateProvider);
  return auth.valueOrNull?.id;
});
