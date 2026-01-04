import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/application_repository.dart';
import 'application.dart';
import '../../workspaces/data/workspace_repository.dart';

class ApplicationsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<Application>, String> {
  late String _postId;

  @override
  Future<List<Application>> build(String postId) async {
    _postId = postId;
    final repo = ref.watch(applicationRepositoryProvider);
    return repo.fetchByPost(postId);
  }

  Future<void> submit({
    required String applicantId,
    required String message,
  }) async {
    final repo = ref.read(applicationRepositoryProvider);
    final created = await repo.create(
      postId: _postId,
      applicantId: applicantId,
      message: message,
    );
    final current = state.value ?? [];
    state = AsyncData([created, ...current]);
  }

  Future<void> invite(String applicantId) async {
    final repo = ref.read(applicationRepositoryProvider);
    final created = await repo.invite(
      postId: _postId,
      applicantId: applicantId,
    );
    final current = state.value ?? [];
    state = AsyncData([created, ...current]);
  }

  Future<String?> approve({
    required Application application,
    required String ownerId,
  }) async {
    final appRepo = ref.read(applicationRepositoryProvider);
    final wsRepo = ref.read(workspaceRepositoryProvider);

    // update status
    final updated = await appRepo.updateStatus(
      applicationId: application.id,
      status: 'accepted',
    );

    // create workspace and members
    final workspace = await wsRepo.create(
      postId: _postId,
      ownerId: ownerId,
      memberIds: [application.applicantId],
    );

    // refresh local state
    final current = state.value ?? [];
    state = AsyncData([
      updated,
      ...current.where((a) => a.id != updated.id),
    ]);

    return workspace.id;
  }

  Future<void> reject(String applicationId) async {
    final appRepo = ref.read(applicationRepositoryProvider);
    final updated = await appRepo.updateStatus(
      applicationId: applicationId,
      status: 'rejected',
    );
    final current = state.value ?? [];
    state = AsyncData([
      updated,
      ...current.where((a) => a.id != updated.id),
    ]);
  }
}

final applicationsProvider =
    AutoDisposeAsyncNotifierProviderFamily<ApplicationsNotifier,
        List<Application>, String>(ApplicationsNotifier.new);
