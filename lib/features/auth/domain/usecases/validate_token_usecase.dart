import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../repo/auth_repository.dart';

class ValidateTokenUseCase extends UseCase<bool, ValidateTokenParams> {
  final AuthRepository repository;

  ValidateTokenUseCase(this.repository);

  @override
  ResultFuture<bool> call(ValidateTokenParams params) async {
    return await repository.validateToken(params.token);
  }
}

class ValidateTokenParams extends Equatable {
  final String token;

  const ValidateTokenParams({required this.token});

  @override
  List<Object> get props => [token];
}

