class RoomModel {
  final double width;
  final double length;
  final double height;

  RoomModel({
    required this.width,
    required this.length,
    this.height = 2.8,
  });

  // بنحوله لـ JSON عشان نبعته لـ Unity
  Map<String, dynamic> toJson() => {
    'width': width,
    'length': length,
    'height': height,
  };
}