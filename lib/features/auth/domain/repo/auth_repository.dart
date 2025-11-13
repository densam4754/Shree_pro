import '../../../../core/utils/typedefs.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  ResultFuture<String> login(String username, String password);
  ResultFuture<UserEntity> getUser(String username);
  ResultFuture<void> logout();
  ResultFuture<String?> getAccessToken();
  ResultFuture<bool> validateToken(String token);
}

