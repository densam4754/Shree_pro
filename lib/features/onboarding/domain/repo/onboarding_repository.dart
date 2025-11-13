import '../../../../core/utils/typedefs.dart';
import '../entities/onboarding_entity.dart';

abstract class OnboardingRepository {
  ResultFuture<List<OnboardingEntity>> getOnboardingPages();
  ResultFuture<bool> isOnboardingCompleted();
  ResultVoid completeOnboarding();
}

