class ProfileModel {
  String name;
  String email;
  String phone;
  String? profileImageUrl;

  ProfileModel({
    required this.name,
    required this.email,
    required this.phone,
    this.profileImageUrl,
  });
}