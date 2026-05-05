import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_colors.dart';

extension on Paint {
  set strokeDash(List<double> _) {} // no-op: Dart canvas has no native dash
}

/// Phase 1 tutorial: animates a hand tapping the 4 corners of a rectangle.
class RefTutorialAnimation extends StatelessWidget {
  final AnimationController animCtrl;
  final AnimationController dotCtrl;

  const RefTutorialAnimation({
    super.key,
    required this.animCtrl,
    required this.dotCtrl,
  });

  @override
  Widget build(BuildContext context) {
    const corners = [
      Offset(0.1, 0.1), // TL
      Offset(0.9, 0.1), // TR
      Offset(0.9, 0.9), // BR
      Offset(0.1, 0.9), // BL
    ];
    const labels = ['TL', 'TR', 'BR', 'BL'];
    const w = 220.0;
    const h = 160.0;

    return AnimatedBuilder(
      animation: Listenable.merge([animCtrl, dotCtrl]),
      builder: (_, __) {
        const segCount = 4;
        final t = animCtrl.value * segCount;
        final seg = t.floor().clamp(0, segCount - 1);
        final segT = t - seg;

        // Split the segment timeline: 70% moving, 30% tapping
        double moveT = (segT / 0.7).clamp(0.0, 1.0);
        double tapT = ((segT - 0.7) / 0.3).clamp(0.0, 1.0);

        // 1. Smooth, non-linear easing for movement
        moveT = Curves.easeInOut.transform(moveT);

        // Shift targeting so the hand ends the segment ON the corner it needs to tap.
        final from = corners[(seg + 3) % 4];
        final to = corners[seg];

        // 2. Reduced arc (sine wave) for a flatter, subtler sweep
        final linearPos = Offset.lerp(from, to, moveT)!;
        final dir = to - from;
        final perp = Offset(-dir.dy, dir.dx);
        final arcHeight = math.sin(moveT * math.pi) * 0.05;
        final dotPos = linearPos + (perp * arcHeight);

        // 3. Tap Animation
        double tapScale = 1.0;
        if (tapT > 0) {
          final tapPhase = math.sin(tapT * math.pi);
          tapScale = 1.0 - (0.2 * tapPhase);
        }

        // 4. Visit Registration
        final int visitedCount = seg + (tapT > 0.5 ? 1 : 0);

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: RefTutorialPainter(
                    corners: corners,
                    labels: labels,
                    visitedCount: visitedCount,
                    targetCorner: to,
                    tapPhase: tapT,
                  ),
                ),
              ),
              Positioned(
                left: dotPos.dx * w - 10,
                top: dotPos.dy * h - 4,
                child: Transform.scale(
                  scale: tapScale,
                  alignment: Alignment.topLeft,
                  child: const Icon(
                    Icons.pan_tool_alt_rounded,
                    color: Colors.white,
                    size: 34,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RefTutorialPainter extends CustomPainter {
  final List<Offset> corners;
  final List<String> labels;
  final int visitedCount;
  final Offset targetCorner;
  final double tapPhase;

  RefTutorialPainter({
    required this.corners,
    required this.labels,
    required this.visitedCount,
    required this.targetCorner,
    required this.tapPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Offset s(Offset n) => Offset(n.dx * w, n.dy * h);

    final rectPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeDash = [6, 4];

    final path = Path()
      ..moveTo(s(corners[0]).dx, s(corners[0]).dy)
      ..lineTo(s(corners[1]).dx, s(corners[1]).dy)
      ..lineTo(s(corners[2]).dx, s(corners[2]).dy)
      ..lineTo(s(corners[3]).dx, s(corners[3]).dy)
      ..close();
    canvas.drawPath(path, rectPaint);

    for (int i = 0; i < visitedCount; i++) {
      final p = s(corners[i]);
      canvas.drawCircle(p, 7,
          Paint()..color = AppColors.primary.withValues(alpha: 0.85));
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
              color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }

    if (tapPhase > 0) {
      final p = s(targetCorner);
      final rippleRadius = 8.0 + (18.0 * tapPhase);
      final rippleOpacity = 1.0 - tapPhase;
      canvas.drawCircle(
          p,
          rippleRadius,
          Paint()
            ..color = AppColors.primary.withValues(alpha: rippleOpacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5);
    }
  }

  @override
  bool shouldRepaint(RefTutorialPainter old) => true;
}

/// Phase 2 tutorial: cycles through showing 3→4 point configurations.
class WallTutorialAnimation extends StatelessWidget {
  final AnimationController animCtrl;
  final AnimationController dotCtrl;

  const WallTutorialAnimation({
    super.key,
    required this.animCtrl,
    required this.dotCtrl,
  });

  @override
  Widget build(BuildContext context) {
    const configs = [
      // 2-point: horizontal line
      [Offset(0.15, 0.55), Offset(0.85, 0.55)],
      // 3-point: L-shape corner
      [Offset(0.15, 0.8), Offset(0.85, 0.8), Offset(0.15, 0.2)],
      // 4-point: quad
      [
        Offset(0.15, 0.2),
        Offset(0.85, 0.25),
        Offset(0.80, 0.85),
        Offset(0.20, 0.80),
      ],
    ];
    const configLabels = ['Distance', 'Width + Height', 'Full Quad'];

    return AnimatedBuilder(
      animation: Listenable.merge([animCtrl, dotCtrl]),
      builder: (_, __) {
        const segCount = 3;
        final t = animCtrl.value * segCount;
        final configIdx = t.floor().clamp(0, segCount - 1);
        final configT = t - configIdx;

        final pts = configs[configIdx];
        final visibleCount =
            (configT * (pts.length + 1)).floor().clamp(0, pts.length);

        final pulse = 1.0 + 0.3 * dotCtrl.value;

        return SizedBox(
          width: 220,
          height: 200,
          child: CustomPaint(
            painter: WallTutorialPainter(
              points: pts,
              visibleCount: visibleCount,
              label: configLabels[configIdx],
              dotPulse: pulse,
            ),
          ),
        );
      },
    );
  }
}

class WallTutorialPainter extends CustomPainter {
  final List<Offset> points;
  final int visibleCount;
  final String label;
  final double dotPulse;

  WallTutorialPainter({
    required this.points,
    required this.visibleCount,
    required this.label,
    required this.dotPulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Offset s(Offset n) => Offset(n.dx * w, n.dy * h);

    final pts = points.map(s).toList();
    final visible = pts.sublist(0, visibleCount.clamp(0, pts.length));

    if (visible.length >= 2) {
      final linePaint = Paint()
        ..color = AppColors.secondary.withValues(alpha: 0.7)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < visible.length - 1; i++) {
        canvas.drawLine(visible[i], visible[i + 1], linePaint);
      }
      if (visible.length == pts.length && pts.length == 4) {
        canvas.drawLine(visible.last, visible.first, linePaint);
      }
    }

    for (int i = 0; i < visible.length; i++) {
      final isLast = i == visible.length - 1;
      final r = isLast ? 8.0 * dotPulse : 7.0;
      if (isLast) {
        canvas.drawCircle(visible[i], r + 4,
            Paint()..color = AppColors.secondary.withValues(alpha: 0.25));
      }
      canvas.drawCircle(visible[i], r, Paint()..color = AppColors.secondary);
      canvas.drawCircle(
          visible[i],
          r + 2,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);

      final tp = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
              color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, visible[i] - Offset(tp.width / 2, tp.height / 2));
    }

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: AppColors.secondary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((w - tp.width) / 2, h - tp.height - 2));
  }

  @override
  bool shouldRepaint(WallTutorialPainter old) => true;
}
