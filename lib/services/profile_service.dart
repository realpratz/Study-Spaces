import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:study_spaces/models/user_profile.dart';

class ProfileService {
  final _supabase = Supabase.instance.client;

  Future<UserProfile> fetchProfile() async {
    final String currentUserId = _supabase.auth.currentUser!.id;
    final String currentUserEmail = _supabase.auth.currentUser!.email!;

    final responseData = await _supabase.from('profiles').select().eq('id', currentUserId);
    
    if(responseData.isEmpty){    
      Map<String, dynamic> data ={
        'id': currentUserId,
        'email': currentUserEmail,
        'avatar_url': null,
      };
      await _supabase.from('profiles').insert(data);
      return UserProfile.fromJSON(data); 
    } 
    else {    
      return UserProfile.fromJSON(responseData[0]); 
    }
  }

  Future<void> updateAvatarUrl(String url) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('profiles').update({'avatar_url': url}).eq('id', userId);
  }

  Future<void> uploadAvatarFile(File imageFile) async {
    final userId = _supabase.auth.currentUser!.id;
    
    final fileExtension = imageFile.path.split('.').last;
    final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    final path = 'public/$fileName';

    await _supabase.storage.from('avatars').upload(path, imageFile);

    final publicUrl = _supabase.storage.from('avatars').getPublicUrl(path);

    await _supabase.from('profiles').update({'avatar_url': publicUrl}).eq('id', userId);
  }
}