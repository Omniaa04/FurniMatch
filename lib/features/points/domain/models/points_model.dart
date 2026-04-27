class PointsTransaction {
  final String id;
  final int points;
  final String description;
  final DateTime date;
  final bool isEarned;

  const PointsTransaction({
    required this.id,
    required this.points,
    required this.description,
    required this.date,
    required this.isEarned,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'points': points,
        'description': description,
        'date': date.toIso8601String(),
        'isEarned': isEarned,
      };

  factory PointsTransaction.fromJson(Map<String, dynamic> json) =>
      PointsTransaction(
        id: json['id'],
        points: json['points'],
        description: json['description'],
        date: DateTime.parse(json['date']),
        isEarned: json['isEarned'],
      );
}

class PointsModel {
  final int totalPoints;
  final List<PointsTransaction> transactions;

  static const int egpPerPoint = 10;
  static const int pointsPerDiscount = 100;
  static const int discountValue = 10;

  const PointsModel({
    this.totalPoints = 0,
    this.transactions = const [],
  });

  bool get canRedeem => totalPoints >= pointsPerDiscount;

  // النقاط المتبقية بعد صرفة واحدة
  int get pointsAfterRedeem => totalPoints - pointsPerDiscount;

  // progress للـ bar
  double get progressToNext =>
      (totalPoints % pointsPerDiscount) / pointsPerDiscount;

  int get pointsToNext =>
      pointsPerDiscount - (totalPoints % pointsPerDiscount);

  static int calculatePoints(double amount) => (amount / egpPerPoint).floor();

  PointsModel copyWith({
    int? totalPoints,
    List<PointsTransaction>? transactions,
  }) =>
      PointsModel(
        totalPoints: totalPoints ?? this.totalPoints,
        transactions: transactions ?? this.transactions,
      );

  // حذف transaction وتعديل الرصيد
  PointsModel deleteTransaction(String transactionId) {
    final tx = transactions.firstWhere((t) => t.id == transactionId);
    final pointsDelta = tx.isEarned ? -tx.points : tx.points;
    final newTotal = (totalPoints + pointsDelta).clamp(0, 999999);
    return PointsModel(
      totalPoints: newTotal,
      transactions: transactions.where((t) => t.id != transactionId).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'totalPoints': totalPoints,
        'transactions': transactions.map((t) => t.toJson()).toList(),
      };

  factory PointsModel.fromJson(Map<String, dynamic> json) => PointsModel(
        totalPoints: json['totalPoints'] ?? 0,
        transactions: (json['transactions'] as List? ?? [])
            .map((t) => PointsTransaction.fromJson(t))
            .toList(),
      );
}