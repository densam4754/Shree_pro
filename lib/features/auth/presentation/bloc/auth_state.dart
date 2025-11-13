part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoginSuccess extends AuthState {
  final String token;

  const AuthLoginSuccess(this.token);

  @override
  List<Object> get props => [token];
}

class AuthUserLoaded extends AuthState {
  final UserEntity user;

  const AuthUserLoaded(this.user);

  @override
  List<Object> get props => [user];
}

class AuthLogoutSuccess extends AuthState {}

class AuthTokenValid extends AuthState {
  final String token;

  const AuthTokenValid(this.token);

  @override
  List<Object> get props => [token];
}

class AuthTokenInvalid extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

