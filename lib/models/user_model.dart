class UserModel {
  final int? id;
  final String? username;
  final String? email;
  final String? role;
  final String? token;
  final String? avatarUrl;

  UserModel({
    this.id,
    this.username,
    this.email,
    this.role,
    this.token,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      token: json['token'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'token': token,
      'avatar_url': avatarUrl,
    };
  }
}
