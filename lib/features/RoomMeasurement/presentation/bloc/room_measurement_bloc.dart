import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import '../../data/services/ar_measurement_service.dart';
import '../../domain/models/room_model.dart';
import '../../domain/usecases/room_measurement_usecases.dart';

// ─────────────────────────────────────────────
//  Events
// ─────────────────────────────────────────────
abstract class RoomMeasurementEvent {}

/// ARCore جاهز
class ArControllerReadyEvent extends RoomMeasurementEvent {
  ArControllerReadyEvent(this.controller);
  final ArCoreController controller;
}

/// المستخدم وضع نقطة جديدة
class PointAddedEvent extends RoomMeasurementEvent {
  PointAddedEvent(this.pointCount);
  final int pointCount;
}

/// المستخدم ضغط "احسب"
class CalculateMeasurementEvent extends RoomMeasurementEvent {}

/// المستخدم حفظ الغرفة
class SaveRoomEvent extends RoomMeasurementEvent {
  SaveRoomEvent(this.name);
  final String name;
}

/// تحميل قائمة الغرف المحفوظة
class LoadRoomsEvent extends RoomMeasurementEvent {}

/// حذف غرفة
class DeleteRoomEvent extends RoomMeasurementEvent {
  DeleteRoomEvent(this.index);
  final int index;
}

/// تعديل اسم غرفة
class UpdateRoomNameEvent extends RoomMeasurementEvent {
  UpdateRoomNameEvent({required this.index, required this.room, required this.newName});
  final int index;
  final RoomModel room;
  final String newName;
}

/// إعادة ضبط الجلسة
class ResetSessionEvent extends RoomMeasurementEvent {}

// ─────────────────────────────────────────────
//  States
// ─────────────────────────────────────────────
abstract class RoomMeasurementState {}

class RoomMeasurementInitial extends RoomMeasurementState {}

/// AR session شغالة وبتستنى نقط
class ArSessionActiveState extends RoomMeasurementState {
  ArSessionActiveState({required this.pointCount});
  final int pointCount; // عدد النقط الموضوعة حتى الآن
}

/// النتيجة جاهزة — عايز اسم الغرفة
class MeasurementReadyState extends RoomMeasurementState {
  MeasurementReadyState({required this.result});
  final ArMeasurementResult result;
}

/// جاري الحفظ
class SavingState extends RoomMeasurementState {}

/// الغرف المحفوظة جاهزة للعرض
class RoomsLoadedState extends RoomMeasurementState {
  RoomsLoadedState(this.rooms);
  final List<RoomModel> rooms;
}

/// خطأ عام
class RoomMeasurementErrorState extends RoomMeasurementState {
  RoomMeasurementErrorState(this.message);
  final String message;
}

// ─────────────────────────────────────────────
//  Bloc
// ─────────────────────────────────────────────
class RoomMeasurementBloc
    extends Bloc<RoomMeasurementEvent, RoomMeasurementState> {
  RoomMeasurementBloc({
    required this.arService,
    required GetRoomsUseCase getRooms,
    required SaveRoomUseCase saveRoom,
    required DeleteRoomUseCase deleteRoom,
    required UpdateRoomNameUseCase updateRoomName,
  })  : _getRooms = getRooms,
        _saveRoom = saveRoom,
        _deleteRoom = deleteRoom,
        _updateRoomName = updateRoomName,
        super(RoomMeasurementInitial()) {
    on<ArControllerReadyEvent>(_onArReady);
    on<PointAddedEvent>(_onPointAdded);
    on<CalculateMeasurementEvent>(_onCalculate);
    on<SaveRoomEvent>(_onSaveRoom);
    on<LoadRoomsEvent>(_onLoadRooms);
    on<DeleteRoomEvent>(_onDeleteRoom);
    on<UpdateRoomNameEvent>(_onUpdateRoomName);
    on<ResetSessionEvent>(_onReset);
  }

  final ArMeasurementService arService;
  final GetRoomsUseCase _getRooms;
  final SaveRoomUseCase _saveRoom;
  final DeleteRoomUseCase _deleteRoom;
  final UpdateRoomNameUseCase _updateRoomName;

  // ── Handlers ───────────────────────────────

  void _onArReady(ArControllerReadyEvent e, Emitter emit) {
    arService.initController(e.controller);

    // لما تتضاف نقطة، نبعت event
    arService.onPointAdded = (count) => add(PointAddedEvent(count));

    emit(ArSessionActiveState(pointCount: 0));
  }

  void _onPointAdded(PointAddedEvent e, Emitter emit) {
    emit(ArSessionActiveState(pointCount: e.pointCount));
  }

  void _onCalculate(CalculateMeasurementEvent e, Emitter emit) {
    final result = arService.getResult();
    if (result == null) {
      emit(RoomMeasurementErrorState('ضع نقطتين على الأقل على السطح'));
      return;
    }
    emit(MeasurementReadyState(result: result));
  }

  Future<void> _onSaveRoom(SaveRoomEvent e, Emitter emit) async {
    final result = arService.getResult();
    if (result == null) return;

    emit(SavingState());
    try {
      final room = RoomModel(
        name: e.name.trim(),
        widthM: result.widthM,
        heightM: result.heightM,
        area: result.area,
        date: DateTime.now().toIso8601String(),
      );
      await _saveRoom(room);
      add(LoadRoomsEvent());
    } catch (err) {
      emit(RoomMeasurementErrorState(err.toString()));
    }
  }

  Future<void> _onLoadRooms(LoadRoomsEvent e, Emitter emit) async {
    try {
      final rooms = await _getRooms();
      emit(RoomsLoadedState(rooms));
    } catch (err) {
      emit(RoomMeasurementErrorState(err.toString()));
    }
  }

  Future<void> _onDeleteRoom(DeleteRoomEvent e, Emitter emit) async {
    try {
      await _deleteRoom(e.index);
      add(LoadRoomsEvent());
    } catch (err) {
      emit(RoomMeasurementErrorState(err.toString()));
    }
  }

  Future<void> _onUpdateRoomName(UpdateRoomNameEvent e, Emitter emit) async {
    try {
      await _updateRoomName(e.index, e.room, e.newName);
      add(LoadRoomsEvent());
    } catch (err) {
      emit(RoomMeasurementErrorState(err.toString()));
    }
  }

  void _onReset(ResetSessionEvent e, Emitter emit) {
    arService.reset();
    emit(ArSessionActiveState(pointCount: 0));
  }

  @override
  Future<void> close() {
    arService.dispose();
    return super.close();
  }
}