import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/profile_repository.dart';
import 'profile.dart';

class ProfileNotifier
    extends AutoDisposeFamilyAsyncNotifier<Profile?, String> {
  @override
  Future<Profile?> build(String userId) async {
    final repo = ref.watch(profileRepositoryProvider);
    final profile = await repo.fetchProfile(userId);
    return profile;
  }

  Future<void> save(Profile profile) async {
    final repo = ref.read(profileRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repo.upsertProfile(profile));
  }
}

final profileProvider =
    AutoDisposeAsyncNotifierProviderFamily<ProfileNotifier, Profile?, String>(
        ProfileNotifier.new);

class ProfileDirectoryNotifier
    extends AutoDisposeAsyncNotifier<List<Profile>> {
  @override
  Future<List<Profile>> build() async {
    final repo = ref.watch(profileRepositoryProvider);
    // Fetch all profiles; in real app, add pagination.
    final data = await repo.fetchAll();
    return data;
  }
}

final profileDirectoryProvider =
    AutoDisposeAsyncNotifierProvider<ProfileDirectoryNotifier, List<Profile>>(
        ProfileDirectoryNotifier.new);
