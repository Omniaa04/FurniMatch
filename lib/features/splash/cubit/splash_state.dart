abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashShowLogo extends SplashState {}

class SplashShowText extends SplashState {}

class SplashNavigateToOnboarding extends SplashState {}

class SplashNavigateToHome extends SplashState {} // ✅ ضفناها

class SplashError extends SplashState {
  final String message;
  SplashError({required this.message});
}