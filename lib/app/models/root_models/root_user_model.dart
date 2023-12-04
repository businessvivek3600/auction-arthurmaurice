abstract class AppUser {
  AppUser();
  Map<String, dynamic> toJson();
  AppUser.fromJson(Map<String, dynamic> json);
}
