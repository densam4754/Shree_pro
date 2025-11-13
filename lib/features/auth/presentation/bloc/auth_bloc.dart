import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/validate_token_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final GetUserUseCase getUserUseCase;
  final LogoutUseCase logoutUseCase;
  final ValidateTokenUseCase validateTokenUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.getUserUseCase,
    required this.logoutUseCase,
    required this.validateTokenUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<GetUserRequested>(_onGetUserRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ValidateTokenRequested>(_onValidateTokenRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final loginResult = await loginUseCase(LoginParams(
      username: event.username,
      password: event.password,
    ));

    await loginResult.fold(
      (failure) async => emit(AuthError(failure.message)),
      (token) async {
        final userResult = await getUserUseCase(
          GetUserParams(username: event.username),
        );

        userResult.fold(
          (failure) => emit(
            AuthError(
              failure.message.isNotEmpty
                  ? failure.message
                  : 'Failed to load user profile.',
            ),
          ),
          (_) => emit(AuthLoginSuccess(token)),
        );
      },
    );
  }

  Future<void> _onGetUserRequested(
    GetUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await getUserUseCase(GetUserParams(username: event.username));

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthUserLoaded(user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await logoutUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthLogoutSuccess()),
    );
  }

  Future<void> _onValidateTokenRequested(
    ValidateTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await validateTokenUseCase(
      ValidateTokenParams(token: event.token),
    );

    result.fold(
      (failure) => emit(AuthTokenInvalid()),
      (isValid) {
        if (isValid) {
          emit(AuthTokenValid(event.token));
        } else {
          emit(AuthTokenInvalid());
        }
      },
    );
  }
}

