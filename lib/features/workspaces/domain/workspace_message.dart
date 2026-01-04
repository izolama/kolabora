import 'package:equatable/equatable.dart';

class WorkspaceMessage extends Equatable {
  const WorkspaceMessage({
    required this.id,
    required this.workspaceId,
    required this.senderId,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String workspaceId;
  final String senderId;
  final String message;
  final DateTime createdAt;

  static WorkspaceMessage fromMap(Map<String, dynamic> map) {
    return WorkspaceMessage(
      id: map['id'] as String,
      workspaceId: map['workspace_id'] as String,
      senderId: map['sender_id'] as String,
      message: map['message'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, workspaceId, senderId, message, createdAt];
}
