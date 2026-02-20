class User {
  final int? id;
  final String name;
  final String username;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final String? location;
  final String? website;
  final String? joinDate;
  final int followersCount;
  final int followingCount;

  User({
    this.id,
    required this.name,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.bio,
    this.location,
    this.website,
    this.joinDate,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      website: json['website'] as String?,
      joinDate: json['joinDate'] as String?,
      followersCount: json['followersCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'location': location,
      'website': website,
      'joinDate': joinDate,
      'followersCount': followersCount,
      'followingCount': followingCount,
    };
  }
}
