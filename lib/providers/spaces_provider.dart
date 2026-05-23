import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_spaces/models/study_space.dart';

final supabase = Supabase.instance.client;

final spacesProvider = FutureProvider<List<StudySpace>>((ref) async {
  final responseData= await supabase.from('spaces').select();
  
  final mySpaces=responseData.map((item){
    return StudySpace.fromJSON(item);
  }).toList();

  return mySpaces;
});