class UserModel {
  final int? id;
  final String? username;
  final String? email;
  final String? role;
  final int? roleId;
  final String? token;
  final String? avatarUrl;

  UserModel({
    this.id,
    this.username,
    this.email,
    this.role,
    this.roleId,
    this.token,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      roleId: json['role_id'] as int?,
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
      'role_id': roleId,
      'token': token,
      'avatar_url': avatarUrl,
    };
  }
}
