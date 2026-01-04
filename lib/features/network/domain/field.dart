import 'package:equatable/equatable.dart';

class Field extends Equatable {
  const Field({required this.id, required this.name});

  final String id;
  final String name;

  static Field fromMap(Map<String, dynamic> map) {
    return Field(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
}
