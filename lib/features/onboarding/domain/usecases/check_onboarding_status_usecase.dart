import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../repo/onboarding_repository.dart';

class CheckOnboardingStatusUseCase extends UseCaseNoParams<bool> {
  final OnboardingRepository repository;

  CheckOnboardingStatusUseCase(this.repository);

  @override
  ResultFuture<bool> call() async {
    return await repository.isOnboardingCompleted();
  }
}

