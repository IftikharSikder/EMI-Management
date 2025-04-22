class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String password;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      password: json['password'],
    );
  }
}