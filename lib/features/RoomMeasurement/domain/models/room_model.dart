import 'dart:convert';
import 'dart:ui';

// ─────────────────────────────────────────────
//  RoomModel – Domain Entity
// ─────────────────────────────────────────────
class RoomModel {
  const RoomModel({
    required this.name,
    required this.widthM,
    required this.heightM,
    required this.area,
    required this.date,
  });

  final String name;
  final double widthM;
  final double heightM;
  final double area;
  final String date;

  RoomModel copyWith({String? name, double? widthM, double? heightM,
      double? area, String? date}) {
    return RoomModel(
      name: name ?? this.name,
      widthM: widthM ?? this.widthM,
      heightM: heightM ?? this.heightM,
      area: area ?? this.area,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'widthM': widthM,
        'heightM': heightM,
        'area': area,
        'date': date,
      };

  factory RoomModel.fromMap(Map<String, dynamic> map) => RoomModel(
        name: map['name'] as String,
        widthM: (map['widthM'] as num).toDouble(),
        heightM: (map['heightM'] as num).toDouble(),
        area: (map['area'] as num).toDouble(),
        date: map['date'] as String,
      );

  String toJson() => jsonEncode(toMap());
  factory RoomModel.fromJson(String source) =>
      RoomModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

// ─────────────────────────────────────────────
//  ArMeasurementResult
//  النتيجة الجاية من ARCore مباشرة
// ─────────────────────────────────────────────
class ArMeasurementResult {
  const ArMeasurementResult({
    required this.points,
    required this.widthM,
    required this.heightM,
  });

  /// النقط على الشاشة (screen coords)
  final List<Offset> points;

  /// العرض بالمتر — محسوب من ARCore depth
  final double widthM;

  /// الارتفاع بالمتر — محسوب من ARCore depth
  final double heightM;

  double get area => widthM * heightM;
}