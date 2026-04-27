import 'package:flutter/material.dart';
import '../../domain/models/room_dimensions.dart';

class AROverlayWidget extends StatefulWidget {
  final RoomDimensions? dimensions;
  final bool isScanning;

  const AROverlayWidget({
    super.key,
    this.dimensions,
    this.isScanning = false,
  });

  @override
  State<AROverlayWidget> createState() => _AROverlayWidgetState();
}

class _AROverlayWidgetState extends State<AROverlayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;
  late final Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.isScanning)
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (_, __) => CustomPaint(
              painter: _ScanLinePainter(_scanAnimation.value),
              child: const SizedBox.expand(),
            ),
          ),
        CustomPaint(
          painter: _CornerBracketsPainter(
              color: widget.isScanning
                  ? const Color(0xFFCF8D5B)
                  : const Color(0xFFF0B589)),
          child: const SizedBox.expand(),
        ),
        if (widget.isScanning)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.12,
            left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7D533D).withOpacity(0.75),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Color(0xFFF5D1A9)),
                    ),
                    SizedBox(width: 8),
                    Text('room analysis..',
                        style: TextStyle(
                            color: Color(0xFFF5D1A9), fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Scan Line Painter ────────────────────────────────────────────────────────
class _ScanLinePainter extends CustomPainter {
  final double progress;
  _ScanLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFFCF8D5B).withOpacity(0.7),
          Colors.transparent,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, y - 2, size.width, 4))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(_ScanLinePainter old) => old.progress != progress;
}

// ─── Corner Brackets Painter ──────────────────────────────────────────────────
class _CornerBracketsPainter extends CustomPainter {
  final Color color;
  _CornerBracketsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const len = 28.0;
    const margin = 28.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawPath(
        Path()
          ..moveTo(margin, margin + len)
          ..lineTo(margin, margin)
          ..lineTo(margin + len, margin),
        paint);
    // Top-right
    canvas.drawPath(
        Path()
          ..moveTo(size.width - margin - len, margin)
          ..lineTo(size.width - margin, margin)
          ..lineTo(size.width - margin, margin + len),
        paint);
    // Bottom-left
    canvas.drawPath(
        Path()
          ..moveTo(margin, size.height - margin - len)
          ..lineTo(margin, size.height - margin)
          ..lineTo(margin + len, size.height - margin),
        paint);
    // Bottom-right
    canvas.drawPath(
        Path()
          ..moveTo(size.width - margin - len, size.height - margin)
          ..lineTo(size.width - margin, size.height - margin)
          ..lineTo(size.width - margin, size.height - margin - len),
        paint);
  }

  @override
  bool shouldRepaint(_CornerBracketsPainter old) => old.color != color;
}