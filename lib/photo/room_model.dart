import 'dart:convert';

class RoomModel {
  final String name;
  final double area;
  final List<double> sides;
  final String date;

  RoomModel({
    required this.name,
    required this.area,
    required this.sides,
    required this.date,
  });

  // ================= TO MAP =================
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'area': area,
      'sides': sides,
      'date': date,
    };
  }

  // ================= FROM MAP =================
  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      name: map['name'] ?? '',
      area: (map['area'] as num).toDouble(),
      sides: List<double>.from(map['sides'] ?? []),
      date: map['date'] ?? '',
    );
  }

  // ================= TO JSON STRING =================
  String toJson() => jsonEncode(toMap());

  // ================= FROM JSON STRING =================
  factory RoomModel.fromJson(String source) =>
      RoomModel.fromMap(jsonDecode(source));
}