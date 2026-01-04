import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase/client.dart';

Future<void> bootstrap(ProviderContainer container) async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Warm up the client so first queries feel snappy.
  container.read(supabaseClientProvider);
}
