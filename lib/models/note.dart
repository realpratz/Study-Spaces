class Note{
  final String id;
  final String spaceId;
  final String title;
  final Map<String, dynamic> content; 
  final DateTime createdAt;

  Note({
    required this.id,
    required this.spaceId,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory Note.fromJSON(Map<String,dynamic> json) {
    return Note(
      id: json['id'] as String,
      spaceId: json['space_id'] as String,
      title: json['title'] as String,
      content: json['content'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}