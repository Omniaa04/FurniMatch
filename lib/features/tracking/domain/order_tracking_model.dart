// class TrackingStep {
//   final String title;
//   final String date;
//   final bool isCompleted;

//   const TrackingStep({
//     required this.title,
//     required this.date,
//     required this.isCompleted,
//   });
// }

class TrackingStep {
  final String title;
  final String date;
  final bool isCompleted;

  const TrackingStep({
    required this.title,
    required this.date,
    required this.isCompleted,
  });

  factory TrackingStep.fromJson(Map<String, dynamic> json) {
    return TrackingStep(
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}