class UserUpdate {

  const UserUpdate({this.name, this.picture});
  final String? name;
  final String? picture;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (picture != null) data['picture'] = picture;

    return data;
  }

  bool get isEmpty => name == null && picture == null;
}
