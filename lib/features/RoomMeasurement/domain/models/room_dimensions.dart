class RoomDimensions {
  final double length;
  final double width;
  final double height;
  final DateTime measuredAt;

  const RoomDimensions({
    required this.length,
    required this.width,
    required this.height,
    required this.measuredAt,
  });

  double get area => length * width;
  double get volume => length * width * height;

  RoomDimensions copyWith({
    double? length,
    double? width,
    double? height,
    DateTime? measuredAt,
  }) {
    return RoomDimensions(
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      measuredAt: measuredAt ?? this.measuredAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'length': length,
        'width': width,
        'height': height,
        'measuredAt': measuredAt.toIso8601String(),
      };

  factory RoomDimensions.fromJson(Map<String, dynamic> json) => RoomDimensions(
        length: (json['length'] as num).toDouble(),
        width: (json['width'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
        measuredAt: DateTime.parse(json['measuredAt'] as String),
      );

  @override
  String toString() =>
      'RoomDimensions(length: ${length.toStringAsFixed(2)}m, '
      'width: ${width.toStringAsFixed(2)}m, '
      'height: ${height.toStringAsFixed(2)}m)';
}