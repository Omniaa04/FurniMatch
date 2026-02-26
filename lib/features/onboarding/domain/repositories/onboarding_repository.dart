import 'package:furnimatch/features/onboarding/domain/entities/onboarding_entity.dart';

abstract class OnboardingRepository {
  Future<List<OnboardingEntity>> getOnboardingPages();
  Future<void> saveOnboardingSeen();
  Future<bool> checkIfOnboardingSeen();
}
