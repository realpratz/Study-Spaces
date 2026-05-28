import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:study_spaces/models/study_space.dart';
import 'dart:math';

class SpaceService {
  final _supabase = Supabase.instance.client;

  Future<List<StudySpace>> fetchSpaces() async {
    final responseData = await _supabase.from('spaces').select();
    
    return responseData.map((item) {
      return StudySpace.fromJSON(item);
    }).toList();
  }

  Future<void> joinSpace(String inviteCode) async {
    final spaceId = await _supabase.rpc(
      'check_invite_code', 
      params: {
        'code': inviteCode
        }
    );

    if(spaceId==null){
      throw Exception('Invalid code!');
    }
    
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('space_members').insert({
      'space_id': spaceId,
      'user_id': userId,
    });
  }

  Future<void> createSpace({
    required String name, 
    required String? description, 
    required bool isPublic,
  }) 
  async{
    final userId = _supabase.auth.currentUser!.id;
    final inviteCode = Random().nextInt(999999).toString().padLeft(6,'0');

    await _supabase.from('spaces').insert({
      'name': name,
      'description': description,
      'is_public': isPublic,
      'creator_id': userId,
      'invite_code': inviteCode,
    });
  }
}