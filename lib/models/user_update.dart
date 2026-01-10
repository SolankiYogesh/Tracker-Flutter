class UserUpdate {
  final String? name;
  final String? picture;

  const UserUpdate({this.name, this.picture});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (picture != null) data['picture'] = picture;

    return data;
  }

  bool get isEmpty => name == null && picture == null;
}
