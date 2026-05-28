class Flashcard {
  final String id;
  final String deckId;
  final String frontText;
  final String backText;
  final DateTime createdAt;

  Flashcard({
    required this.id,
    required this.deckId,
    required this.frontText,
    required this.backText,
    required this.createdAt,
  });

  factory Flashcard.fromJSON(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String,
      deckId: json['deck_id'] as String,
      frontText: json['front_text'] as String,
      backText: json['back_text'] as String,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}