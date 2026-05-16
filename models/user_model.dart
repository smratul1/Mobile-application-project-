import 'dart:convert';

class UserModel {
  final String email;
  final String name;
  final String password;

  const UserModel({
    required this.email,
    required this.name,
    required this.password,
  });

  Map<String, dynamic> toMap() => {
        'email': email,
        'name': name,
        'password': password,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        email: map['email'] as String,
        name: map['name'] as String,
        password: map['password'] as String,
      );

  String toJson() => jsonEncode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
