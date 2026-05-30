import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_spaces/models/study_space.dart';
import 'package:study_spaces/services/space_service.dart';

final supabase = Supabase.instance.client;

final spacesProvider = FutureProvider<List<StudySpace>>((ref) async {
  //for shimmer tests
  //await Future.delayed(Duration(seconds: 15));

  return await SpaceService().fetchSpaces();
});