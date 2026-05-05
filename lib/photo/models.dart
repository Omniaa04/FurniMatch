import 'dart:ui';

// ── Reference Objects ─────────────────────────────────────────────────────────

class ReferenceObject {
  final String name;
  final double widthMm;
  final double heightMm;
  final bool isCustom;

  const ReferenceObject({
    required this.name,
    required this.widthMm,
    required this.heightMm,
    this.isCustom = false,
  });

  double get widthM => widthMm / 1000;
  double get heightM => heightMm / 1000;

  static const a4Paper = ReferenceObject(
    name: 'A4 Paper',
    widthMm: 297,
    heightMm: 210,
  );

  static const creditCard = ReferenceObject(
    name: 'National ID / Credit Card',
    widthMm: 85.6,
    heightMm: 53.98,
  );

  static const usDollarBill = ReferenceObject(
    name: 'US Dollar Bill',
    widthMm: 156.1,
    heightMm: 66.3,
  );

  static const standardDoor = ReferenceObject(
    name: 'Standard Door Frame',
    widthMm: 900,
    heightMm: 2100,
  );

  static const presets = [a4Paper, creditCard, usDollarBill, standardDoor];
}

// ── Measurement Result ────────────────────────────────────────────────────────

/// Carries everything needed by the result screen.
///
/// [widthM] is the measured horizontal/wider dimension, or the single
/// distance when only 2 points are placed and the segment is horizontal.
/// It is null when a 2-point segment is determined to be vertical.
///
/// [heightM] is the measured vertical/taller dimension. It is null when
/// only 2 points are placed and the segment is horizontal, or when only
/// a width could be determined.
class MeasurementResult {
  /// Path to the original photo.
  final String imagePath;

  /// Image natural pixel dimensions.
  final Size imageSize;

  /// 4 reference-object corners in image pixels: [TL, TR, BR, BL].
  final List<Offset> refPoints;

  /// 2–4 wall-edge points in image pixels (order-independent; raw placement order).
  final List<Offset> wallPoints;

  /// Measured width/horizontal dimension. Null when only a vertical
  /// distance was detected from a 2-point placement.
  final double? widthM;

  /// Measured height/vertical dimension. Null when only a horizontal
  /// distance was detected from a 2-point placement.
  final double? heightM;

  const MeasurementResult({
    required this.imagePath,
    required this.imageSize,
    required this.refPoints,
    required this.wallPoints,
    required this.widthM,
    required this.heightM,
  });
}

// ── Undo/Redo Action System ───────────────────────────────────────────────────

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