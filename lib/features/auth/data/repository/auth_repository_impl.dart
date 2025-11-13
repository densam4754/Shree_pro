import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repo/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  ResultFuture<String> login(String username, String password) async {
    try {
      // Use NetworkChecker for consistent and reliable network checking
      if (!await NetworkChecker.checkConnection()) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final token = await remoteDataSource.login(username, password);
      await localDataSource.cacheAccessToken(token);
      await localDataSource.cacheUsername(username);
      
      return Right(token);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<UserEntity> getUser(String username) async {
    try {
      // Use NetworkChecker for consistent and reliable network checking
      if (!await NetworkChecker.checkConnection()) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final user = await remoteDataSource.getUser(username);
      await localDataSource.cacheUserProfile(user);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<void> logout() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<String?> getAccessToken() async {
    try {
      final token = await localDataSource.getAccessToken();
      return Right(token);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<bool> validateToken(String token) async {
    try {
      // Check network connection first
      final isConnected = await NetworkChecker.checkConnection();
      if (!isConnected) {
        // If no internet, assume token is valid to allow offline usage
        return const Right(true);
      }

      final isValid = await remoteDataSource.validateToken(token);
      
      // If token is invalid, clear cached tokens
      if (!isValid) {
        await localDataSource.deleteAccessToken();
        await localDataSource.deleteUsername();
      }
      
      return Right(isValid);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

