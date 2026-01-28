class UserResponse {

  const UserResponse({
    required this.id,
    required this.email,
    this.username,
    required this.name,
    required this.picture,
    this.profilePictureKey,
    this.gender,
    this.birthdate,
    this.phoneNumber,
    this.socialMediaLinks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      name: json['name'] as String?,
      picture: json['picture'] as String?,
      profilePictureKey: json['profile_picture_key'] as String?,
      gender: json['gender'] as String?,
      birthdate: json['birthdate'] != null ? DateTime.parse(json['birthdate'] as String) : null,
      phoneNumber: json['phone_number'] as String?,
      socialMediaLinks: json['social_media_links'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
  final String id;
  final String email;
  final String? username;
  final String? name;
  final String? picture;
  final String? profilePictureKey;
  final String? gender;
  final DateTime? birthdate;
  final String? phoneNumber;
  final Map<String, dynamic>? socialMediaLinks;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'UserResponse('
        'id: $id, '
        'email: $email, '
        'username: $username, '
        'name: $name, '
        'picture: $picture, '
        'gender: $gender, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}
