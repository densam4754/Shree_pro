import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../repo/auth_repository.dart';

class LogoutUseCase extends UseCaseNoParams<void> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  ResultFuture<void> call() async {
    return await repository.logout();
  }
}

