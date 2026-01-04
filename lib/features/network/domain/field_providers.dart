import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fields_repository.dart';
import 'field.dart';

class FieldsNotifier extends AutoDisposeAsyncNotifier<List<Field>> {
  @override
  Future<List<Field>> build() async {
    final repo = ref.watch(fieldsRepositoryProvider);
    return repo.all();
  }
}

final fieldsProvider =
    AutoDisposeAsyncNotifierProvider<FieldsNotifier, List<Field>>(
        FieldsNotifier.new);
