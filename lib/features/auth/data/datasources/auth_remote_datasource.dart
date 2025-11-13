import '../../../../core/errors/exceptions.dart';
import '../services/auth_service.dart';
import '../../domain/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<String> login(String username, String password);
  Future<UserModel> getUser(String username);
  Future<bool> validateToken(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthService authService;

  AuthRemoteDataSourceImpl({required this.authService});

  @override
  Future<String> login(String username, String password) async {
    try {
      return await authService.login(username, password);
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw AuthException('Login failed: $e');
    }
  }

  @override
  Future<UserModel> getUser(String username) async {
    try {
      return await authService.getUser(username);
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw AuthException('Failed to get user: $e');
    }
  }

  @override
  Future<bool> validateToken(String token) async {
    try {
      return await authService.validateToken(token);
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw AuthException('Failed to validate token: $e');
    }
  }
}

