import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/client.dart';
import '../domain/feed_filters.dart';
import '../domain/post.dart';

class FeedRepository {
  FeedRepository(this._client);

  final SupabaseClient _client;

  Future<List<Post>> fetchFeed(FeedFilters filters) async {
    final selectColumns = filters.fieldId != null
        ? '*, post_fields!inner(field_id)'
        : '*, post_fields(field_id)';

    final query = _client.from('posts').select(selectColumns);

    if (filters.type != null) {
      query.eq('type', filters.type!);
    }
    if (filters.fieldId != null) {
      query.eq('post_fields.field_id', filters.fieldId!);
    }
    if (filters.openOnly) {
      query.eq('status', 'open');
    }

    final data = await query.order('created_at', ascending: false);
    return (data as List<dynamic>)
        .map((row) => Post.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<Post?> fetchPost(String id) async {
    final data = await _client
        .from('posts')
        .select('*, post_fields(field_id)')
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return Post.fromMap(data);
  }

  Future<Post> createPost({
    required String authorId,
    required String type,
    required String title,
    required String description,
    required String compensationType,
    required String timeline,
    List<String> fieldIds = const [],
  }) async {
    final response = await _client.from('posts').insert({
      'author_id': authorId,
      'type': type,
      'title': title,
      'description': description,
      'compensation_type': compensationType,
      'timeline': timeline,
      'status': 'open',
    }).select().single();
    final postId = response['id'] as String;

    if (fieldIds.isNotEmpty) {
      final payload = fieldIds
          .map((id) => {'post_id': postId, 'field_id': id})
          .toList();
      await _client.from('post_fields').insert(payload);
    }

    response['post_fields'] =
        fieldIds.map((id) => {'field_id': id}).toList();
    return Post.fromMap(response as Map<String, dynamic>);
  }
}

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return FeedRepository(client);
});
