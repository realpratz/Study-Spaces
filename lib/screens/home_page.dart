import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import "package:study_spaces/providers/spaces_provider.dart";
import 'package:study_spaces/models/study_space.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

final supabase = Supabase.instance.client;

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final spacesAsyncValue = ref.watch(spacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Spaces'),
        actions: [
          IconButton(
            icon: Icon(Icons.group_add),
            onPressed:() async {
              final TextEditingController _inviteController = TextEditingController();

              showDialog(
                context: context,
                builder: (context){
                  return AlertDialog(
                    title:Text('Join Space'),
                    content: TextField(
                      controller: _inviteController,
                      decoration: InputDecoration(
                        hintText: 'Enter 6-digit code',
                      ),
                    ),
                    actions:[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          final typedCode=_inviteController.text.trim();

                          try{
                            final spaceId = await supabase.rpc(
                              'check_invite_code', 
                              params: {
                                'code': typedCode
                                }
                            );

                            if (spaceId == null){
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid code!')));
                              return;
                            }
                            
                            Map<String, dynamic> data = {};
                            data['space_id'] = spaceId;
                            data['user_id']=supabase.auth.currentUser!.id;

                            await supabase.from('space_members').insert(data);
                            
                            ref.invalidate(spacesProvider);

                            if(context.mounted) {
                              Navigator.pop(context);
                            }
                          }
                          catch(e){
                            if(context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                            }
                          }     
                        },
                        child: Text('Join'),
                      )
                    ]
                  );
                }
              );
            },
            )
        ],
      ),
      body: spacesAsyncValue.when(
        error: (error, StackTrace){
          return Center(child: Text('Error: $error'));
        },
        loading: () {
          return Center(child: CircularProgressIndicator());
        },
        data: (List<StudySpace> spaces){
          /*return Center(
            child: FilledButton(
              onPressed: () async {
                await supabase.auth.signOut();
                
                if(!mounted) return;

                context.go('/login');
              },
              child: Text('Sign Out'),
            ),
          );*/
          return ListView.builder(
            itemCount: spaces.length,
            itemBuilder: (context, index) {
              final currentSpace = spaces[index];
              
              return ListTile(
                title: Text(currentSpace.name),
                subtitle: Text(currentSpace.description ?? 'No Description'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
            onPressed:(){
              showModalBottomSheet(
                  context: context, 
                  isScrollControlled: true,
                  builder: (context) => CreateSpaceSheet(),
                );
            },
            child: Icon(Icons.add),
      ),
    );
  }
}

class CreateSpaceSheet extends ConsumerStatefulWidget {
  const CreateSpaceSheet({super.key});

  @override
  ConsumerState<CreateSpaceSheet> createState() => _CreateSpaceSheetState();
}

class _CreateSpaceSheetState extends ConsumerState<CreateSpaceSheet> {
  final TextEditingController _spaceName = TextEditingController();
  final TextEditingController _description = TextEditingController();
  bool isPublic = false;

  @override
  void dispose(){
    _spaceName.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  label: Text('Space Name'),
                ),
                controller: _spaceName,
              ),
              TextField(
                decoration: InputDecoration(
                  label: Text('Description'),
                ),
                controller: _description,
              ),
              SwitchListTile(
                title: Text('Others can view this space'),
                value: isPublic,
                onChanged: (bool value) {
                  setState(() {
                    isPublic=value;
                  });
                }
              ),
              ElevatedButton(
                onPressed: () async {
                  Map<String, dynamic> data = {};
                  data['name']=_spaceName.text;
                  data['description']=_description.text.isEmpty?null:_description.text;
                  data['is_public']=isPublic;
                  data['creator_id']=supabase.auth.currentUser!.id;
                  data['invite_code']=Random().nextInt(999999).toString();

                  await supabase.from('spaces').insert(data);
                  
                  ref.invalidate(spacesProvider);

                  if(context.mounted) {
                    Navigator.pop(context);
                  }
                }, 
                child: Text('Create Space'),
              ),
            ]
        )
      ),
    );
  }
}
