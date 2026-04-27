import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/room_dimensions.dart';
import '../../domain/usecases/measure_room_usecase.dart';

// ─── Events ────────────────────────────────────────────────────────────────

abstract class MeasurementEvent extends Equatable {
  const MeasurementEvent();
  @override
  List<Object?> get props => [];
}

class StartMeasurementEvent extends MeasurementEvent {
  const StartMeasurementEvent();
}

class ResetMeasurementEvent extends MeasurementEvent {
  const ResetMeasurementEvent();
}

class LoadLastMeasurementEvent extends MeasurementEvent {
  const LoadLastMeasurementEvent();
}

// ─── States ────────────────────────────────────────────────────────────────

abstract class MeasurementState extends Equatable {
  const MeasurementState();
  @override
  List<Object?> get props => [];
}

class MeasurementInitial extends MeasurementState {
  const MeasurementInitial();
}

class MeasurementLoading extends MeasurementState {
  const MeasurementLoading();
}

class MeasurementSuccess extends MeasurementState {
  final RoomDimensions dimensions;
  const MeasurementSuccess({required this.dimensions});
  @override
  List<Object?> get props => [dimensions];
}

class MeasurementFailure extends MeasurementState {
  final String message;
  const MeasurementFailure({required this.message});
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ──────────────────────────────────────────────────────────────────

class MeasurementBloc extends Bloc<MeasurementEvent, MeasurementState> {
  final MeasureRoomUseCase measureRoomUseCase;
  final GetLastMeasurementUseCase getLastMeasurementUseCase;

  MeasurementBloc({
    required this.measureRoomUseCase,
    required this.getLastMeasurementUseCase,
  }) : super(const MeasurementInitial()) {
    on<StartMeasurementEvent>(_onStartMeasurement);
    on<ResetMeasurementEvent>(_onReset);
    on<LoadLastMeasurementEvent>(_onLoadLast);
  }

  Future<void> _onStartMeasurement(
    StartMeasurementEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    emit(const MeasurementLoading());
    try {
      final dimensions = await measureRoomUseCase();
      emit(MeasurementSuccess(dimensions: dimensions));
    } catch (e) {
      emit(MeasurementFailure(message: e.toString()));
    }
  }

  void _onReset(ResetMeasurementEvent event, Emitter<MeasurementState> emit) {
    emit(const MeasurementInitial());
  }

  Future<void> _onLoadLast(
    LoadLastMeasurementEvent event,
    Emitter<MeasurementState> emit,
  ) async {
    try {
      final last = await getLastMeasurementUseCase();
      if (last != null) {
        emit(MeasurementSuccess(dimensions: last));
      }
    } catch (_) {
      // Silently ignore — no previous data is fine
    }
  }
}