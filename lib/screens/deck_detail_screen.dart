import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:study_spaces/models/flashcard.dart';
import 'package:study_spaces/providers/study_provider.dart';
import 'package:study_spaces/services/study_service.dart';

class DeckDetailScreen extends ConsumerWidget{
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
        loading: (){
         return ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[700]!,
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  subtitle: Container(
                    height: 14,
                    width: 150,
                    color: Colors.white,
                    margin: EdgeInsets.only(top: 8),
                  ),
                ),
              );
            }
         );
        },
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (flashcards) {
          if (flashcards.isEmpty) {
            return Center(child: Text("No cards yet. Tap + to create one!"));
          }
          return ListView.builder(
            itemCount: flashcards.length,
            itemBuilder: (context, index) {
              final card = flashcards[index];
              return Card(
                child: ListTile(
                  title: Text(card.frontText),
                  subtitle: Text(card.backText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => CreateFlashcardSheet(
                              deckId: deckId,
                              existingCard: card,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await StudyService().deleteFlashcard(card.id);
                          ref.invalidate(flashcardsProvider(deckId));
                        },
                      ),
                    ]
                  )
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => CreateFlashcardSheet(deckId: deckId),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class CreateFlashcardSheet extends ConsumerStatefulWidget {
  final String deckId;
  final Flashcard? existingCard;

  const CreateFlashcardSheet({
    super.key,
    required this.deckId,
    this.existingCard,
  });

  @override
  ConsumerState<CreateFlashcardSheet> createState() => _CreateFlashcardSheetState();
}

class _CreateFlashcardSheetState extends ConsumerState<CreateFlashcardSheet> {
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingCard!=null) {
      _frontController.text=widget.existingCard!.frontText;
      _backController.text=widget.existingCard!.backText;
    }
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.existingCard==null?'New Flashcard':'Edit Flashcard'),
            TextField(
              controller: _frontController,
              decoration: InputDecoration(
                labelText: 'Front (Question)',
              ),
            ),
            TextField(
              controller: _backController,
              decoration: InputDecoration(
                labelText: 'Back (Answer)',
              ),
            ),
            SizedBox(
              child: FilledButton(
                onPressed: _isLoading?null:()async{
                  final String front = _frontController.text.trim();
                  final String back = _backController.text.trim();
                  
                  if(front.isEmpty||back.isEmpty) return;

                  if(context.mounted){
                    setState(() {
                      _isLoading = true;
                    });
                  }

                  try{
                    if(widget.existingCard==null){
                      await StudyService().createFlashcard(
                        deckId: widget.deckId,
                        front: front,
                        back: back,
                      );
                    } 
                    else{
                      await StudyService().updateFlashcard(
                        id: widget.existingCard!.id,
                        front: front,
                        back: back,
                      );
                    }

                    ref.invalidate(flashcardsProvider(widget.deckId));
                    
                    if(context.mounted){
                      context.pop();
                    }
                  } 
                  catch(e){
                    if(context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                  
                  if (context.mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                child: _isLoading?CircularProgressIndicator():Text('Save Card'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}