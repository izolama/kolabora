import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/client.dart';
import '../domain/application.dart';

class ApplicationRepository {
  ApplicationRepository(this._client);

  final SupabaseClient _client;

  Future<List<Application>> fetchByPost(String postId) async {
    final data = await _client
        .from('applications')
        .select()
        .eq('post_id', postId)
        .order('created_at', ascending: false);
    return (data as List<dynamic>)
        .map((row) => Application.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<Application> create({
    required String postId,
    required String applicantId,
    required String message,
    String status = 'pending',
  }) async {
    final response = await _client.from('applications').insert({
      'post_id': postId,
      'applicant_id': applicantId,
      'message': message,
      'status': status,
    }).select().single();
    return Application.fromMap(response);
  }

  Future<Application> invite({
    required String postId,
    required String applicantId,
    String? message,
  }) {
    return create(
      postId: postId,
      applicantId: applicantId,
      message: message ?? 'Invited to collaborate',
      status: 'invited',
    );
  }
}

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ApplicationRepository(client);
});
