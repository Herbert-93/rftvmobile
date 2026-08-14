class AppUser {
  final String uid;
  final String? name;
  final String? email;
  final String? phone;
  final bool isAdmin;

  AppUser({required this.uid, this.name, this.email, this.phone, this.isAdmin = false});

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        uid: json['uid'] as String,
        name: json['name'] as String?,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        isAdmin: json['isAdmin'] as bool? ?? false,
      );
}
