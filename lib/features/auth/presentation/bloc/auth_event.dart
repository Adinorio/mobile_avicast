import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignInRequested extends AuthEvent {
  final String userId;
  final String password;

  const SignInRequested({
    required this.userId,
    required this.password,
  });

  @override
  List<Object?> get props => [userId, password];
}

class SignUpRequested extends AuthEvent {
  final String userId;
  final String password;
  final String name;

  const SignUpRequested({
    required this.userId,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [userId, password, name];
}

class SignOutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class ForgotPasswordRequested extends AuthEvent {
  final String userId;

  const ForgotPasswordRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ResetPasswordRequested extends AuthEvent {
  final String token;
  final String newPassword;

  const ResetPasswordRequested({
    required this.token,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [token, newPassword];
} 