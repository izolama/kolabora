import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://xmqhbgdmebogcvkwuwhs.supabase.co',
);

const supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_qTL8hTfU624n6ZSHLiZu6w_H3lrMCQF',
);

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
