import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  const Profile({
    required this.id,
    required this.displayName,
    required this.role,
    this.bio,
    this.location,
    this.createdAt,
    this.fields = const [],
  });

  final String id;
  final String displayName;
  final String role; // owner | vendor | both
  final String? bio;
  final String? location;
  final DateTime? createdAt;
  final List<String> fields;

  Profile copyWith({
    String? displayName,
    String? role,
    String? bio,
    String? location,
    List<String>? fields,
  }) {
    return Profile(
      id: id,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      createdAt: createdAt,
      fields: fields ?? this.fields,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'display_name': displayName,
      'role': role,
      'bio': bio,
      'location': location,
    };
  }

  static Profile fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      displayName: map['display_name'] as String? ?? '',
      role: map['role'] as String? ?? 'owner',
      bio: map['bio'] as String?,
      location: map['location'] as String?,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      fields: (map['fields'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props => [id, displayName, role, bio, location, fields];
}
