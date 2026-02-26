import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingCubit extends Cubit<int> {
  OnboardingCubit() : super(0);

  void nextPage() => emit(state + 1);

  void previousPage() {
    if (state > 0) emit(state - 1);
  }

  void skip() => emit(2);
}