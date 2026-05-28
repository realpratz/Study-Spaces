class Deck {
  final String id;
  final String spaceId;
  final String title;
  final DateTime createdAt;

  Deck({
    required this.id,
    required this.spaceId,
    required this.title,
    required this.createdAt,
  });

  factory Deck.fromJSON(Map<String, dynamic> json) {
    return Deck(
      id: json['id'] as String,
      spaceId: json['space_id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}