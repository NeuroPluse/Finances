part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const RegisterEvent({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginEvent({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

class CheckEmailVerificationEvent extends AuthEvent {
  final dynamic user;
  final String email;
  final String password;

  const CheckEmailVerificationEvent({
    required this.user,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [user, email, password];
}

class ConfirmEmailEvent extends AuthEvent {
  final dynamic user;

  const ConfirmEmailEvent({required this.user});

  @override
  List<Object?> get props => [user];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();

  @override
  List<Object?> get props => [];
}

class ShowRegisterEvent extends AuthEvent {
  const ShowRegisterEvent();

  @override
  List<Object?> get props => [];
}

class CheckSavedSessionEvent extends AuthEvent {
  final bool afterLogout;

  const CheckSavedSessionEvent({this.afterLogout = false});

  @override
  List<Object?> get props => [afterLogout];
}

class RegisterButtonPressedEvent extends AuthEvent {
  const RegisterButtonPressedEvent();

  @override
  List<Object?> get props => [];
}
