import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/models/onboarding_model.dart';

abstract class OnboardingLocalDataSource {
  Future<List<OnboardingModel>> getOnboardingPages();
  Future<bool> isOnboardingCompleted();
  Future<void> completeOnboarding();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final SharedPreferences prefs;

  OnboardingLocalDataSourceImpl({required this.prefs});

  @override
  Future<List<OnboardingModel>> getOnboardingPages() async {
    // Return static onboarding pages with background images
    // Images are mapped based on their content:
    // - refuel-2157211_1280.jpg: Fuel station/refueling scene
    // - fuel-6999650_1280.jpg: Fuel/gas station
    // - Forte Gt.jpg: Vehicle/customer related
    // - data-4570804_1280.jpg: Analytics/data visualization
    return const [
      OnboardingModel(
        title: 'Welcome to Shree Pro',
        description: 'Your complete fuel station management solution\nStreamline operations and boost efficiency',
        imagePath: 'assets/images/onboarding/refuel-2157211_1280.jpg',
      ),
      OnboardingModel(
        title: 'Track Sales & Purchases',
        description: 'Monitor all transactions in real-time\nGet comprehensive insights into your fuel operations',
        imagePath: 'assets/images/onboarding/fuel-6999650_1280.jpg',
      ),
      OnboardingModel(
        title: 'Manage Customers & Suppliers',
        description: 'Build stronger relationships\nKeep detailed records and serve your customers better',
        imagePath: 'assets/images/onboarding/Forte Gt.jpg',
      ),
      OnboardingModel(
        title: 'Analytics & Reports',
        description: 'Make data-driven decisions\nComprehensive analytics and insights at your fingertips',
        imagePath: 'assets/images/onboarding/data-4570804_1280.jpg',
      ),
    ];
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    try {
      return prefs.getBool('notFirstTime') ?? false;
    } catch (e) {
      throw CacheException('Failed to check onboarding status: $e');
    }
  }

  @override
  Future<void> completeOnboarding() async {
    try {
      await prefs.setBool('notFirstTime', true);
      await prefs.setBool('onboarding_completed', true); // Keep for backward compatibility
    } catch (e) {
      throw CacheException('Failed to complete onboarding: $e');
    }
  }
}

