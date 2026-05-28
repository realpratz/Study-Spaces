import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_spaces/models/deck.dart';
import 'package:study_spaces/models/note.dart';
import 'package:study_spaces/services/study_service.dart';

final decksProvider = FutureProvider.family<List<Deck>, String>((ref, spaceId) async {
  return await StudyService().fetchDecks(spaceId);
});

final notesProvider = FutureProvider.family<List<Note>, String>((ref, spaceId) async {
  return await StudyService().fetchNotes(spaceId);
});