import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/application_repository.dart';
import 'application.dart';

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
}

final applicationsProvider =
    AutoDisposeAsyncNotifierProviderFamily<ApplicationsNotifier,
        List<Application>, String>(ApplicationsNotifier.new);
