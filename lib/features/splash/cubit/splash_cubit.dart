import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:furnimatch/features/splash/cubit/splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final SharedPreferences prefs;

  SplashCubit({required this.prefs}) : super(SplashInitial());

  Future<void> startSplashSequence() async {
    try {
      /// 1. Show Logo
      emit(SplashShowLogo());
      await Future.delayed(const Duration(milliseconds: 1500));

      /// 2. Show Text
      emit(SplashShowText());
      await Future.delayed(const Duration(milliseconds: 2000));

      /// 3. Check onboarding
      final hasSeenOnboarding = prefs.getBool('onboarding_seen') ?? false;

      if (hasSeenOnboarding) {
        emit(SplashNavigateToHome());
      } else {
        emit(SplashNavigateToOnboarding());
      }

    } catch (e) {
      emit(SplashError(message: e.toString()));
    }
  }
}