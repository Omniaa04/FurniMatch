// import 'package:flutter/material.dart';
// import '../../domain/order_tracking_model.dart';

// class TrackingStepper extends StatelessWidget {
//   final List<TrackingStep> steps;

//   const TrackingStepper({super.key, required this.steps});

//   int get _completedSteps => steps.where((s) => s.isCompleted).length;

//   double get _progress {
//     if (steps.length <= 1) return 0;
//     final int total = steps.length - 1;
//     final int completed = _completedSteps - 1;
//     return completed < 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
//   }

//   @override
//   Widget build(BuildContext context) {
//     const double circleSize = 24.0;
//     const double lineH = 3.0;
//     const double labelWidth = 70.0;

//     return LayoutBuilder(builder: (context, constraints) {
//       final double totalWidth = constraints.maxWidth;
//       final int count = steps.length;

      
//       final List<double> centers = List.generate(count, (i) {
//         return (totalWidth / (count - 1)) * i;
//       });
//       centers[0] = circleSize / 2;
//       centers[count - 1] = totalWidth - circleSize / 2;

      
//       final double progressWidth =
//           _progress * (centers[count - 1] - centers[0]);

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
    
//           SizedBox(
//             height: circleSize,
//             child: Stack(
//               clipBehavior: Clip.none,
//               children: [
                
//                 Positioned(
//                   left: centers[0],
//                   right: totalWidth - centers[count - 1],
//                   top: circleSize / 2 - lineH / 2,
//                   child: Container(
//                     height: lineH,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),

//                 if (_completedSteps > 0)
//                   Positioned(
//                     left: centers[0],
//                     top: circleSize / 2 - lineH / 2,
//                     child: Container(
//                       width: progressWidth.clamp(0.0, centers[count - 1] - centers[0]),
//                       height: lineH,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFF7043),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),

//                 ...List.generate(count, (i) {
//                   final bool isCompleted = steps[i].isCompleted;
//                   final bool isActive = i == _completedSteps;
//                   return Positioned(
//                     left: centers[i] - circleSize / 2,
//                     top: 0,
//                     child: _buildCircle(
//                       size: circleSize,
//                       isCompleted: isCompleted,
//                       isActive: isActive,
//                     ),
//                   );
//                 }),
//               ],
//             ),
//           ),

//           const SizedBox(height: 10),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: List.generate(count, (i) {
//               final TrackingStep step = steps[i];
//               final bool isCompleted = step.isCompleted;
//               final bool isActive = i == _completedSteps;

//               CrossAxisAlignment crossAlign = CrossAxisAlignment.center;
//               if (i == 0) crossAlign = CrossAxisAlignment.start;
//               if (i == count - 1) crossAlign = CrossAxisAlignment.end;

//               return SizedBox(
//                 width: labelWidth,
//                 child: Column(
//                   crossAxisAlignment: crossAlign,
//                   children: [
//                     Text(
//                       step.title,
//                       textAlign: i == 0
//                           ? TextAlign.left
//                           : i == count - 1
//                               ? TextAlign.right
//                               : TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 10.5,
//                         fontWeight: isCompleted || isActive
//                             ? FontWeight.bold
//                             : FontWeight.normal,
//                         color: isCompleted || isActive
//                             ? Colors.black87
//                             : Colors.grey.shade400,
//                         height: 1.3,
//                       ),
//                     ),
//                     const SizedBox(height: 3),
//                     Text(
//                       step.date,
//                       textAlign: i == 0
//                           ? TextAlign.left
//                           : i == count - 1
//                               ? TextAlign.right
//                               : TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 9.5,
//                         color: isCompleted
//                             ? const Color(0xFFFF7043)
//                             : Colors.grey.shade400,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//           ),
//         ],
//       );
//     });
//   }

