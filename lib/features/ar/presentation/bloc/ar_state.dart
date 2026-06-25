import '../../domain/entities/ar_model.dart';

abstract class ArState {}

class ArInitial extends ArState {}

class ArLoading extends ArState {}

class ArLoaded extends ArState {
  final ArModel model;
  ArLoaded(this.model);
}

class ArNoModel extends ArState {}

class ArError extends ArState {
  final String message;
  ArError(this.message);
}