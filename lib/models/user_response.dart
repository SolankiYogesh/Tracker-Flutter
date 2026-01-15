class UserResponse {

  const UserResponse({
    required this.id,
    required this.email,
    required this.name,
    required this.picture,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      picture: json['picture'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
  final String id;
  final String email;
  final String? name;
  final String? picture;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'UserResponse('
        'id: $id, '
        'email: $email, '
        'name: $name, '
        'picture: $picture, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}
