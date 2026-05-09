import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import '../bloc/room_measurement_bloc.dart';
import '../../domain/models/room_model.dart';
import 'history_screen.dart';

// ─────────────────────────────────────────────
//  ArMeasurementScreen
//  شاشة الـ AR الرئيسية — بدون reference object
// ─────────────────────────────────────────────
class ArMeasurementScreen extends StatelessWidget {
  const ArMeasurementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoomMeasurementBloc, RoomMeasurementState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // ── AR View (الكاميرا + ARCore) ──────────
              _ArView(),

              // ── HUD فوق الكاميرا ──────────────────────
              _TopBar(),
              _BottomHud(state: state),

              // ── Loading overlay ───────────────────────
              if (state is SavingState) _buildSavingOverlay(),
            ],
          ),
        );
      },
    );
  }

  // ── Listener ────────────────────────────────

  void _handleStateChanges(BuildContext context, RoomMeasurementState state) {
    if (state is MeasurementReadyState) {
      _showSaveDialog(context, state.result);
    }
    if (state is RoomsLoadedState) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HistoryScreen()),
      );
    }
    if (state is RoomMeasurementErrorState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── Save Dialog ──────────────────────────────

  Future<void> _showSaveDialog(
      BuildContext context, ArMeasurementResult result) async {
    final controller = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SaveBottomSheet(
        result: result,
        controller: controller,
        onSave: (name) {
          Navigator.pop(context);
          context.read<RoomMeasurementBloc>().add(SaveRoomEvent(name));
        },
        onDiscard: () {
          Navigator.pop(context);
          context.read<RoomMeasurementBloc>().add(ResetSessionEvent());
        },
      ),
    );
  }

  Widget _buildSavingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('جاري الحفظ...',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _ArView – يشيل ArCoreView ويبعت controller
// ─────────────────────────────────────────────
class _ArView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ArCoreView(
      onArCoreViewCreated: (controller) {
        context
            .read<RoomMeasurementBloc>()
            .add(ArControllerReadyEvent(controller));
      },
      enableTapRecognizer: true,
      enableUpdateListener: false, // مش محتاجين update loop مستمر
    );
  }
}

// ─────────────────────────────────────────────
//  _TopBar
// ─────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _GlassButton(
              icon: Icons.close,
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
            _GlassButton(
              icon: Icons.history_rounded,
              label: 'السجل',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              ),
            ),
            const SizedBox(width: 8),
            _GlassButton(
              icon: Icons.refresh_rounded,
              onTap: () =>
                  context.read<RoomMeasurementBloc>().add(ResetSessionEvent()),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _BottomHud – التعليمات + زرار الحساب
// ─────────────────────────────────────────────
class _BottomHud extends StatelessWidget {
  const _BottomHud({required this.state});
  final RoomMeasurementState state;

  @override
  Widget build(BuildContext context) {
    final pointCount =
        state is ArSessionActiveState ? (state as ArSessionActiveState).pointCount : 0;

    final String instruction = switch (pointCount) {
      0 => 'وجّه الكاميرا للسطح وانتظر ARCore يكتشفه، ثم اضغط لوضع أول نقطة',
      1 => 'ضع نقطة ثانية لقياس المسافة',
      2 => 'يمكنك الحساب الآن، أو أضف نقطة ثالثة لعرض + ارتفاع',
      3 => 'أضف نقطة رابعة لـ quad كامل، أو احسب الآن',
      _ => 'ممتاز! الـ quad مكتمل — احسب الآن',
    };

    final canCalculate = pointCount >= 2;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.75),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── مؤشر النقط ──────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < pointCount;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? const Color(0xFF00E5FF)
                          : Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: const Color(0xFF00E5FF).withOpacity(0.6),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 12),

              // ── التعليمة ────────────────────────────
              Text(
                instruction,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 16),

              // ── زرار الحساب ─────────────────────────
              SizedBox(
                width: double.infinity,
                child: AnimatedOpacity(
                  opacity: canCalculate ? 1.0 : 0.35,
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: canCalculate
                        ? () => context
                            .read<RoomMeasurementBloc>()
                            .add(CalculateMeasurementEvent())
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF006B7A), Color(0xFF00E5FF)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.straighten_rounded,
                              color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'احسب القياسات',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
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
}

// ─────────────────────────────────────────────
//  _SaveBottomSheet
// ─────────────────────────────────────────────
class _SaveBottomSheet extends StatelessWidget {
  const _SaveBottomSheet({
    required this.result,
    required this.controller,
    required this.onSave,
    required this.onDiscard,
  });

  final ArMeasurementResult result;
  final TextEditingController controller;
  final void Function(String name) onSave;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0D0D0D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle ──────────────────────────────
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // ── النتيجة ──────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _ResultCard(
                    label: 'العرض',
                    value: '${result.widthM.toStringAsFixed(2)} م',
                    valueSub:
                        '${(result.widthM * 100).toStringAsFixed(1)} سم',
                    color: const Color(0xFF00E5FF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ResultCard(
                    label: 'الارتفاع',
                    value: '${result.heightM.toStringAsFixed(2)} م',
                    valueSub:
                        '${(result.heightM * 100).toStringAsFixed(1)} سم',
                    color: const Color(0xFFFF9800),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ── المساحة ──────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'المساحة: ${result.area.toStringAsFixed(2)} م²',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── اسم الغرفة ──────────────────────────
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'اسم الغرفة (مثال: غرفة المعيشة)',
                hintStyle: TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),

            const SizedBox(height: 16),

            // ── Buttons ──────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDiscard,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white54,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('تجاهل'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => onSave(controller.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'حفظ الغرفة',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _ResultCard
// ─────────────────────────────────────────────
class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.label,
    required this.value,
    required this.valueSub,
    required this.color,
  });

  final String label;
  final String value;
  final String valueSub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1)),
          const SizedBox(height: 2),
          Text(valueSub,
              style:
                  TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  _GlassButton
// ─────────────────────────────────────────────
class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap, this.label});

  final IconData icon;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: label != null
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 9)
            : const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(label!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}