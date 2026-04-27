import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_ar_model_usecase.dart';
import 'ar_event.dart';
import 'ar_state.dart';

class ArBloc extends Bloc<ArEvent, ArState> {
  final GetArModelUseCase getArModelUseCase;

  ArBloc({required this.getArModelUseCase}) : super(ArInitial()) {
    on<LoadArModelEvent>(_onLoadArModel);
  }

  Future<void> _onLoadArModel(
      LoadArModelEvent event, Emitter<ArState> emit) async {
    emit(ArLoading());
    try {
      final model = await getArModelUseCase(event.productId);

      if (!model.hasAndroidModel && !model.hasIosModel) {
        emit(ArNoModel());
      } else {
        emit(ArLoaded(model));
      }
    } catch (e) {
      emit(ArError(e.toString()));
    }
  }
}