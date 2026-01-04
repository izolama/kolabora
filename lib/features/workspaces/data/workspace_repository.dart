import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/client.dart';
import '../domain/workspace.dart';
import '../domain/workspace_message.dart';

class WorkspaceRepository {
  WorkspaceRepository(this._client);

  final SupabaseClient _client;

  Future<Workspace?> fetchWorkspace(String id) async {
    final data =
        await _client.from('workspaces').select().eq('id', id).maybeSingle();
    if (data == null) return null;
    final membersData = await _client
        .from('workspace_members')
        .select()
        .eq('workspace_id', id);
    final members = (membersData as List<dynamic>)
        .map((m) => WorkspaceMember.fromMap(m as Map<String, dynamic>))
        .toList();
    final workspace = Workspace.fromMap(data);
    return workspace.copyWith(members: members);
  }

  Future<Workspace> create({
    required String postId,
    required String ownerId,
    required List<String> memberIds,
  }) async {
    final response = await _client.from('workspaces').insert({
      'post_id': postId,
      'owner_id': ownerId,
      'status': 'ongoing',
    }).select().single();
    final workspaceId = response['id'] as String;

    final membersPayload = [
      {'workspace_id': workspaceId, 'member_id': ownerId, 'role': 'owner'},
      ...memberIds.map(
        (id) => {
          'workspace_id': workspaceId,
          'member_id': id,
          'role': 'vendor',
        },
      ),
    ];
    await _client.from('workspace_members').insert(membersPayload);

    final members = membersPayload
        .map((m) => WorkspaceMember.fromMap(m))
        .toList();
    final workspace = Workspace.fromMap(response as Map<String, dynamic>);
    return workspace.copyWith(members: members);
  }

  Future<List<WorkspaceMessage>> fetchMessages(String workspaceId) async {
    final data = await _client
        .from('workspace_messages')
        .select()
        .eq('workspace_id', workspaceId)
        .order('created_at', ascending: true);
    return (data as List<dynamic>)
        .map((row) => WorkspaceMessage.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<WorkspaceMessage> addMessage({
    required String workspaceId,
    required String senderId,
    required String message,
  }) async {
    final response = await _client.from('workspace_messages').insert({
      'workspace_id': workspaceId,
      'sender_id': senderId,
      'message': message,
    }).select().single();
    return WorkspaceMessage.fromMap(response);
  }

  Future<Workspace> close(String workspaceId) async {
    final data = await _client
        .from('workspaces')
        .update({'status': 'completed'})
        .eq('id', workspaceId)
        .select()
        .single();
    return Workspace.fromMap(data as Map<String, dynamic>);
  }

  Future<void> endorse({
    required String workspaceId,
    required String fromUserId,
    required String toUserId,
    int? rating,
    String? comment,
  }) async {
    await _client.from('endorsements').insert({
      'workspace_id': workspaceId,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'rating': rating,
      'comment': comment,
    });
  }

  Future<List<Workspace>> listForUser(String userId) async {
    final data = await _client
        .from('workspace_members')
        .select('workspace_id')
        .eq('member_id', userId);
    if (data.isEmpty) return [];
    final ids = (data as List<dynamic>)
        .map((e) => (e as Map<String, dynamic>)['workspace_id'] as String)
        .toList();
    final workspaces = await _client
        .from('workspaces')
        .select()
        .inFilter('id', ids)
        .order('id');
    return (workspaces as List<dynamic>)
        .map((w) => Workspace.fromMap(w as Map<String, dynamic>))
        .toList();
  }
}

final workspaceRepositoryProvider = Provider<WorkspaceRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return WorkspaceRepository(client);
});
