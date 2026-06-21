import 'dart:convert';
import '../../domain/entities/room_entity.dart';

class RoomModel {
  final String name;
  final double area;
  final List<double> sides;
  final String date;

  const RoomModel({
    required this.name,
    required this.area,
    required this.sides,
    required this.date,
  });

  factory RoomModel.fromEntity(RoomEntity entity) => RoomModel(
        name: entity.name,
        area: entity.area,
        sides: entity.sides,
        date: entity.date,
      );

  RoomEntity toEntity() => RoomEntity(
        name: name,
        area: area,
        sides: sides,
        date: date,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'area': area,
        'sides': sides,
        'date': date,
      };

  factory RoomModel.fromMap(Map<String, dynamic> map) => RoomModel(
        name: map['name'] ?? '',
        area: (map['area'] as num).toDouble(),
        sides: List<double>.from(map['sides'] ?? []),
        date: map['date'] ?? '',
      );

  String toJson() => jsonEncode(toMap());

  factory RoomModel.fromJson(String source) =>
      RoomModel.fromMap(jsonDecode(source));
}
