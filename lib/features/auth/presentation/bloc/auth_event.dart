part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  const LoginRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [username, password];
}

class GetUserRequested extends AuthEvent {
  final String username;

  const GetUserRequested({required this.username});

  @override
  List<Object> get props => [username];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class ValidateTokenRequested extends AuthEvent {
  final String token;

  const ValidateTokenRequested({required this.token});

  @override
  List<Object> get props => [token];
}

