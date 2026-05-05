import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/app_colors.dart';
import 'models.dart';
import 'photo_marking_screen.dart';

class ReferenceScreen extends StatefulWidget {
  const ReferenceScreen({super.key});

  @override
  State<ReferenceScreen> createState() => _ReferenceScreenState();
}

class _ReferenceScreenState extends State<ReferenceScreen> {
  final _picker = ImagePicker();
  int _selectedIndex = 0;
  bool _showCustom = false;
  final _widthCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _nameCtrl = TextEditingController(text: 'My Object');

  @override
  void dispose() {
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  ReferenceObject get _selectedRef {
    if (_showCustom) {
      return ReferenceObject(
        name: _nameCtrl.text.isEmpty ? 'Custom' : _nameCtrl.text,
        widthMm: double.tryParse(_widthCtrl.text) ?? 0,
        heightMm: double.tryParse(_heightCtrl.text) ?? 0,
        isCustom: true,
      );
    }
    return ReferenceObject.presets[_selectedIndex];
  }

  bool get _canProceed {
    if (_showCustom) {
      final w = double.tryParse(_widthCtrl.text);
      final h = double.tryParse(_heightCtrl.text);
      return w != null && w > 0 && h != null && h > 0;
    }
    return true;
  }

  Future<void> _proceed() async {
    if (!_canProceed) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Choose Photo Source',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SourceBtn(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () => Navigator.pop(context, ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SourceBtn(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null || !mounted) return;

    final xFile = await _picker.pickImage(
      source: source,
      maxWidth: 2048,
      imageQuality: 90,
    );
    if (xFile == null || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoMarkingScreen(
          imagePath: xFile.path,
          reference: _selectedRef,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reference Object',
            style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select a reference object',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Place this object flat against the surface you\'re '
                      'photographing. It calibrates the scale. The bigger the object, the more accurate the measurement will be.',
                      style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    // Presets
                    ...List.generate(ReferenceObject.presets.length, (i) {
                      final ref = ReferenceObject.presets[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _RefTile(
                          label: ref.name,
                          detail:
                              '${ref.widthMm.toStringAsFixed(1)} × ${ref.heightMm.toStringAsFixed(1)} mm',
                          selected: !_showCustom && _selectedIndex == i,
                          onTap: () => setState(() {
                            _selectedIndex = i;
                            _showCustom = false;
                          }),
                        ),
                      );
                    }),

                    // Custom
                    _RefTile(
                      label: 'Custom Object',
                      detail: 'Enter your own dimensions',
                      selected: _showCustom,
                      onTap: () => setState(() => _showCustom = true),
                    ),

                    if (_showCustom) ...[
                      const SizedBox(height: 16),
                      _buildCustomFields(),
                    ],
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canProceed
                        ? AppColors.button
                        : Colors.grey.shade300,
                    foregroundColor: AppColors.buttonText,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Choose Photo',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  onPressed: _canProceed ? _proceed : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Object Name',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _widthCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Width (mm)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _heightCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Height (mm)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _RefTile extends StatelessWidget {
  final String label;
  final String detail;
  final bool selected;
  final VoidCallback onTap;

  const _RefTile({
    required this.label,
    required this.detail,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(detail,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SourceBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
