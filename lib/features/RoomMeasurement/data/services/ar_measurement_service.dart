import 'dart:ui';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../../domain/models/room_model.dart';

// ─────────────────────────────────────────────
//  ArMeasurementService
//  بيتعامل مع ARCore مباشرة ويرجع المسافات
//  بالمتر بدون أي reference object
// ─────────────────────────────────────────────
class ArMeasurementService {
  ArCoreController? _arController;

  // النقط اللي المستخدم وضعها في الـ AR world
  final List<vm.Vector3> _placedPoints = [];

  // Callback لما تتضاف نقطة جديدة
  void Function(int count)? onPointAdded;

  // ── تهيئة الـ ARCore controller ────────────────

  void initController(ArCoreController controller) {
    _arController = controller;
    _arController!.onPlaneTap = _onPlaneTap;
  }

  // ── لما المستخدم يضغط على سطح ─────────────────

  void _onPlaneTap(List<ArCoreHitTestResult> hits) {
    if (hits.isEmpty) return;
    if (_placedPoints.length >= 4) return; // max 4 نقط

    final hit = hits.first;
    final position = hit.pose.translation;

    // إضافة sphere صغيرة في مكان اللمس عشان المستخدم يشوفها
    _addAnchorSphere(hit, position);

    _placedPoints.add(position);
    onPointAdded?.call(_placedPoints.length);
  }

  // ── رسم sphere في الـ AR scene ────────────────

  void _addAnchorSphere(ArCoreHitTestResult hit, vm.Vector3 position) {
    final material = ArCoreMaterial(
      color: const Color(0xFF00E5FF),
      metallic: 0.5,
    );

    final sphere = ArCoreSphere(
      materials: [material],
      radius: 0.015, // 1.5 سم
    );

    final node = ArCoreReferenceNode(
      name: 'point_${_placedPoints.length}',
      objectUrl: '', // مش محتاجين object خارجي
    );

    // بنستخدم ArCoreNode مع الـ shape مباشرة
    final shapeNode = ArCoreNode(
      shape: sphere,
      position: position,
    );

    _arController?.addArCoreNode(shapeNode);

    // لو في نقطة قبلها، نرسم خط بينهم
    if (_placedPoints.isNotEmpty) {
      _drawLineBetween(_placedPoints.last, position);
    }
  }

  // ── رسم خط بين نقطتين ────────────────────────

  void _drawLineBetween(vm.Vector3 from, vm.Vector3 to) {
    final mid = (from + to) / 2.0;
    final diff = to - from;
    final length = diff.length;

    final cylinder = ArCoreCylinder(
      materials: [
        ArCoreMaterial(
          color: const Color(0xFF00E5FF).withOpacity(0.7),
        )
      ],
      radius: 0.005, // 5 مم سماكة الخط
      height: length,
    );

    final lineNode = ArCoreNode(
      shape: cylinder,
      position: mid,
    );

    _arController?.addArCoreNode(lineNode);
  }

  // ── حساب المسافة بين نقطتين ──────────────────

  double _distanceBetween(vm.Vector3 a, vm.Vector3 b) {
    return (a - b).length; // بالمتر مباشرة
  }

  // ── الحصول على النتيجة النهائية ───────────────

  ArMeasurementResult? getResult() {
    if (_placedPoints.length < 2) return null;

    final pts = _placedPoints;

    if (pts.length == 2) {
      // مسافة واحدة فقط
      final dist = _distanceBetween(pts[0], pts[1]);
      final dx = (pts[1].x - pts[0].x).abs();
      final dy = (pts[1].y - pts[0].y).abs();

      return ArMeasurementResult(
        points: pts.map((p) => Offset(p.x, p.y)).toList(),
        widthM: dx >= dy ? dist : 0,
        heightM: dx < dy ? dist : 0,
      );
    }

    if (pts.length == 3) {
      // نقطة corner + ذراعين
      int cornerIdx = _findCornerIndex(pts);
      final corner = pts[cornerIdx];
      final arm1 = pts[(cornerIdx + 1) % 3];
      final arm2 = pts[(cornerIdx + 2) % 3];

      final d1 = _distanceBetween(corner, arm1);
      final d2 = _distanceBetween(corner, arm2);

      // الأكبر = عرض، الأصغر = ارتفاع
      return ArMeasurementResult(
        points: pts.map((p) => Offset(p.x, p.y)).toList(),
        widthM: d1 >= d2 ? d1 : d2,
        heightM: d1 < d2 ? d1 : d2,
      );
    }

    // 4 نقط = quad كامل
    final topW = _distanceBetween(pts[0], pts[1]);
    final botW = _distanceBetween(pts[3], pts[2]);
    final leftH = _distanceBetween(pts[0], pts[3]);
    final rightH = _distanceBetween(pts[1], pts[2]);

    return ArMeasurementResult(
      points: pts.map((p) => Offset(p.x, p.y)).toList(),
      widthM: (topW + botW) / 2,
      heightM: (leftH + rightH) / 2,
    );
  }

  // ── إيجاد الـ corner (أقرب زاوية لـ 90 درجة) ──

  int _findCornerIndex(List<vm.Vector3> pts) {
    int cornerIdx = 0;
    double smallest = double.infinity;
    for (int i = 0; i < 3; i++) {
      final a = pts[(i + 1) % 3] - pts[i];
      final b = pts[(i + 2) % 3] - pts[i];
      final cosA = a.dot(b) / (a.length * b.length + 1e-15);
      final angle = cosA.clamp(-1.0, 1.0);
      final diff = (angle).abs(); // كلما قرب من 0 = 90 درجة
      if (diff < smallest) {
        smallest = diff;
        cornerIdx = i;
      }
    }
    return cornerIdx;
  }

  // ── Reset ─────────────────────────────────────

  void reset() {
    _placedPoints.clear();
    _arController?.dispose();
  }

  void dispose() {
    _arController?.dispose();
  }
}