import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/onboarding_entity.dart';
import '../repo/onboarding_repository.dart';

class GetOnboardingPagesUseCase extends UseCaseNoParams<List<OnboardingEntity>> {
  final OnboardingRepository repository;

  GetOnboardingPagesUseCase(this.repository);

  @override
  ResultFuture<List<OnboardingEntity>> call() async {
    return await repository.getOnboardingPages();
  }
}

