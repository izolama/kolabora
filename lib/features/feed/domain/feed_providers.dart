import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/feed_repository.dart';
import 'feed_filters.dart';
import 'post.dart';

class FeedNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<Post>, FeedFilters> {
  late FeedFilters _filters;

  @override
  Future<List<Post>> build(FeedFilters filters) async {
    _filters = filters;
    final repo = ref.watch(feedRepositoryProvider);
    return repo.fetchFeed(filters);
  }

  Future<void> refresh() async {
    final repo = ref.read(feedRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repo.fetchFeed(_filters));
  }
}

final feedProvider =
    AutoDisposeAsyncNotifierProviderFamily<FeedNotifier, List<Post>, FeedFilters>(
        FeedNotifier.new);

class PostDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<Post?, String> {
  @override
  Future<Post?> build(String postId) async {
    final repo = ref.watch(feedRepositoryProvider);
    return repo.fetchPost(postId);
  }
}

final postDetailProvider =
    AutoDisposeAsyncNotifierProviderFamily<PostDetailNotifier, Post?, String>(
        PostDetailNotifier.new);
