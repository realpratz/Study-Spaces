class UserProfile{
  final String id; 
  final String email;
  final String? avatarUrl; 

  UserProfile({
    required this.id,
    required this.email,
    this.avatarUrl,
  });

  factory UserProfile.fromJSON(Map<String,dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}