import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../domain/entities/measurement_entities.dart';
import '../../core/homography.dart';
import './measurement_result_screen.dart';
import '../animations/tutorial_animations.dart';
import '../theme/app_colors.dart';

enum MarkingPhase { reference, wall }

class PhotoMarkingScreen extends StatefulWidget {
  final String imagePath;
  final ReferenceObjectEntity reference;

  const PhotoMarkingScreen({
    super.key,
    required this.imagePath,
    required this.reference,
  });

  @override
  State<PhotoMarkingScreen> createState() => _PhotoMarkingScreenState();
}

class _PhotoMarkingScreenState extends State<PhotoMarkingScreen>
    with TickerProviderStateMixin {
  ui.Image? _uiImage;
  late File _file;
  Size _imageSize = Size.zero;
  final GlobalKey _stackKey = GlobalKey();

  final TransformationController _transformCtrl = TransformationController();

  MarkingPhase _phase = MarkingPhase.reference;
  final List<Offset> _refPoints = [];
  final List<Offset> _wallPoints = [];

  int? _dragIndex;
  Offset? _dragStartImagePos;
  Offset? _dragScreenPos;
  int? _selectedIndex;
  bool _isLocked = false;
  bool _isRefTooSmall = false;

  final List<MarkingAction> _undoStack = [];
  final List<MarkingAction> _redoStack = [];

  // Tutorial state
  bool _showTutorial = true;
  late AnimationController _tutorialAnimCtrl;
  late AnimationController _tutorialDotCtrl;

  List<Offset> get _activePoints =>
      _phase == MarkingPhase.reference ? _refPoints : _wallPoints;

  int get _maxPoints => _phase == MarkingPhase.reference ? 4 : 4;

  List<String> get _pointLabels => _phase == MarkingPhase.reference
      ? ['TL', 'TR', 'BR', 'BL']
      : ['1', '2', '3', '4'];

  @override
  void initState() {
    super.initState();
    _file = File(widget.imagePath);
    _loadImage();
    _transformCtrl.addListener(() {
      if (mounted) setState(() {});
    });

    _tutorialAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _tutorialDotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  Future<void> _loadImage() async {
    final bytes = await _file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _uiImage = frame.image;
        _imageSize = Size(
          frame.image.width.toDouble(),
          frame.image.height.toDouble(),
        );
      });
    }
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    _tutorialAnimCtrl.dispose();
    _tutorialDotCtrl.dispose();
    super.dispose();
  }

  // ── Geometry Mappings ─────────────────────────────────────────────────────

  Offset _imageToScreen(Offset p, Size viewport) {
    if (_imageSize == Size.zero || viewport == Size.zero) return p;
    // Calculate how the image was scaled to fit the screen
    final fitScale = math.min(
      viewport.width / _imageSize.width,
      viewport.height / _imageSize.height,
    );
    // Calculate the empty space (padding) added by the Center widget
    final dx = (viewport.width - _imageSize.width * fitScale) / 2;
    final dy = (viewport.height - _imageSize.height * fitScale) / 2;

    // Map raw image pixel -> fitted screen pixel
    final centeredPos = Offset(p.dx * fitScale + dx, p.dy * fitScale + dy);
    // Apply user zoom/pan
    return MatrixUtils.transformPoint(_transformCtrl.value, centeredPos);
  }

  Offset _screenToImage(Offset p, Size viewport) {
    if (_imageSize == Size.zero || viewport == Size.zero) return p;
    final fitScale = math.min(
      viewport.width / _imageSize.width,
      viewport.height / _imageSize.height,
    );
    final dx = (viewport.width - _imageSize.width * fitScale) / 2;
    final dy = (viewport.height - _imageSize.height * fitScale) / 2;

    // Remove user zoom/pan
    final inverted = Matrix4.inverted(_transformCtrl.value);
    final centeredPos = MatrixUtils.transformPoint(inverted, p);

    // Remove padding and base scale to get raw image pixel
    return Offset(
      (centeredPos.dx - dx) / fitScale,
      (centeredPos.dy - dy) / fitScale,
    );
  }

  // ── Points ────────────────────────────────────────────────────────────────

  void _addPoint(Offset imagePos) {
    if (_activePoints.length >= _maxPoints) return;
    final group = _phase == MarkingPhase.reference
        ? PointGroup.reference
        : PointGroup.wall;
    setState(() {
      _activePoints.add(imagePos);
      _undoStack.add(AddPointAction(group: group, point: imagePos));
      _redoStack.clear();
      _selectedIndex = _activePoints.length - 1;
    });
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    final action = _undoStack.removeLast();
    setState(() {
      _redoStack.add(action);
      _applyAction(action, undo: true);
      _selectedIndex = null;
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    final action = _redoStack.removeLast();
    setState(() {
      _undoStack.add(action);
      _applyAction(action, undo: false);
      _selectedIndex = null;
    });
  }

  void _applyAction(MarkingAction action, {required bool undo}) {
    final pts = switch (action) {
      AddPointAction(group: final g) =>
        g == PointGroup.reference ? _refPoints : _wallPoints,
      MovePointAction(group: final g) =>
        g == PointGroup.reference ? _refPoints : _wallPoints,
      RemovePointAction(group: final g) =>
        g == PointGroup.reference ? _refPoints : _wallPoints,
    };
    if (action is AddPointAction) {
      undo ? pts.removeLast() : pts.add(action.point);
    } else if (action is MovePointAction) {
      pts[action.index] = undo ? action.oldPosition : action.newPosition;
    } else if (action is RemovePointAction) {
      undo
          ? pts.insert(action.index, action.point)
          : pts.removeAt(action.index);
    }
  }

  void _nudge(double dx, double dy) {
    if (_selectedIndex == null || _selectedIndex! >= _activePoints.length) {
      return;
    }
    final old = _activePoints[_selectedIndex!];
    final next = Offset(old.dx + dx, old.dy + dy);
    final group = _phase == MarkingPhase.reference
        ? PointGroup.reference
        : PointGroup.wall;
    setState(() {
      _activePoints[_selectedIndex!] = next;
      _undoStack.add(MovePointAction(
          group: group,
          index: _selectedIndex!,
          oldPosition: old,
          newPosition: next));
      _redoStack.clear();
    });
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _advanceToWallPhase() {
    if (_refPoints.length < 4) return;

    // Accuracy Check: Calculate average side length in pixels
    final d1 = (_refPoints[0] - _refPoints[1]).distance;
    final d2 = (_refPoints[1] - _refPoints[2]).distance;
    final avgSide = (d1 + d2) / 2;

    setState(() {
      // Threshold: warn if reference is < 120px or < 4% of image height
      _isRefTooSmall = avgSide < 120 || (avgSide / _imageSize.height) < 0.04;
      _phase = MarkingPhase.wall;
      _selectedIndex = null;
      _showTutorial = true;
    });
  }

  void _backToRefPhase() {
    setState(() {
      _phase = MarkingPhase.reference;
      _isRefTooSmall = false;
      _selectedIndex = null;
    });
  }

  // ── Geometric Analyzer ───────────────────────────────────────────────────

  ({double? widthM, double? heightM}) _analyzeWallPoints(
      List<Offset> pts, List<double> h) {
    assert(pts.length >= 2 && pts.length <= 4);

    if (pts.length == 2) {
      final dist = measureDistance(h, pts[0], pts[1]);
      final dx = (pts[1].dx - pts[0].dx).abs();
      final dy = (pts[1].dy - pts[0].dy).abs();
      // More horizontal -> width; more vertical -> height
      if (dx >= dy) {
        return (widthM: dist, heightM: null);
      } else {
        return (widthM: null, heightM: dist);
      }
    }

    if (pts.length == 3) {
      int cornerIdx = 0;
      double smallestAngle = double.infinity;
      for (int i = 0; i < 3; i++) {
        final a = pts[(i + 1) % 3];
        final b = pts[i];
        final c = pts[(i + 2) % 3];
        final v1 = a - b;
        final v2 = c - b;
        final cosA = (v1.dx * v2.dx + v1.dy * v2.dy) /
            (v1.distance * v2.distance + 1e-15);
        final angle = math.acos(cosA.clamp(-1.0, 1.0)).abs();
        final diff = (angle - math.pi / 2).abs();
        if (diff < smallestAngle) {
          smallestAngle = diff;
          cornerIdx = i;
        }
      }
      final corner = pts[cornerIdx];
      final arm1 = pts[(cornerIdx + 1) % 3];
      final arm2 = pts[(cornerIdx + 2) % 3];

      final dist1 = measureDistance(h, corner, arm1);
      final dist2 = measureDistance(h, corner, arm2);

      final dx1 = (arm1.dx - corner.dx).abs();
      final dy1 = (arm1.dy - corner.dy).abs();

      if (dx1 >= dy1) {
        return (widthM: dist1, heightM: dist2);
      } else {
        return (widthM: dist2, heightM: dist1);
      }
    }

    final sorted = _sortClockwise(pts);
    final tl = sorted[0];
    final tr = sorted[1];
    final br = sorted[2];
    final bl = sorted[3];

    final topW = measureDistance(h, tl, tr);
    final botW = measureDistance(h, bl, br);
    final leftH = measureDistance(h, tl, bl);
    final rightH = measureDistance(h, tr, br);

    return (widthM: (topW + botW) / 2, heightM: (leftH + rightH) / 2);
  }

  List<Offset> _sortClockwise(List<Offset> pts) {
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

  void _finishMarking() {
    if (_refPoints.length < 4 || _wallPoints.length < 2) return;

    // 1. Auto-detect orientation of the reference object
    final topEdgePx = (_refPoints[0] - _refPoints[1]).distance;
    final rightEdgePx = (_refPoints[1] - _refPoints[2]).distance;

    double refW = widget.reference.widthM;
    double refH = widget.reference.heightM;

    // If the physical dimensions and on-screen pixel proportions mismatch,
    // the user likely placed the reference object rotated by 90 degrees.
    if ((refW > refH && topEdgePx < rightEdgePx) ||
        (refW < refH && topEdgePx > rightEdgePx)) {
      refW = widget.reference.heightM;
      refH = widget.reference.widthM;
    }

    // 2. Build the exact real-world mapping quad
    final refRealOffsets = [
      Offset.zero,
      Offset(refW, 0),
      Offset(refW, refH),
      Offset(0, refH),
    ];

    // 3. Compute homography and analyze
    final h = computeHomography(_refPoints, refRealOffsets);
    final (:widthM, :heightM) = _analyzeWallPoints(_wallPoints, h);

    final result = MeasurementResultEntity(
      imagePath: widget.imagePath,
      imageSize: _imageSize,
      refPoints: List.from(_refPoints),
      wallPoints: List.from(_wallPoints),
      widthM: widthM,
      heightM: heightM,
    );

    // Save debug info in background
    // _saveDebugInfo(result);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) => MeasurementResultScreen(result: result)),
    );
  }



  // ── Tutorial overlay ──────────────────────────────────────────────────────

  void _dismissTutorial() => setState(() => _showTutorial = false);
  void _showTutorialOverlay() => setState(() => _showTutorial = true);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_uiImage == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopUI(),
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  final viewport = constraints.biggest;
                  return Stack(
                    key: _stackKey,
                    clipBehavior: Clip.none,
                    children: [
                      _buildInteractiveImage(viewport),
                      ..._buildPointMarkers(viewport),
                      if (_activePoints.length > 1) _buildLines(viewport),
                      if (_dragIndex != null && _dragScreenPos != null)
                        _buildLoupe(),
                      if (_selectedIndex != null && _dragIndex == null)
                        _buildNudgePad(),
                    ],
                  );
                }),
              ),
              _buildBottomToolbar(),
            ],
          ),
          if (_showTutorial) _buildTutorialOverlay(),
        ],
      ),
    );
  }

  Widget _buildInteractiveImage(Size viewport) {
    if (_imageSize == Size.zero) return const SizedBox();

    // Determine the fitted dimension sizes natively
    final fitScale = math.min(
      viewport.width / _imageSize.width,
      viewport.height / _imageSize.height,
    );
    final fittedWidth = _imageSize.width * fitScale;
    final fittedHeight = _imageSize.height * fitScale;

    return GestureDetector(
      onTapUp: (d) {
        if (_showTutorial) {
          _dismissTutorial();
          return;
        }
        if (_isLocked || _activePoints.length >= _maxPoints) return;

        final imgPos = _screenToImage(d.localPosition, viewport);
        if (imgPos.dx >= 0 &&
            imgPos.dy >= 0 &&
            imgPos.dx <= _imageSize.width &&
            imgPos.dy <= _imageSize.height) {
          _addPoint(imgPos);
        }
      },
      child: InteractiveViewer(
        transformationController: _transformCtrl,
        constrained: true, // Let it naturally center to the viewport size
        minScale: 1.0, // Prevents zooming out smaller than fitted
        maxScale: 10.0,
        child: SizedBox(
          width: viewport.width,
          height: viewport.height,
          child: Center(
            child: SizedBox(
              width: fittedWidth,
              height: fittedHeight,
              child: RawImage(image: _uiImage, fit: BoxFit.fill),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPointMarkers(Size viewport) {
    final color = _phase == MarkingPhase.reference
        ? RoomAppColors.primary
        : RoomAppColors.secondary;
    return [
      for (int i = 0; i < _activePoints.length; i++)
        _buildMarker(i, _activePoints[i], color, viewport),
    ];
  }

  Widget _buildMarker(int i, Offset imgPt, Color color, Size viewport) {
    final sp = _imageToScreen(imgPt, viewport);
    final isSelected = _selectedIndex == i;
    final isDragging = _dragIndex == i;
    return Positioned(
      left: sp.dx - 18,
      top: sp.dy - 18,
      child: GestureDetector(
        onTap: _isLocked ? null : () => setState(() => _selectedIndex = i),
        onPanStart: _isLocked
            ? null
            : (d) => setState(() {
                  _dragIndex = i;
                  _selectedIndex = i;
                  _dragStartImagePos = _activePoints[i];
                  _dragScreenPos = d.globalPosition;
                }),
        onPanUpdate: _isLocked
            ? null
            : (d) {
                // Ensure drag matches the exact total visual scale
                final fitScale = math.min(
                  viewport.width / _imageSize.width,
                  viewport.height / _imageSize.height,
                );
                final zoom = _transformCtrl.value.getMaxScaleOnAxis();
                final totalScale = fitScale * zoom;

                // The friction multiplier for precision dragging.
                // 0.4 means the point moves at 40% the speed of your finger.
                // Tweak this number to get the exact feel you want (lower = slower).
                const precisionFriction = 0.4;

                setState(() {
                  _activePoints[i] = _activePoints[i] +
                      Offset((d.delta.dx * precisionFriction) / totalScale,
                          (d.delta.dy * precisionFriction) / totalScale);
                  _dragScreenPos = d.globalPosition;
                });
              },
        onPanEnd: _isLocked
            ? null
            : (_) {
                if (_dragIndex != null && _dragStartImagePos != null) {
                  final group = _phase == MarkingPhase.reference
                      ? PointGroup.reference
                      : PointGroup.wall;
                  _undoStack.add(MovePointAction(
                    group: group,
                    index: i,
                    oldPosition: _dragStartImagePos!,
                    newPosition: _activePoints[i],
                  ));
                  _redoStack.clear();
                }
                setState(() {
                  _dragIndex = null;
                  _dragScreenPos = null;
                  _dragStartImagePos = null;
                });
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDragging
                ? color
                : isSelected
                    ? color.withValues(alpha: 0.9)
                    : color.withValues(alpha: 0.7),
            border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: isSelected ? 12 : 6),
            ],
          ),
          child: Center(
            child: Text(
              i < _pointLabels.length ? _pointLabels[i] : '${i + 1}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLines(Size viewport) {
    final pts = _activePoints.map((p) => _imageToScreen(p, viewport)).toList();
    final displayPts = (_phase == MarkingPhase.wall && pts.length == 4)
        ? _sortClockwise(pts)
        : pts;
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _LinePainter(
            points: displayPts,
            color: _phase == MarkingPhase.reference
                ? RoomAppColors.primary
                : RoomAppColors.secondary,
            close: _phase == MarkingPhase.reference
                ? pts.length == 4
                : pts.length == 4,
          ),
        ),
      ),
    );
  }

  Widget _buildLoupe() {
    const loupeSize = 130.0;
    const zoom = 3.0;
    const fingerOffset = 80.0;
    final imagePos = _activePoints[_dragIndex!];

    final RenderBox stackBox =
        _stackKey.currentContext!.findRenderObject() as RenderBox;
    final localPos = stackBox.globalToLocal(_dragScreenPos!);
    final screenW = stackBox.size.width;

    double lx = localPos.dx - loupeSize / 2;
    double ly = localPos.dy - loupeSize - fingerOffset;
    if (lx < 4) lx = 4;
    if (lx + loupeSize > screenW - 4) lx = screenW - loupeSize - 4;
    if (ly < 4) ly = localPos.dy + 40;

    return Positioned(
      left: lx,
      top: ly,
      child: IgnorePointer(
        child: Container(
          width: loupeSize,
          height: loupeSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: RoomAppColors.primary, width: 3),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5), blurRadius: 16),
            ],
          ),
          child: ClipOval(
            child: CustomPaint(
              size: const Size(loupeSize, loupeSize),
              painter:
                  _LoupePainter(image: _uiImage!, center: imagePos, zoom: zoom),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopUI() {
    final isRef = _phase == MarkingPhase.reference;
    final count = _activePoints.length;
    final String subtitle;
    if (isRef) {
      subtitle =
          'Tap the 4 corners of your ${widget.reference.name} in Clockwise order. It MUST be flat against the surface you want to measure.';
    } else if (count < 2) {
      subtitle = 'Tap at least 2 points. Add up to 4 for width & height.';
    } else if (count == 2) {
      subtitle = 'Good! Tap to add more points, or tap Get Results.';
    } else if (count == 3) {
      subtitle = 'One more point gives a full quad, or tap Get Results.';
    } else {
      subtitle = 'All 4 points placed. Tap Get Results when ready.';
    }

    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _glassBtn(Icons.close, () => Navigator.pop(context)),
                const Spacer(),
                _glassBtn(
                  Icons.help_outline_rounded,
                  _showTutorialOverlay,
                ),
                const SizedBox(width: 8),
                _glassBtn(
                  _isLocked ? Icons.lock : Icons.lock_open,
                  () => setState(() => _isLocked = !_isLocked),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: RoomAppColors.glassBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: RoomAppColors.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isRef
                              ? RoomAppColors.primary.withValues(alpha: 0.3)
                              : RoomAppColors.secondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isRef ? 'Phase 1' : 'Phase 2',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isRef
                            ? 'Mark Reference (${_refPoints.length}/4)'
                            : 'Mark Surface (${_wallPoints.length}/4, min 2)',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12),
                  ),
                  if (!isRef && _isRefTooSmall)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.red.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.redAccent, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Warning: Reference object is very small in this photo. Results may be unstable.',
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (!isRef)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: Colors.amberAccent, size: 15),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Results require points to be on the same physical surface as your reference object.',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3),
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
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBottomToolbar() {
    final isRef = _phase == MarkingPhase.reference;
    final canAdvance = isRef && _refPoints.length == 4;
    final canFinish = !isRef && _wallPoints.length >= 2;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: RoomAppColors.glassBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: RoomAppColors.glassBorder),
          ),
          child: Row(
            children: [
              _toolBtn(Icons.undo, _undoStack.isNotEmpty, _undo),
              _toolBtn(Icons.redo, _redoStack.isNotEmpty, _redo),
              const Spacer(),
              if (!isRef) _toolBtn(Icons.arrow_back, true, _backToRefPhase),
              GestureDetector(
                onTap: canAdvance
                    ? _advanceToWallPhase
                    : canFinish
                        ? _finishMarking
                        : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: (canAdvance || canFinish)
                        ? (canFinish ? RoomAppColors.arSuccess : RoomAppColors.primary)
                        : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    canFinish ? 'Get Results' : 'Next Phase',
                    style: TextStyle(
                      color: (canAdvance || canFinish)
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNudgePad() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: RoomAppColors.glassBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: RoomAppColors.glassBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _nudgeBtn(Icons.keyboard_arrow_up, 0, -1),
            Row(mainAxisSize: MainAxisSize.min, children: [
              _nudgeBtn(Icons.keyboard_arrow_left, -1, 0),
              const SizedBox(width: 32, height: 32),
              _nudgeBtn(Icons.keyboard_arrow_right, 1, 0),
            ]),
            _nudgeBtn(Icons.keyboard_arrow_down, 0, 1),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => setState(() => _selectedIndex = null),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Done',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialOverlay() {
    final isRef = _phase == MarkingPhase.reference;
    return GestureDetector(
      onTap: _dismissTutorial,
      child: Container(
        color: Colors.black.withValues(alpha: 0.72),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 100),
              Expanded(
                child: Center(
                  child: _phase == MarkingPhase.reference
                      ? RefTutorialAnimation(
                          animCtrl: _tutorialAnimCtrl,
                          dotCtrl: _tutorialDotCtrl,
                        )
                      : WallTutorialAnimation(
                          animCtrl: _tutorialAnimCtrl,
                          dotCtrl: _tutorialDotCtrl,
                        ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                child: Column(
                  children: [
                    Text(
                      isRef ? 'Mark the 4 Corners' : 'Mark 2–4 Surface Points',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isRef
                          ? 'Tap each corner of your ${widget.reference.name} in order: top-left → top-right → bottom-right → bottom-left.'
                          : 'Place 2 points for a single distance, 3 for width & height, or 4 for a full quad.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 14,
                        height: 1.55,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (!isRef) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _modeChip(
                          '2 pts', 'Distance', Icons.linear_scale_rounded),
                      const SizedBox(width: 8),
                      _modeChip(
                          '3 pts', 'Width + Height', Icons.crop_free_rounded),
                      const SizedBox(width: 8),
                      _modeChip(
                          '4 pts', 'Full Quad', Icons.crop_square_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 4, 32, 20),
                child: GestureDetector(
                  onTap: _dismissTutorial,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isRef ? RoomAppColors.primary : RoomAppColors.secondary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Got it — tap to start',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeChip(String pts, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: RoomAppColors.secondary, size: 18),
          const SizedBox(height: 3),
          Text(pts,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _nudgeBtn(IconData icon, double dx, double dy) {
    return GestureDetector(
      onTap: () => _nudge(dx, dy),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _glassBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _toolBtn(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(icon,
            color:
                enabled ? Colors.white : Colors.white.withValues(alpha: 0.25),
            size: 22),
      ),
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

class _LoupePainter extends CustomPainter {
  final ui.Image image;
  final Offset center;
  final double zoom;
  _LoupePainter(
      {required this.image, required this.center, required this.zoom});

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromCenter(
        center: center, width: size.width / zoom, height: size.height / zoom);
    canvas.drawImageRect(
        image, src, Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    final cx = size.width / 2;
    final cy = size.height / 2;
    final p = Paint()
      ..color = Colors.red.withValues(alpha: 0.8)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(cx - 12, cy), Offset(cx + 12, cy), p);
    canvas.drawLine(Offset(cx, cy - 12), Offset(cx, cy + 12), p);
  }

  @override
  bool shouldRepaint(_LoupePainter old) =>
      old.center != center || old.zoom != zoom;
}

class _LinePainter extends CustomPainter {
  final List<Offset> points;
  final Color color;
  final bool close;
  _LinePainter(
      {required this.points, required this.color, required this.close});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    if (close && points.length >= 3) path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LinePainter _) => true;
}