import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:study_spaces/providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading=false;
  final TextEditingController _UrlController = TextEditingController();

  @override
  void dispose(){
    _UrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  final profileAsyncValue = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_sharp),
            onPressed: (){
              if (context.mounted){
                context.go('/home');
              }
            },
          ),
        ]
      ),
      body: profileAsyncValue.when(
        error: (error, StackTrace){
          return Center(child: Text('Error: $error'));
        },
        loading: () {
          return Center(child: CircularProgressIndicator());
        },
        data: (profile) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    //Note to self---> add supabase storage based avatar feature in future
                    backgroundImage: profile.avatarUrl!=null?NetworkImage(profile.avatarUrl!):null,
                    child: profile.avatarUrl==null?Icon(Icons.person):null,
                  ),
                  Text(profile.email),
                  TextField(
                    controller: _UrlController,
                  ),
                  FilledButton(
                    onPressed: _isLoading? null : () async {
                      if (_UrlController.text.trim().isEmpty) return;

                      setState(() {
                        _isLoading = true;
                      });

                      try{
                        await supabase.from('profiles').update({'avatar_url': _UrlController.text.trim()}).eq('id',profile.id);

                        ref.invalidate(profileProvider);

                        if(context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile Updated!')));
                          _UrlController.clear();
                        }
                      }
                      catch(e){
                        print('Updating Profile Failed: $e');

                        if(context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                        }
                      }    

                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }, 
                    child: _isLoading?CircularProgressIndicator():Text('Save'),
                  ),
                ],
              )
            )
          );
        },
      ),
    );
  }
}