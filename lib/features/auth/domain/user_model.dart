class UserModel {
  final String uid;
  final String email;
  final String username;
  final String phoneNumber;
  final String role;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.phoneNumber,
    this.role = 'user',
  });

  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'phoneNumber': phoneNumber,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      role: map['role'] ?? 'user',
    );
  }
}
