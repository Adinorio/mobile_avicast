import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? profilePicture;
  final List<String> roles;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.profilePicture,
    required this.roles,
    required this.createdAt,
    this.lastLoginAt,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    profilePicture,
    roles,
    createdAt,
    lastLoginAt,
    isActive,
  ];

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? profilePicture,
    List<String>? roles,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }
} 