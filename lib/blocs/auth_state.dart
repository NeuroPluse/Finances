part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final dynamic user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class EmailUnverifiedState extends AuthState {
  final String email;
  final dynamic user;
  final String password;
  final bool showError;

  const EmailUnverifiedState({
    required this.email,
    required this.user,
    required this.password,
    this.showError = false,
  });

  @override
  List<Object?> get props => [email, user, showError];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthRegister extends AuthState {}
