import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/user_entity.dart';
import '../repo/auth_repository.dart';

class GetUserUseCase extends UseCase<UserEntity, GetUserParams> {
  final AuthRepository repository;

  GetUserUseCase(this.repository);

  @override
  ResultFuture<UserEntity> call(GetUserParams params) async {
    return await repository.getUser(params.username);
  }
}

class GetUserParams extends Equatable {
  final String username;

  const GetUserParams({required this.username});

  @override
  List<Object> get props => [username];
}

