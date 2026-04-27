import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import '../bloc/measurement_bloc.dart';
import '../widgets/ar_overlay_widget.dart';
import '../../data/datasource/camera_measurement_service.dart';
import '../../data/repository/measurement_repository_impl.dart';
import '../../domain/models/room_dimensions.dart';
import '../../domain/usecases/measure_room_usecase.dart';

// ─── Brand Colors ────────────────────────────────────────────────────────────
class AppColors {
  static const primary    = Color(0xFFCF8D5B);
  static const dark       = Color(0xFF7D533D);
  static const medium     = Color(0xFFA36846);
  static const light      = Color(0xFFEBA46E);
  static const lighter    = Color(0xFFF0B589);
  static const lightest   = Color(0xFFF5D1A9);
  static const background = Color(0xFFFDF6EE);
  static const white      = Color(0xFFFFFFFF);
}

// ─── Screen ──────────────────────────────────────────────────────────────────
class MeasurementScreen extends StatefulWidget {
  const MeasurementScreen({super.key});

  @override
  State<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends State<MeasurementScreen> {
  late final CameraMeasurementService _cameraService;
  late final MeasurementBloc _bloc;

  @override
  void initState() {
    super.initState();
    _cameraService = CameraMeasurementService();
    final repository = MeasurementRepositoryImpl(cameraService: _cameraService);
    _bloc = MeasurementBloc(
      measureRoomUseCase: MeasureRoomUseCase(repository: repository),
      getLastMeasurementUseCase: GetLastMeasurementUseCase(repository: repository),
    );
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      await _cameraService.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e'),
              backgroundColor: AppColors.dark),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocConsumer<MeasurementBloc, MeasurementState>(
          listener: (context, state) {
            if (state is MeasurementFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message),
                    backgroundColor: AppColors.dark),
              );
            }
            if (state is MeasurementSuccess) {
              _showSaveDialog(context, state.dimensions);
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                _buildCameraPreview(),
                AROverlayWidget(
                  dimensions: state is MeasurementSuccess ? state.dimensions : null,
                  isScanning: state is MeasurementLoading,
                ),
                _buildTopBar(context),
                _buildBottomControls(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final ctrl = _cameraService.controller;
    if (ctrl == null || !ctrl.value.isInitialized) {
      return Container(
        color: AppColors.dark,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.lighter),
        ),
      );
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: ctrl.value.previewSize!.height,
          height: ctrl.value.previewSize!.width,
          child: CameraPreview(ctrl),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _GlassButton(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: AppColors.lightest, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.dark.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lighter.withOpacity(0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.straighten, color: AppColors.lighter, size: 16),
                    SizedBox(width: 6),
                    Text('Room Measurement',
                        style: TextStyle(
                            color: AppColors.lightest,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Spacer(),
              _GlassButton(
                onTap: () => _showSavedRooms(context),
                child: const Icon(Icons.bookmark_outlined,
                    color: AppColors.lighter, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, MeasurementState state) {
    final isLoading = state is MeasurementLoading;
    final hasResult = state is MeasurementSuccess;

    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!hasResult && !isLoading)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.dark.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lighter.withOpacity(0.3)),
                ),
                child: const Text(
                  'Point the camera at the room, then tap Measure',
                  style: TextStyle(color: AppColors.lightest, fontSize: 12),
                ),
              ),
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.dark.withOpacity(0.88),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.lighter.withOpacity(0.35)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasResult) ...[
                    _DimensionsCard(
                        dimensions: (state as MeasurementSuccess).dimensions),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _OutlineBtn(
                            icon: Icons.refresh,
                            label: 'Re-measure',
                            onTap: () => _bloc.add(const ResetMeasurementEvent()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _OutlineBtn(
                            icon: Icons.bookmark_add_outlined,
                            label: 'Save',
                            onTap: () =>
                                _showSaveDialog(context, state.dimensions),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => _bloc.add(const StartMeasurementEvent()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor:
                            AppColors.primary.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                ),
                                SizedBox(width: 10),
                                Text('Measuring...',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                              ],
                            )
                          : Text(
                              hasResult ? 'Measure Again' : 'Start Measuring',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Save dialog (proper Dialog — no autofocus, no keyboard jump) ──────────
  void _showSaveDialog(BuildContext context, RoomDimensions dimensions) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.lightest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bookmark_add_outlined,
                        color: AppColors.dark, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('Save Dimensions',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(dialogContext),
                    child: Icon(Icons.close,
                        color: AppColors.medium.withOpacity(0.7), size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Dimensions chips
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.lightest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lighter),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _InfoChip(label: 'Length',
                        value: '${dimensions.length.toStringAsFixed(2)}m'),
                    _InfoChip(label: 'Width',
                        value: '${dimensions.width.toStringAsFixed(2)}m'),
                    _InfoChip(label: 'Height',
                        value: '${dimensions.height.toStringAsFixed(2)}m'),
                    _InfoChip(label: 'Area',
                        value: '${dimensions.area.toStringAsFixed(1)}m²'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Room Name',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark)),
              const SizedBox(height: 8),
              // TextField — autofocus FALSE to prevent keyboard jump
              TextField(
                controller: controller,
                autofocus: false,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: AppColors.dark, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'e.g. Master Bedroom',
                  hintStyle: TextStyle(
                      color: AppColors.medium.withOpacity(0.55),
                      fontSize: 14),
                  prefixIcon: const Icon(Icons.meeting_room_outlined,
                      color: AppColors.primary, size: 20),
                  filled: true,
                  fillColor: AppColors.lightest.withOpacity(0.4),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.lighter, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.medium,
                        side: const BorderSide(color: AppColors.lighter),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final name = controller.text.trim();
                        if (name.isEmpty) return;
                        SavedRoomsStore.save(
                            SavedRoom(name: name, dimensions: dimensions));
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('"$name" saved successfully'),
                            backgroundColor: AppColors.medium,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text('Save',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Saved rooms sheet ────────────────────────────────────────────────────
  void _showSavedRooms(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lighter,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.bookmark, color: AppColors.primary, size: 22),
                    SizedBox(width: 8),
                    Text('Saved Rooms',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StatefulBuilder(
                  builder: (ctx, setS) {
                    final rooms = SavedRoomsStore.all;
                    if (rooms.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_outlined,
                                size: 56,
                                color: AppColors.lighter.withOpacity(0.7)),
                            const SizedBox(height: 12),
                            const Text('No saved rooms yet',
                                style: TextStyle(
                                    color: AppColors.medium, fontSize: 14)),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: rooms.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _SavedRoomTile(
                        room: rooms[i],
                        onDelete: () {
                          SavedRoomsStore.delete(i);
                          setS(() {});
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Info Chip ────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.medium,
                fontSize: 10,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: AppColors.dark,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ─── Dimensions Card ──────────────────────────────────────────────────────────
class _DimensionsCard extends StatelessWidget {
  final RoomDimensions dimensions;
  const _DimensionsCard({required this.dimensions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _DimTile(icon: Icons.straighten, label: 'Length',
                value: '${dimensions.length.toStringAsFixed(2)} m',
                color: AppColors.primary),
            const SizedBox(width: 8),
            _DimTile(icon: Icons.swap_horiz, label: 'Width',
                value: '${dimensions.width.toStringAsFixed(2)} m',
                color: AppColors.light),
            const SizedBox(width: 8),
            _DimTile(icon: Icons.height, label: 'Height',
                value: '${dimensions.height.toStringAsFixed(2)} m',
                color: AppColors.lighter),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lighter.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SmallStat(label: 'Floor Area',
                  value: '${dimensions.area.toStringAsFixed(2)} m²'),
              Container(width: 1, height: 24,
                  color: AppColors.lighter.withOpacity(0.4)),
              _SmallStat(label: 'Volume',
                  value: '${dimensions.volume.toStringAsFixed(2)} m³'),
            ],
          ),
        ),
      ],
    );
  }
}

class _DimTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _DimTile({required this.icon, required this.label,
      required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(color: color, fontSize: 10,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(color: AppColors.lightest,
                    fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final String label;
  final String value;
  const _SmallStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.lighter, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(color: AppColors.lightest,
                fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ─── Outline Button ───────────────────────────────────────────────────────────
class _OutlineBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _OutlineBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lighter.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.lighter, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: AppColors.lightest, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ─── Glass Button ─────────────────────────────────────────────────────────────
class _GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _GlassButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.dark.withOpacity(0.65),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lighter.withOpacity(0.3)),
        ),
        child: child,
      ),
    );
  }
}

// ─── Saved Room Tile ──────────────────────────────────────────────────────────
class _SavedRoomTile extends StatelessWidget {
  final SavedRoom room;
  final VoidCallback onDelete;
  const _SavedRoomTile({required this.room, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final d = room.dimensions;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightest),
        boxShadow: [
          BoxShadow(color: AppColors.lighter.withOpacity(0.15),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.lightest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.meeting_room_outlined,
                color: AppColors.dark, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(room.name,
                    style: const TextStyle(
                        color: AppColors.dark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  '${d.length.toStringAsFixed(2)}m x ${d.width.toStringAsFixed(2)}m x ${d.height.toStringAsFixed(2)}m',
                  style: const TextStyle(color: AppColors.medium, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text('Floor area: ${d.area.toStringAsFixed(2)} m²',
                    style: const TextStyle(
                        color: AppColors.primary, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline,
                color: AppColors.medium.withOpacity(0.7), size: 20),
          ),
        ],
      ),
    );
  }
}


class SavedRoom {
  final String name;
  final RoomDimensions dimensions;
  const SavedRoom({required this.name, required this.dimensions});
}

class SavedRoomsStore {
  static final List<SavedRoom> _rooms = [];
  static List<SavedRoom> get all => List.unmodifiable(_rooms);
  static void save(SavedRoom room) => _rooms.add(room);
  static void delete(int index) => _rooms.removeAt(index);
}