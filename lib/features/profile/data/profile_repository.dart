import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/client.dart';
import '../domain/profile.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<Profile?> fetchProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return Profile.fromMap(data);
  }

  Future<Profile> upsertProfile(Profile profile) async {
    final response =
        await _client.from('profiles').upsert(profile.toMap()).select().single();
    return Profile.fromMap(response);
  }

  Future<List<Profile>> fetchAll() async {
    final data = await _client.from('profiles').select().order('created_at');
    return (data as List<dynamic>)
        .map((row) => Profile.fromMap(row as Map<String, dynamic>))
        .toList();
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProfileRepository(client);
});
