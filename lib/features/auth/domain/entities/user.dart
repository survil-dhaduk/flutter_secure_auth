import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final bool isBiometricEnabled;
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    this.isBiometricEnabled = false,
    this.lastLoginAt,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? email,
    bool? isBiometricEnabled,
    DateTime? lastLoginAt,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    isBiometricEnabled,
    lastLoginAt,
    createdAt,
  ];

  @override
  String toString() {
    return 'User(id: $id, email: $email, isBiometricEnabled: $isBiometricEnabled)';
  }
}
