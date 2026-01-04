import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/client.dart';
import '../domain/field.dart';

class FieldsRepository {
  FieldsRepository(this._client);

  final SupabaseClient _client;

  Future<List<Field>> all() async {
    final data = await _client.from('fields').select().order('name');
    return (data as List<dynamic>)
        .map((row) => Field.fromMap(row as Map<String, dynamic>))
        .toList();
  }
}

final fieldsRepositoryProvider = Provider<FieldsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return FieldsRepository(client);
});
