import 'package:equatable/equatable.dart';

class Workspace extends Equatable {
  const Workspace({
    required this.id,
    required this.postId,
    required this.ownerId,
    required this.status,
    this.title,
    this.members = const [],
  });

  final String id;
  final String postId;
  final String ownerId;
  final String status; // ongoing | completed
  final String? title;
  final List<WorkspaceMember> members;

  Workspace copyWith({
    String? status,
    List<WorkspaceMember>? members,
    String? title,
  }) {
    return Workspace(
      id: id,
      postId: postId,
      ownerId: ownerId,
      status: status ?? this.status,
      title: title ?? this.title,
      members: members ?? this.members,
    );
  }

  static Workspace fromMap(Map<String, dynamic> map) {
    return Workspace(
      id: map['id'] as String,
      postId: map['post_id'] as String,
      ownerId: map['owner_id'] as String,
      status: map['status'] as String? ?? 'ongoing',
      title: map['title'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, postId, ownerId, status, members];
}

class WorkspaceMember extends Equatable {
  const WorkspaceMember({
    required this.workspaceId,
    required this.memberId,
    required this.role,
  });

  final String workspaceId;
  final String memberId;
  final String role; // owner | vendor | partner

  static WorkspaceMember fromMap(Map<String, dynamic> map) {
    return WorkspaceMember(
      workspaceId: map['workspace_id'] as String,
      memberId: map['member_id'] as String,
      role: map['role'] as String? ?? 'partner',
    );
  }

  @override
  List<Object?> get props => [workspaceId, memberId, role];
}
