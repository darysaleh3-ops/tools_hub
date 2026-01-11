class UserModel {
  final String uid;
  final String email;
  final String username;
  final String phoneNumber;
  final String role;
  final String status;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.phoneNumber,
    this.role = 'user',
    this.status = 'active',
  });

  bool get isAdmin => role == 'admin';
  bool get isActive => status == 'active';

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'phoneNumber': phoneNumber,
      'role': role,
      'status': status,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      role: (map['role'] ?? 'user').toString().trim(),
      status: map['status'] ?? 'active',
    );
  }
}
