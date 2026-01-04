import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/client.dart';

class AuthStateNotifier extends AsyncNotifier<User?> {
  StreamSubscription<AuthState>? _subscription;

  @override
  Future<User?> build() async {
    final supabase = ref.watch(supabaseClientProvider);
    final session = supabase.auth.currentSession;

    _subscription ??= supabase.auth.onAuthStateChange.listen((event) {
      state = AsyncData(event.session?.user);
    });
    ref.onDispose(() => _subscription?.cancel());

    return session?.user;
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final supabase = ref.read(supabaseClientProvider);
    final result = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    state = AsyncData(result.session?.user);
    return result;
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final supabase = ref.read(supabaseClientProvider);
    final result = await supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'kolabora://auth-callback',
    );
    state = AsyncData(result.session?.user);
    return result;
  }

  Future<void> signOut() async {
    final supabase = ref.read(supabaseClientProvider);
    await supabase.auth.signOut();
    state = const AsyncData(null);
  }
}

final authStateProvider =
    AsyncNotifierProvider<AuthStateNotifier, User?>(AuthStateNotifier.new);
