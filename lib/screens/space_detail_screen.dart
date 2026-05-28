import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:study_spaces/providers/study_provider.dart';
import 'package:study_spaces/services/study_service.dart';

class SpaceDetailScreen extends ConsumerStatefulWidget {
  final String spaceID;
  final String spaceName;

  const SpaceDetailScreen({
    super.key,
    required this.spaceID,
    required this.spaceName,
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
          title: Text(widget.spaceName),
          bottom: const TabBar(
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
                return Center(child: CircularProgressIndicator());
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
                      onTap: (){},
                    );
                  },
                );
              },
            ),

            notesAsync.when(
              loading: () {
                return Center(child: CircularProgressIndicator());
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
      ),
    );
  }
}