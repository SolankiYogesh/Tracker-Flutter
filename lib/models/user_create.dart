class UserCreate {

  const UserCreate({
    required this.id,
    required this.email,
    this.name,
    this.picture,
  });
  final String id;
  final String email;
  final String? name;
  final String? picture;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (name != null) 'name': name,
      if (picture != null) 'picture': picture,
    };
  }
}
