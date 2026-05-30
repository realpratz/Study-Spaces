import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:study_spaces/providers/profile_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:study_spaces/services/profile_service.dart';

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
        data: (profile) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: profile.avatarUrl != null?NetworkImage(profile.avatarUrl!):null,
                          child: profile.avatarUrl == null?Icon(Icons.person):null,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            onPressed: _isLoading ? null : () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                              
                              if (image == null) return;

                              setState(() {
                                _isLoading = true;
                              });

                              try{
                                await ProfileService().uploadAvatarFile(File(image.path));
                                
                                ref.invalidate(profileProvider); 
                                
                                if(context.mounted){
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Avatar uploaded!')));
                                }
                              } 
                              catch(e)
                              {
                                print('Uploading Avatar Failed: $e');

                                if(context.mounted){
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
                                }
                              }
                              if(context.mounted){
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Center(child: Text(profile.email)),
                  SizedBox(height: 24),
                  TextField(
                    controller: _UrlController,
                  ),
                  SizedBox(height: 16),
                  FilledButton(
                    onPressed: _isLoading? null : () async {
                      if (_UrlController.text.trim().isEmpty) return;

                      setState(() {
                        _isLoading = true;
                      });

                      try{
                        await ProfileService().updateAvatarUrl(_UrlController.text.trim());

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

                      if(context.mounted) {
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