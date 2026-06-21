import 'dart:ui';

class ReferenceObjectEntity {
  final String name;
  final double widthMm;
  final double heightMm;
  final bool isCustom;

  const ReferenceObjectEntity({
    required this.name,
    required this.widthMm,
    required this.heightMm,
    this.isCustom = false,
  });

  double get widthM => widthMm / 1000;
  double get heightM => heightMm / 1000;

  static const a4Paper = ReferenceObjectEntity(
    name: 'A4 Paper',
    widthMm: 297,
    heightMm: 210,
  );
  static const creditCard = ReferenceObjectEntity(
    name: 'National ID / Credit Card',
    widthMm: 85.6,
    heightMm: 53.98,
  );
  static const usDollarBill = ReferenceObjectEntity(
    name: 'US Dollar Bill',
    widthMm: 156.1,
    heightMm: 66.3,
  );
  static const standardDoor = ReferenceObjectEntity(
    name: 'Standard Door Frame',
    widthMm: 900,
    heightMm: 2100,
  );

  static const presets = [a4Paper, creditCard, usDollarBill, standardDoor];
}

class MeasurementResultEntity {
  final String imagePath;
  final Size imageSize;
  final List<Offset> refPoints;
  final List<Offset> wallPoints;
  final double? widthM;
  final double? heightM;

  const MeasurementResultEntity({
    required this.imagePath,
    required this.imageSize,
    required this.refPoints,
    required this.wallPoints,
    required this.widthM,
    required this.heightM,
  });
}

enum PointGroup { reference, wall }

sealed class MarkingAction {}

class AddPointAction extends MarkingAction {
  final PointGroup group;
  final Offset point;
  AddPointAction({required this.group, required this.point});
}

class MovePointAction extends MarkingAction {
  final PointGroup group;
  final int index;
  final Offset oldPosition;
  final Offset newPosition;
  MovePointAction({
    required this.group,
    required this.index,
    required this.oldPosition,
    required this.newPosition,
  });
}

class RemovePointAction extends MarkingAction {
  final PointGroup group;
  final int index;
  final Offset point;
  RemovePointAction({
    required this.group,
    required this.index,
    required this.point,
  });
}
