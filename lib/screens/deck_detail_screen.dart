import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_spaces/providers/study_provider.dart';
import 'package:study_spaces/services/study_service.dart';

class DeckDetailScreen extends ConsumerWidget {
  final String deckId;
  final String deckTitle;

  const DeckDetailScreen({
    super.key,
    required this.deckId,
    required this.deckTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashcardsAsync = ref.watch(flashcardsProvider(deckId));

    return Scaffold(
      appBar: AppBar(
        title: Text(deckTitle),
      ),
      body: flashcardsAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (flashcards) {},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}