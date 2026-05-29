import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import "package:study_spaces/providers/spaces_provider.dart";
import 'package:study_spaces/models/study_space.dart';
import 'package:study_spaces/services/auth_service.dart';
import 'package:study_spaces/services/space_service.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

final supabase = Supabase.instance.client;

class _HomePageState extends ConsumerState<HomePage> {
  bool _isLoading=false;
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
                        onPressed: () => context.pop(),
                        child: Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: _isLoading?null: () async {
                          final typedCode=_inviteController.text.trim();

                          setState(() {
                            _isLoading = true;
                          });

                          try{
                            await SpaceService().joinSpace(typedCode);

                            ref.invalidate(spacesProvider);

                            if(context.mounted) {
                              context.pop();
                            }
                          }
                          catch(e){
                            print('Joining Space Failed: $e');

                            if(context.mounted) {
                              if(e is PostgrestException && e.code=='23505') {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You are already a member of this space!')));
                              }
                              else{
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred while joining. Try again later.')));
                              }
                            }
                          }

                          if(context.mounted){
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                        child:_isLoading?CircularProgressIndicator(): Text('Join'),
                      )
                    ]
                  );
                }
              );
            },
            ),
            IconButton(
                icon: Icon(Icons.logout),
                onPressed: () async {
                  await AuthService().signOut();

                  if (context.mounted){
                    context.go('/login');
                  }
                },
              ),
            IconButton(
              icon: Icon(Icons.home),
              onPressed: (){
                if (context.mounted){
                  context.go('/profile');
                }
              },
            ),
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
          return ListView.builder(
            itemCount: spaces.length,
            itemBuilder: (context, index) {
              final currentSpace = spaces[index];
              
              return ListTile(
                title: Text(currentSpace.name),
                subtitle: Text(currentSpace.description ?? 'No Description'),
                onTap: (){
                  context.push(
                    '/space',
                    extra:{
                      'id': currentSpace.id,
                      'name': currentSpace.name,
                    },
                  );
                },
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
  bool _isLoading=false;

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
                onPressed: _isLoading? null : () async {
                  if (_spaceName.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Space name cannot be empty!')));
                    return;
                  }

                  setState(() {
                    _isLoading = true;
                  });

                  bool success=false;

                  while(!success){
                    try{
                      await SpaceService().createSpace(
                        name: _spaceName.text.trim(),
                        description: _description.text.trim().isEmpty ? null : _description.text.trim(),
                        isPublic: isPublic,
                      );

                      ref.invalidate(spacesProvider);

                      success=true;

                      if(context.mounted) {
                        context.pop();
                      }
                    }
                    catch(e){
                      print('Creating Space Failed: $e');

                      if(e is PostgrestException && e.code=='23505') {
                        print('unique code not unique');
                      }
                      else{
                        if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred while joining. Try again later.')));
                        break;
                      }
                    }    
                  }

                  if (context.mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }, 
                child: _isLoading?CircularProgressIndicator(): Text('Create Space'),
              ),
            ]
        )
      ),
    );
  }
}
