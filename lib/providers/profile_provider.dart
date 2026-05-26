import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_spaces/models/user_profile.dart';

final supabase = Supabase.instance.client;

final profileProvider = FutureProvider<UserProfile>((ref) async {
  final String currentUserId=supabase.auth.currentUser!.id;
  final String currentUserEmail=supabase.auth.currentUser!.email!;

  final responseData= await supabase.from('profiles').select().eq('id', currentUserId);
  
  if(responseData.isEmpty){    
    Map<String, dynamic> data={};
    data['id']=currentUserId;
    data['email']=currentUserEmail;
    data['avatar_url']=null;

    await supabase.from('profiles').insert(data);
    return UserProfile.fromJSON(data);
    
  } 
  else{    
    return UserProfile.fromJSON(responseData[0]);
  }
});