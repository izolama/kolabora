import 'package:equatable/equatable.dart';

class Application extends Equatable {
  const Application({
    required this.id,
    required this.postId,
    required this.applicantId,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String postId;
  final String applicantId;
  final String message;
  final String status; // pending | accepted | rejected
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'applicant_id': applicantId,
      'message': message,
      'status': status,
    };
  }

  static Application fromMap(Map<String, dynamic> map) {
    return Application(
      id: map['id'] as String,
      postId: map['post_id'] as String,
      applicantId: map['applicant_id'] as String,
      message: map['message'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, postId, applicantId, message, status];
}
