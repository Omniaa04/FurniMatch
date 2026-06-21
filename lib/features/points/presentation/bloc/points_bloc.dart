import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/points_model.dart';
import '../../domain/usecases/points_usecases.dart';



abstract class PointsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPointsEvent extends PointsEvent {}

class EarnPointsEvent extends PointsEvent {
  final double purchaseAmount;
  final String orderId;
  EarnPointsEvent({required this.purchaseAmount, required this.orderId});
  @override
  List<Object?> get props => [purchaseAmount, orderId];
}


class RedeemPointsEvent extends PointsEvent {
  final String orderId;
  RedeemPointsEvent({required this.orderId});
  @override
  List<Object?> get props => [orderId];
}

class DeleteTransactionEvent extends PointsEvent {
  final String transactionId;
  DeleteTransactionEvent(this.transactionId);
  @override
  List<Object?> get props => [transactionId];
}



abstract class PointsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PointsInitial extends PointsState {}

class PointsLoading extends PointsState {}

class PointsLoaded extends PointsState {
  final PointsModel points;
  PointsLoaded(this.points);
  @override
  List<Object?> get props => [points];
}

class PointsEarned extends PointsState {
  final PointsModel points;
  final int earnedAmount;
  PointsEarned(this.points, this.earnedAmount);
  @override
  List<Object?> get props => [points, earnedAmount];
}

class PointsRedeemed extends PointsState {
  final PointsModel points;
  final int discountValue;
  final int remainingPoints;
  PointsRedeemed(this.points, this.discountValue, this.remainingPoints);
  @override
  List<Object?> get props => [points, discountValue, remainingPoints];
}

class PointsError extends PointsState {
  final String message;
  PointsError(this.message);
  @override
  List<Object?> get props => [message];
}



class PointsBloc extends Bloc<PointsEvent, PointsState> {
  final GetPointsUseCase getPoints;
  final EarnPointsUseCase earnPoints;
  final RedeemPointsUseCase redeemPoints;
  final SavePointsUseCase savePoints;

  PointsBloc({
    required this.getPoints,
    required this.earnPoints,
    required this.redeemPoints,
    required this.savePoints,
  }) : super(PointsInitial()) {
    on<LoadPointsEvent>(_onLoad);
    on<EarnPointsEvent>(_onEarn);
    on<RedeemPointsEvent>(_onRedeem);
    on<DeleteTransactionEvent>(_onDelete);
  }

  Future<void> _onLoad(LoadPointsEvent e, Emitter<PointsState> emit) async {
    emit(PointsLoading());
    try {
      final p = await getPoints();
      emit(PointsLoaded(p));
    } catch (e) {
      emit(PointsError(e.toString()));
    }
  }

  Future<void> _onEarn(EarnPointsEvent e, Emitter<PointsState> emit) async {
    try {
      final earned = PointsModel.calculatePoints(e.purchaseAmount);
      final updated = await earnPoints(e.purchaseAmount, e.orderId);
      emit(PointsEarned(updated, earned));
      emit(PointsLoaded(updated));
    } catch (err) {
      emit(PointsError(err.toString()));
    }
  }

  Future<void> _onRedeem(RedeemPointsEvent e, Emitter<PointsState> emit) async {
    if (state is! PointsLoaded) return;
    final current = (state as PointsLoaded).points;
    if (!current.canRedeem) {
      emit(PointsError('Not enough points'));
      emit(PointsLoaded(current));
      return;
    }
    try {
      final updated = await redeemPoints(
          PointsModel.pointsPerDiscount, e.orderId);
      emit(PointsRedeemed(
          updated, PointsModel.discountValue, updated.totalPoints));
      emit(PointsLoaded(updated));
    } catch (err) {
      emit(PointsError(err.toString()));
    }
  }

  Future<void> _onDelete(
      DeleteTransactionEvent e, Emitter<PointsState> emit) async {
    if (state is! PointsLoaded) return;
    final current = (state as PointsLoaded).points;
    final updated = current.deleteTransaction(e.transactionId);
    await savePoints(updated);
    emit(PointsLoaded(updated));
  }
}