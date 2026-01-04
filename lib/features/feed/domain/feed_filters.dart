import 'package:equatable/equatable.dart';

class FeedFilters extends Equatable {
  const FeedFilters({
    this.type,
    this.fieldId,
    this.openOnly = true,
  });

  final String? type;
  final String? fieldId;
  final bool openOnly;

  FeedFilters copyWith({
    String? type,
    bool clearType = false,
    String? fieldId,
    bool clearField = false,
    bool? openOnly,
  }) {
    return FeedFilters(
      type: clearType ? null : (type ?? this.type),
      fieldId: clearField ? null : (fieldId ?? this.fieldId),
      openOnly: openOnly ?? this.openOnly,
    );
  }

  @override
  List<Object?> get props => [type, fieldId, openOnly];
}
