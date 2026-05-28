import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:study_spaces/models/deck.dart';
import 'package:study_spaces/models/flashcard.dart';
import 'package:study_spaces/models/note.dart';

class StudyService {
  final _supabase = Supabase.instance.client;

  Future<List<Deck>> fetchDecks(String spaceId) async {
    final response = await _supabase
        .from('decks')
        .select()
        .eq('space_id', spaceId)
        .order('created_at');
    
    return response.map((json) => Deck.fromJSON(json)).toList();
  }

  Future<void> createDeck({required String spaceId, required String title}) async {
    await _supabase.from('decks').insert({
      'space_id': spaceId,
      'title': title,
    });
  }

  Future<void> deleteDeck(String deckId) async {
    await _supabase.from('decks').delete().eq('id', deckId);
  }

  Future<List<Flashcard>> fetchFlashcards(String deckId) async {
    final response = await _supabase
        .from('flashcards')
        .select()
        .eq('deck_id', deckId)
        .order('created_at');
        
    return response.map((json) => Flashcard.fromJSON(json)).toList();
  }

  Future<void> createFlashcard({required String deckId, required String front, required String back}) async {
    await _supabase.from('flashcards').insert({
      'deck_id': deckId,
      'front_text': front,
      'back_text': back,
    });
  }

  Future<void> updateFlashcard({required String id, required String front, required String back}) async {
    await _supabase.from('flashcards').update({
      'front_text': front,
      'back_text': back,
    }).eq('id', id);
  }

  Future<void> deleteFlashcard(String id) async {
    await _supabase.from('flashcards').delete().eq('id', id);
  }

  Future<List<Note>> fetchNotes(String spaceId) async {
    final response = await _supabase
        .from('notes')
        .select()
        .eq('space_id', spaceId)
        .order('created_at');
        
    return response.map((json) => Note.fromJSON(json)).toList();
  }

  Future<void> createNote({required String spaceId, required String title, required Map<String, dynamic> content}) async {
    await _supabase.from('notes').insert({
      'space_id': spaceId,
      'title': title,
      'content': content,
    });
  }

  Future<void> updateNote({required String id, required String title, required Map<String, dynamic> content}) async {
    await _supabase.from('notes').update({
      'title': title,
      'content': content,
    }).eq('id', id);
  }

  Future<void> deleteNote(String id) async {
    await _supabase.from('notes').delete().eq('id', id);
  }
}