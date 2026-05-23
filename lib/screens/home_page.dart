import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: FilledButton(
          onPressed: () async {
            await supabase.auth.signOut();
            
            if(!mounted) return;

            context.go('/login');
          },
          child: Text('Sign Out'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:(){
          showModalBottomSheet(
              context: context, 
              isScrollControlled: true,
              builder: (context) => const CreateSpaceSheet(),
            );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class CreateSpaceSheet extends StatefulWidget {
  const CreateSpaceSheet({super.key});

  @override
  State<CreateSpaceSheet> createState() => _CreateSpaceSheetState();
}

class _CreateSpaceSheetState extends State<CreateSpaceSheet> {
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
                onPressed: (){}, 
                child: Text('Create Space'),
              ),
            ]
        )
      ),
    );
  }
}
