class UserUpdate {

  const UserUpdate({
    this.name,
    this.picture,
    this.username,
    this.gender,
    this.birthdate,
    this.phoneNumber,
    this.socialMediaLinks,
  });
  final String? name;
  final String? picture;
  final String? username;
  final String? gender;
  final DateTime? birthdate;
  final String? phoneNumber;
  final Map<String, dynamic>? socialMediaLinks;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (picture != null) data['picture'] = picture;
    if (username != null) data['username'] = username;
    if (gender != null) data['gender'] = gender;
    if (birthdate != null) data['birthdate'] = birthdate!.toIso8601String().split('T')[0]; // Send date only
    if (phoneNumber != null) data['phone_number'] = phoneNumber;
    if (socialMediaLinks != null) data['social_media_links'] = socialMediaLinks;

    return data;
  }

  bool get isEmpty => 
    name == null && 
    picture == null && 
    username == null && 
    gender == null && 
    birthdate == null && 
    phoneNumber == null && 
    socialMediaLinks == null;
}
