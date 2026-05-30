class StudySpace{
  final String id; 
  final DateTime createdAt;
  final String name;
  final String? description;
  final bool isPublic;
  final String inviteCode;
  final String creatorId;

  StudySpace({
    required this.id,
    required this.createdAt,
    required this.name,
    this.description,
    required this.isPublic,
    required this.inviteCode,
    required this.creatorId,
  });

  factory StudySpace.fromJSON(Map<String,dynamic> json) {
    return StudySpace(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']),
      name: json['name'] as String,
      description: json['description'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      inviteCode: json['invite_code'] as String,
      creatorId: json['creator_id'] as String,
    );
  }
}