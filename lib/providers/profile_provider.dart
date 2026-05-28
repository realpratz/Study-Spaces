import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_spaces/models/user_profile.dart';
import 'package:study_spaces/services/profile_service.dart';

final supabase = Supabase.instance.client;

final profileProvider = FutureProvider<UserProfile>((ref) async {
    return await ProfileService().fetchProfile();
});