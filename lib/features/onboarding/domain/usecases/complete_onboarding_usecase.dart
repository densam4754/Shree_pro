import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../repo/onboarding_repository.dart';

class CompleteOnboardingUseCase extends UseCaseNoParams<void> {
  final OnboardingRepository repository;

  CompleteOnboardingUseCase(this.repository);

  @override
  ResultFuture<void> call() async {
    return await repository.completeOnboarding();
  }
}