//   Widget _buildCircle({
//     required double size,
//     required bool isCompleted,
//     required bool isActive,
//   }) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: isCompleted ? const Color(0xFFFF7043) : Colors.white,
//         border: Border.all(
//           color: isCompleted || isActive
//               ? const Color(0xFFFF7043)
//               : Colors.grey.shade300,
//           width: 2.5,
//         ),
//         boxShadow: isCompleted || isActive
//             ? [
//                 BoxShadow(
//                   color: const Color(0xFFFF7043).withOpacity(0.3),
//                   blurRadius: 6,
//                   spreadRadius: 1,
//                 )
//               ]
//             : null,
//       ),
//       child: isCompleted
//           ? const Icon(Icons.check, size: 13, color: Colors.white)
//           : null,
//     );
//   }

// }

import 'package:flutter/material.dart';
import '../../domain/order_tracking_model.dart';

class TrackingStepper extends StatelessWidget {
  final List<TrackingStep> steps;

  const TrackingStepper({super.key, required this.steps});

  static const Color darkBrown = Color(0xFF7D533D);
  static const Color accent = Color(0xFFEBA46E);

  int get _completedSteps => steps.where((s) => s.isCompleted).length;

  double get _progress {
    if (steps.length <= 1) return 0;
    final int total = steps.length - 1;
    final int completed = _completedSteps - 1;
    return completed < 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    const double circleSize = 24.0;
    const double lineH = 3.0;
    const double labelWidth = 72.0;

    if (steps.isEmpty) {
      return const SizedBox();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final int count = steps.length;

        if (count == 1) {
          return Text(
            steps.first.title,
            style: const TextStyle(
              color: darkBrown,
              fontWeight: FontWeight.bold,
            ),
          );
        }

        final List<double> centers = List.generate(count, (i) {
          return (totalWidth / (count - 1)) * i;
        });

        centers[0] = circleSize / 2;
        centers[count - 1] = totalWidth - circleSize / 2;

        final double progressWidth =
            _progress * (centers[count - 1] - centers[0]);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: circleSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: centers[0],
                    right: totalWidth - centers[count - 1],
                    top: circleSize / 2 - lineH / 2,
                    child: Container(
                      height: lineH,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  if (_completedSteps > 0)
                    Positioned(
                      left: centers[0],
                      top: circleSize / 2 - lineH / 2,
                      child: Container(
                        width: progressWidth.clamp(
                          0.0,
                          centers[count - 1] - centers[0],
                        ),
                        height: lineH,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ...List.generate(count, (i) {
                    final bool isCompleted = steps[i].isCompleted;
                    final bool isActive = i == _completedSteps;

                    return Positioned(
                      left: centers[i] - circleSize / 2,
                      top: 0,
                      child: _buildCircle(
                        size: circleSize,
                        isCompleted: isCompleted,
                        isActive: isActive,
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(count, (i) {
                final TrackingStep step = steps[i];
                final bool isCompleted = step.isCompleted;
                final bool isActive = i == _completedSteps;

                CrossAxisAlignment crossAlign = CrossAxisAlignment.center;
                if (i == 0) crossAlign = CrossAxisAlignment.start;
                if (i == count - 1) crossAlign = CrossAxisAlignment.end;

                return SizedBox(
                  width: labelWidth,
                  child: Column(
                    crossAxisAlignment: crossAlign,
                    children: [
                      Text(
                        step.title,
                        textAlign: i == 0
                            ? TextAlign.left
                            : i == count - 1
                                ? TextAlign.right
                                : TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isCompleted || isActive
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isCompleted || isActive
                              ? darkBrown
                              : Colors.grey.shade400,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        step.date,
                        textAlign: i == 0
                            ? TextAlign.left
                            : i == count - 1
                                ? TextAlign.right
                                : TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isCompleted ? FontWeight.w600 : FontWeight.w400,
                          color: isCompleted ? accent : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCircle({
    required double size,
    required bool isCompleted,
    required bool isActive,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? accent : Colors.white,
        border: Border.all(
          color: isCompleted || isActive ? accent : Colors.grey.shade300,
          width: 2.5,
        ),
        boxShadow: isCompleted || isActive
            ? [
                BoxShadow(
                  color: accent.withOpacity(0.35),
                  blurRadius: 7,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: isCompleted
          ? const Icon(Icons.check, size: 13, color: Colors.white)
          : null,
    );
  }
}