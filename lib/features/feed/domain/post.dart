import 'package:equatable/equatable.dart';

class Post extends Equatable {
  const Post({
    required this.id,
    required this.authorId,
    required this.type,
    required this.title,
    required this.description,
    required this.compensationType,
    required this.timeline,
    required this.status,
    required this.createdAt,
    this.fields = const [],
  });

  final String id;
  final String authorId;
  final String type; // looking_vendor | open_project | collaboration | offer_service
  final String title;
  final String description;
  final String compensationType; // paid | rev_share | negotiable
  final String timeline;
  final String status; // open | closed
  final DateTime createdAt;
  final List<String> fields;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author_id': authorId,
      'type': type,
      'title': title,
      'description': description,
      'compensation_type': compensationType,
      'timeline': timeline,
      'status': status,
    };
  }

  static Post fromMap(Map<String, dynamic> map) {
    final fields = <String>[];
    if (map['fields'] is List) {
      fields.addAll(
        (map['fields'] as List<dynamic>).map((e) => e.toString()),
      );
    } else if (map['post_fields'] is List) {
      fields.addAll(
        (map['post_fields'] as List<dynamic>)
            .map((e) => (e as Map<String, dynamic>)['field_id'].toString()),
      );
    }

    return Post(
      id: map['id'] as String,
      authorId: map['author_id'] as String,
      type: map['type'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      compensationType: map['compensation_type'] as String? ?? 'negotiable',
      timeline: map['timeline'] as String? ?? '',
      status: map['status'] as String? ?? 'open',
      createdAt: DateTime.parse(map['created_at'] as String),
      fields: fields,
    );
  }

  @override
  List<Object?> get props => [
        id,
        authorId,
        type,
        title,
        description,
        compensationType,
        timeline,
        status,
        createdAt,
        fields,
      ];
}
