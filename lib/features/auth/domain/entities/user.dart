import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final bool isPinSet;
  final bool isBiometricEnabled;
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    this.isPinSet = false,
    this.isBiometricEnabled = false,
    this.lastLoginAt,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? email,
    bool? isPinSet,
    bool? isBiometricEnabled,
    DateTime? lastLoginAt,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      isPinSet: isPinSet ?? this.isPinSet,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    isPinSet,
    isBiometricEnabled,
    lastLoginAt,
    createdAt,
  ];

  @override
  String toString() {
    return 'User(id: $id, email: $email, isPinSet: $isPinSet, isBiometricEnabled: $isBiometricEnabled)';
  }
}
