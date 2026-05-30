import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:study_spaces/providers/study_provider.dart';
import 'package:study_spaces/services/study_service.dart';

class SpaceDetailScreen extends ConsumerStatefulWidget {
  final String spaceID;
  final String spaceName;
  final String inviteCode;
  final bool isPublic;

  const SpaceDetailScreen({
    super.key,
    required this.spaceID,
    required this.spaceName,
    required this.inviteCode,
    required this.isPublic,
  });

  @override
  ConsumerState<SpaceDetailScreen> createState() => _SpaceDetailScreenState();
}

class _SpaceDetailScreenState extends ConsumerState<SpaceDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final decksAsync = ref.watch(decksProvider(widget.spaceID));
    final notesAsync = ref.watch(notesProvider(widget.spaceID));

    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        appBar: AppBar(
          title: SelectableText(widget.isPublic?'${widget.spaceName}:${widget.inviteCode}':widget.spaceName),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.style), text: "Decks"),
              Tab(icon: Icon(Icons.notes), text: "Notes"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            decksAsync.when(
              loading: () {
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
              error: (error, stack) {
                return Center(child: Text('Error: $error'));
              },
              data: (decks) {
                if (decks.isEmpty) {
                  return Center(child: Text("No decks yet. Tap + to create one!"));
                }
                return ListView.builder(
                  itemCount: decks.length,
                  itemBuilder: (context, index) {
                    final deck = decks[index];
                    return ListTile(
                      leading: Icon(Icons.folder),
                      title: Text(deck.title),
                      trailing: Icon(Icons.chevron_right),
                      onTap: (){
                        context.push(
                          '/deck',
                        extra: {
                          'deckId': deck.id,
                          'deckTitle': deck.title,
                        },
                        );
                      },
                    );
                  },
                );
              },
            ),

            notesAsync.when(
              loading: () {
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
              error: (error, stack) {
                return Center(child: Text('Error: $error'));
              },
              data: (notes) {
                if(notes.isEmpty){
                  return Center(child: Text("No notes yet. Tap + to create one!"));
                }
                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return ListTile(
                      leading: Icon(Icons.description),
                      title: Text(note.title),
                      trailing: Icon(Icons.chevron_right),
                      onTap: (){},
                    );
                  },
                );
              },
            ),
          ],
        ),
        floatingActionButton: Builder(
          builder: (BuildContext fabContext){
            return FloatingActionButton.extended(
              onPressed:(){
                final currentTab = DefaultTabController.of(fabContext).index;

                if (currentTab==0) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => CreateDeckSheet(spaceId: widget.spaceID),
                  );
                } 
                else{
                  //Note to self: add notes 
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Note to self: add notes')));
                }
              },
              icon:Icon(Icons.add),
              label:Text('Create'),
            );
          }
        )
      )
    );
  }
}

class CreateDeckSheet extends ConsumerStatefulWidget {
  final String spaceId;

  const CreateDeckSheet({
    super.key, 
    required this.spaceId
  });

  @override
  ConsumerState<CreateDeckSheet> createState() => _CreateDeckSheetState();
}

class _CreateDeckSheetState extends ConsumerState<CreateDeckSheet> {
  final TextEditingController _titleController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
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
            Text('Create New Deck'),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Deck Title',
              ),
            ),
            SizedBox(
              child: FilledButton(
                onPressed: _isLoading?null: ()async{

                  final String title = _titleController.text.trim();
                  if(title.isEmpty) return;

                  if(context.mounted){
                    setState(() {
                      _isLoading = true;
                    });
                  }

                  try{
                    await StudyService().createDeck(
                      spaceId: widget.spaceId, 
                      title: title,
                    );

                    ref.invalidate(decksProvider(widget.spaceId));

                    if(context.mounted){
                      context.pop();
                    }
                  } 
                  catch(e){
                    if(context.mounted){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating deck: $e')));
                    }
                  }

                  if(context.mounted){
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },

                child:_isLoading?CircularProgressIndicator(): Text('Create Deck'),
              ),
            ),
          ],
        ),
      )
    );
  }
}