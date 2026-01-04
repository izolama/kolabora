import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/client.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Future<AuthResponse> signIn(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp(String email, String password) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepository(client);
});
