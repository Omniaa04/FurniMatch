class RoomEntity {
  final String name;
  final double area;
  final List<double> sides;
  final String date;

  const RoomEntity({
    required this.name,
    required this.area,
    required this.sides,
    required this.date,
  });

  RoomEntity copyWith({
    String? name,
    double? area,
    List<double>? sides,
    String? date,
  }) {
    return RoomEntity(
      name: name ?? this.name,
      area: area ?? this.area,
      sides: sides ?? this.sides,
      date: date ?? this.date,
    );
  }
}
