import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';

import '../core/app_colors.dart';
import 'models.dart';
import 'history_screen.dart';
import 'room_storage.dart';
import 'room_model.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class MeasurementResultScreen extends StatefulWidget {
  final MeasurementResult result;
  const MeasurementResultScreen({super.key, required this.result});

  @override
  State<MeasurementResultScreen> createState() =>
      _MeasurementResultScreenState();
}

class _MeasurementResultScreenState extends State<MeasurementResultScreen>
    with SingleTickerProviderStateMixin {
  final _repaintKey = GlobalKey();

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  bool _saving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> _saveImageAndRoom() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      // 1) Capture the annotated photo
      final boundary = _repaintKey.currentContext!.findRenderObject()
      as RenderRepaintBoundary;
      final img = await boundary.toImage(pixelRatio: 2.5);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw Exception('Failed to encode image');

      final bytes = data.buffer.asUint8List();
      await Gal.putImageBytes(bytes);

      // 2) Ask for room name
      if (!mounted) return;
      final String? name = await showRoomNameDialog(context);

      // User pressed Cancel or left name empty → abort silently
      if (name == null || name.trim().isEmpty) {
        if (mounted) setState(() => _saving = false);
        return;
      }

      // 3) Persist room
      final r = widget.result;
      final room = RoomModel(
        name: name.trim(),
        area: (r.widthM ?? 0) * (r.heightM ?? 0),
        sides: [r.widthM ?? 0, r.heightM ?? 0],
        date: DateTime.now().toIso8601String(),
      );
      await RoomStorage.saveRoom(room);

      // 4) Navigate to history
      if (mounted) {
        setState(() {
          _saving = false;
          _saved = true;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HistoryScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Room-name dialog ───────────────────────────────────────────────────────

  Future<String?> showRoomNameDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter room name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Room name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final mq = MediaQuery.of(context);

    const panelHeight = 220.0;
    final imageAreaHeight = mq.size.height - panelHeight - mq.padding.top;
    final imageAreaSize = Size(mq.size.width, imageAreaHeight);

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // ── Annotated photo (captured for save) ────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: imageAreaHeight + mq.padding.top,
              child: RepaintBoundary(
                key: _repaintKey,
                child: _AnnotatedPhoto(
                  result: r,
                  areaSize: imageAreaSize,
                  topPadding: mq.padding.top,
                ),
              ),
            ),

            // ── Top bar (outside RepaintBoundary) ──────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      _glassBtn(
                        Icons.arrow_back_rounded,
                            () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      _glassBtn(
                        Icons.history_rounded,
                            () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HistoryScreen()),
                        ),
                        label: 'History',
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom info panel ───────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _BottomPanel(
                result: r,
                onSave: _saveImageAndRoom,
                saving: _saving,
                saved: _saved,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassBtn(
      IconData icon,
      VoidCallback onTap, {
        String? label,
        bool active = true,
      }) {
    return GestureDetector(
      onTap: active ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          border:
          Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Annotated Photo ───────────────────────────────────────────────────────────

class _AnnotatedPhoto extends StatelessWidget {
  final MeasurementResult result;
  final Size areaSize;
  final double topPadding;

  const _AnnotatedPhoto({
    required this.result,
    required this.areaSize,
    required this.topPadding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Container(color: Colors.black),
          Center(
            child: Image.file(
              File(result.imagePath),
              fit: BoxFit.contain,
            ),
          ),
          Positioned.fill(
            child: LayoutBuilder(builder: (context, constraints) {
              final displayRect = _fitRect(
                Size(constraints.maxWidth, constraints.maxHeight),
                result.imageSize,
              );
              return CustomPaint(
                painter: _AnnotationPainter(
                  wallPoints: result.wallPoints,
                  imageSize: result.imageSize,
                  displayRect: displayRect,
                  widthM: result.widthM,
                  heightM: result.heightM,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  static Rect _fitRect(Size viewport, Size image) {
    final scaleX = viewport.width / image.width;
    final scaleY = viewport.height / image.height;
    final scale = math.min(scaleX, scaleY);
    final w = image.width * scale;
    final h = image.height * scale;
    return Rect.fromLTWH(
      (viewport.width - w) / 2,
      (viewport.height - h) / 2,
      w,
      h,
    );
  }
}

// ── Annotation Painter ────────────────────────────────────────────────────────

class _AnnotationPainter extends CustomPainter {
  final List<Offset> wallPoints;
  final Size imageSize;
  final Rect displayRect;
  final double? widthM;
  final double? heightM;

  _AnnotationPainter({
    required this.wallPoints,
    required this.imageSize,
    required this.displayRect,
    required this.widthM,
    required this.heightM,
  });

  Offset _i2s(Offset p) {
    if (imageSize.width == 0 || imageSize.height == 0) return Offset.zero;
    return Offset(
      displayRect.left + (p.dx / imageSize.width) * displayRect.width,
      displayRect.top + (p.dy / imageSize.height) * displayRect.height,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (wallPoints.isEmpty) return;

    final pts = wallPoints.map(_i2s).toList();
    final n = pts.length;

    // ── 2 points ────────────────────────────────────────────────
    if (n == 2) {
      final a = pts[0];
      final b = pts[1];
      final label = widthM != null
          ? '${widthM!.toStringAsFixed(2)} m'
          : '${heightM!.toStringAsFixed(2)} m';
      final color = widthM != null
          ? const Color(0xFF00E5FF)
          : AppColors.secondary;
      _drawLine(canvas, a, b, label, color);
      for (final pt in pts) {
        _drawAnchorNode(canvas, pt);
      }
      return;
    }

    // ── 3 points ────────────────────────────────────────────────
    if (n == 3) {
      int cornerIdx = 0;
      double smallest = double.infinity;
      for (int i = 0; i < 3; i++) {
        final a = wallPoints[(i + 1) % 3];
        final b = wallPoints[i];
        final c = wallPoints[(i + 2) % 3];
        final v1 = a - b;
        final v2 = c - b;
        final cosA = (v1.dx * v2.dx + v1.dy * v2.dy) /
            (v1.distance * v2.distance + 1e-15);
        final angle = math.acos(cosA.clamp(-1.0, 1.0)).abs();
        final diff = (angle - math.pi / 2).abs();
        if (diff < smallest) {
          smallest = diff;
          cornerIdx = i;
        }
      }

      final corner = pts[cornerIdx];
      final arm1 = pts[(cornerIdx + 1) % 3];
      final arm2 = pts[(cornerIdx + 2) % 3];

      final dxArm1 =
      (wallPoints[(cornerIdx + 1) % 3].dx - wallPoints[cornerIdx].dx)
          .abs();
      final dyArm1 =
      (wallPoints[(cornerIdx + 1) % 3].dy - wallPoints[cornerIdx].dy)
          .abs();

      final Offset wArm, hArm;
      if (dxArm1 >= dyArm1) {
        wArm = arm1;
        hArm = arm2;
      } else {
        wArm = arm2;
        hArm = arm1;
      }

      _drawLine(canvas, corner, wArm, '${widthM!.toStringAsFixed(2)} m',
          const Color(0xFF00E5FF));
      _drawLine(canvas, corner, hArm, '${heightM!.toStringAsFixed(2)} m',
          AppColors.secondary);

      for (final pt in pts) {
        _drawAnchorNode(canvas, pt);
      }
      return;
    }

    // ── 4 points ────────────────────────────────────────────────
    final sorted = _sortClockwiseScreen(pts);
    final tl = sorted[0];
    final tr = sorted[1];
    final br = sorted[2];
    final bl = sorted[3];

    final outlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(tl.dx, tl.dy)
        ..lineTo(tr.dx, tr.dy)
        ..lineTo(br.dx, br.dy)
        ..lineTo(bl.dx, bl.dy)
        ..close(),
      outlinePaint,
    );

    _drawLine(canvas, tl, tr, '${widthM!.toStringAsFixed(2)} m',
        const Color(0xFF00E5FF));
    _drawLine(canvas, tl, bl, '${heightM!.toStringAsFixed(2)} m',
        AppColors.secondary);

    for (final pt in sorted) {
      _drawAnchorNode(canvas, pt);
    }
  }

  List<Offset> _sortClockwiseScreen(List<Offset> pts) {
    final cx = pts.map((p) => p.dx).reduce((a, b) => a + b) / pts.length;
    final cy = pts.map((p) => p.dy).reduce((a, b) => a + b) / pts.length;
    final sorted = List<Offset>.from(pts)
      ..sort((a, b) {
        final angleA = math.atan2(a.dy - cy, a.dx - cx);
        final angleB = math.atan2(b.dy - cy, b.dx - cx);
        return angleA.compareTo(angleB);
      });
    int startIdx = 0;
    double minSum = double.infinity;
    for (int i = 0; i < sorted.length; i++) {
      final s = sorted[i].dx + sorted[i].dy;
      if (s < minSum) {
        minSum = s;
        startIdx = i;
      }
    }
    return [
      ...sorted.sublist(startIdx),
      ...sorted.sublist(0, startIdx),
    ];
  }

  void _drawAnchorNode(Canvas canvas, Offset pt) {
    canvas.drawCircle(
      pt,
      12,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(
        pt, 6, Paint()..color = Colors.black.withValues(alpha: 0.6));
    canvas.drawCircle(pt, 3, Paint()..color = Colors.white);
    canvas.drawCircle(
      pt,
      8,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  void _drawLine(
      Canvas canvas, Offset a, Offset b, String label, Color color) {
    final dir = b - a;
    final len = dir.distance;
    if (len < 2) return;

    canvas.drawLine(
        a,
        b,
        Paint()
          ..color = color.withValues(alpha: 0.25)
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    canvas.drawLine(
        a,
        b,
        Paint()
          ..color = color.withValues(alpha: 0.6)
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));

    canvas.drawLine(
        a,
        b,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.9)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round);

    _drawChevron(canvas, a, b, color);
    _drawChevron(canvas, b, a, color);
    _label(canvas, Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2), label, color);
  }

  void _drawChevron(Canvas canvas, Offset tip, Offset other, Color color) {
    final dir = tip - other;
    final len = dir.distance;
    if (len < 1) return;
    final norm = dir / len;
    const arrowLen = 14.0;
    const arrowWidth = 7.0;
    final perp = Offset(-norm.dy, norm.dx);
    final base = tip - (norm * arrowLen);
    final p1 = base + (perp * arrowWidth);
    final p2 = base - (perp * arrowWidth);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(base.dx + (norm.dx * 4), base.dy + (norm.dy * 4))
      ..lineTo(p2.dx, p2.dy)
      ..close();
    canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawPath(path, Paint()..color = color);
  }

  void _label(Canvas canvas, Offset center, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    const padH = 12.0;
    const padV = 6.0;
    final rw = tp.width + padH * 2;
    final rh = tp.height + padV * 2;

    final cx = center.dx.clamp(
        displayRect.left + rw / 2 + 4, displayRect.right - rw / 2 - 4);
    final cy = center.dy.clamp(
        displayRect.top + rh / 2 + 4, displayRect.bottom - rh / 2 - 4);
    final c = Offset(cx, cy);

    final rr = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: rw, height: rh),
      const Radius.circular(12),
    );

    canvas.drawRRect(
        rr.shift(const Offset(0, 4)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    canvas.drawRRect(
        rr,
        Paint()
          ..color = const Color(0xFF121212).withValues(alpha: 0.85));
    canvas.drawRRect(
        rr,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
    canvas.drawRRect(
        rr,
        Paint()
          ..color = color.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);

    tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_AnnotationPainter old) =>
      old.wallPoints != wallPoints ||
          old.displayRect != displayRect ||
          old.widthM != widthM ||
          old.heightM != heightM;
}

// ── Bottom Panel ──────────────────────────────────────────────────────────────

class _BottomPanel extends StatelessWidget {
  final MeasurementResult result;
  final VoidCallback onSave;
  final bool saving;
  final bool saved;

  const _BottomPanel({
    required this.result,
    required this.onSave,
    required this.saving,
    required this.saved,
  });

  @override
  Widget build(BuildContext context) {
    final hasWidth = result.widthM != null;
    final hasHeight = result.heightM != null;
    final hasBoth = hasWidth && hasHeight;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Dimensions row ──────────────────────────────────
              hasBoth
                  ? Row(
                children: [
                  Expanded(
                    child: _DimCard(
                      label: 'Width',
                      valueCm: result.widthM! * 100,
                      color: const Color(0xFF443521),
                      icon: Icons.swap_horiz_rounded,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: Colors.white.withValues(alpha: 0.1),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  Expanded(
                    child: _DimCard(
                      label: 'Height',
                      valueCm: result.heightM! * 100,
                      color: AppColors.secondary,
                      icon: Icons.swap_vert_rounded,
                    ),
                  ),
                ],
              )
                  : Center(
                child: _DimCard(
                  label: hasWidth ? 'Width' : 'Height',
                  valueCm: (result.widthM ?? result.heightM)! * 100,
                  color: hasWidth
                      ? const Color(0xFF443521)
                      : AppColors.secondary,
                  icon: hasWidth
                      ? Icons.swap_horiz_rounded
                      : Icons.swap_vert_rounded,
                ),
              ),

              const SizedBox(height: 18),

              // ── SAVE button ─────────────────────────────────────
              GestureDetector(
                onTap: (!saving && !saved) ? onSave : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: saved
                        ? const LinearGradient(
                      colors: [Color(0xFF443521), Color(0xFFFFD5AF)],
                    )
                        : saving
                        ? LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.04),
                      ],
                    )
                        : const LinearGradient(
                      colors: [
                        Color(0xFF443521),
                        Color(0xFF443521),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: saved || saving
                        ? []
                        : [
                      BoxShadow(
                        color:
                        const Color(0xFF443521).withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        saved
                            ? Icons.check_rounded
                            : saving
                            ? Icons.hourglass_empty_rounded
                            : Icons.save_alt_rounded,
                        color: saving
                            ? Colors.white.withValues(alpha: 0.4)
                            : Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        saved
                            ? 'Saved!'
                            : saving
                            ? 'Saving…'
                            : 'Save',
                        style: TextStyle(
                          color: saving
                              ? Colors.white.withValues(alpha: 0.4)
                              : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dim Card ──────────────────────────────────────────────────────────────────

class _DimCard extends StatelessWidget {
  final String label;
  final double valueCm;
  final Color color;
  final IconData icon;

  const _DimCard({
    required this.label,
    required this.valueCm,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final meters = valueCm / 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ]),
        const SizedBox(height: 6),
        Text(
          '${meters.toStringAsFixed(2)} m',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${valueCm.toStringAsFixed(1)} cm',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}