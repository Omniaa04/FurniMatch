import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/settings_bloc.dart';
import '../widgets/help_page.dart';
import '../widgets/policy_page.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is CacheCleared) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('AR cache cleared successfully'),
              backgroundColor: const Color(0xFF2C2416),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is SettingsLoading || state is SettingsInitial) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F3EE),
            body: Center(
                child: CircularProgressIndicator(color: Color(0xFF8B6914))),
          );
        }
        if (state is SettingsError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F3EE),
            body: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.error_outline, size: 48, color: Color(0xFF8B6914)),
                const SizedBox(height: 12),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<SettingsBloc>().add(LoadSettingsEvent()),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2416)),
                  child: const Text('Retry',
                      style: TextStyle(color: Colors.white)),
                ),
              ]),
            ),
          );
        }

        final settings = (state as SettingsLoaded).settings;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F3EE),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF5F3EE),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Color(0xFF2C2416), size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Settings',
                style: TextStyle(
                    color: Color(0xFF2C2416),
                    fontSize: 20,
                    fontWeight: FontWeight.w600)),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Profile Card ──────────────────────────────────────────
                _ProfileCard(
                  name: settings.userName ?? 'Your Name',
                  email: settings.userEmail ?? 'your@email.com',
                  imagePath: settings.profileImagePath,
                  onEdit: () => _showEditProfile(context, settings),
                ),
                const SizedBox(height: 28),

                // ── Preferences ───────────────────────────────────────────
                _sectionLabel('Preferences'),
                const SizedBox(height: 10),
                _card([
                  _switchTile(
                    icon: Icons.notifications_outlined,
                    iconColor: const Color(0xFF8B6914),
                    title: 'Notifications',
                    subtitle: 'Order updates & offers',
                    value: settings.notificationsEnabled,
                    onChanged: (_) => context
                        .read<SettingsBloc>()
                        .add(ToggleNotificationsEvent()),
                  ),
                ]),
                const SizedBox(height: 20),

                // ── Help & Support ────────────────────────────────────────
                _sectionLabel('Help & Support'),
                const SizedBox(height: 10),
                _card([
                  _navTile(
                    icon: Icons.help_outline_rounded,
                    iconColor: const Color(0xFF4A7C59),
                    title: 'Help Center',
                    subtitle: 'FAQs, tutorials & contact',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HelpPage())),
                  ),
                  _divider(),
                  _navTile(
                    icon: Icons.play_circle_outline_rounded,
                    iconColor: const Color(0xFF8B6914),
                    title: 'How to Use AR',
                    subtitle: 'Watch the step-by-step guide',
                    onTap: () => _showArSteps(context),
                  ),
                ]),
                const SizedBox(height: 20),

                // ── Legal ─────────────────────────────────────────────────
                _sectionLabel('Legal'),
                const SizedBox(height: 10),
                _card([
                  _navTile(
                    icon: Icons.policy_outlined,
                    iconColor: const Color(0xFF8B6914),
                    title: 'Our Policy',
                    subtitle: 'Privacy, returns & terms',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const PolicyPage())),
                  ),
                  _divider(),
                  _navTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: const Color(0xFF3D4A6B),
                    title: 'About the App',
                    subtitle: 'Version 1.0.0',
                    onTap: () => _showAbout(context),
                  ),
                ]),
                const SizedBox(height: 20),

                // ── Account ───────────────────────────────────────────────
                _sectionLabel('Account'),
                const SizedBox(height: 10),
                _card([
                  _navTile(
                    icon: Icons.delete_outline_rounded,
                    iconColor: Colors.red.shade400,
                    title: 'Clear AR Cache',
                    subtitle: 'Free up storage space',
                    onTap: () => _confirmClearCache(context),
                  ),
                  _divider(),
                  _navTile(
                    icon: Icons.logout_rounded,
                    iconColor: Colors.red.shade400,
                    title: 'Log Out',
                    subtitle: null,
                    onTap: () => _confirmLogout(context),
                    showChevron: false,
                  ),
                ]),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Edit Profile Sheet ───────────────────────────────────────────────────

  void _showEditProfile(BuildContext context, dynamic settings) {
    final usernameCtrl =
        TextEditingController(text: settings.userName ?? '');
    final bloc = context.read<SettingsBloc>();
    String? pickedImagePath = settings.profileImagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 20),
                const Text('Edit Profile',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C2416))),
                const SizedBox(height: 24),

                // ── صورة البروفايل ─────────────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                        maxWidth: 400,
                      );
                      if (picked != null) {
                        setSheetState(() => pickedImagePath = picked.path);
                      }
                    },
                    child: Stack(
                      children: [
                        // الصورة أو الأيقونة
                        Container(
                          width: 90, height: 90,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B6914),
                            borderRadius: BorderRadius.circular(22),
                            image: pickedImagePath != null
                                ? DecorationImage(
                                    image: FileImage(File(pickedImagePath!)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: pickedImagePath == null
                              ? const Icon(Icons.person,
                                  color: Colors.white, size: 42)
                              : null,
                        ),
                        // زر التعديل
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2416),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Tap to change photo',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ),
                ),
                const SizedBox(height: 22),

                // ── Username ───────────────────────────────────────────
                const Text('Username',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8B6914))),
                const SizedBox(height: 6),
                TextField(
                  controller: usernameCtrl,
                  decoration: InputDecoration(
                    hintText: 'Enter your username',
                    prefixIcon: const Icon(Icons.alternate_email,
                        color: Color(0xFF8B6914), size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF5F3EE),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFF8B6914), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Email (للعرض فقط) ──────────────────────────────────
                const Text('Email',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8B6914))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(children: [
                    Icon(Icons.email_outlined,
                        color: Colors.grey.shade400, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      settings.userEmail ?? 'your@email.com',
                      style: TextStyle(
                          fontSize: 15, color: Colors.grey.shade500),
                    ),
                    const Spacer(),
                    Icon(Icons.lock_outline,
                        color: Colors.grey.shade400, size: 16),
                  ]),
                ),
                const SizedBox(height: 6),
                Text('  Email cannot be changed',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade400)),
                const SizedBox(height: 24),

                // ── Save Button ────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (usernameCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter a username')),
                        );
                        return;
                      }
                      bloc.add(UpdateProfileEvent(
                        userName: usernameCtrl.text.trim(),
                        profileImagePath: pickedImagePath,
                      ));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              const Text('✓ Profile updated successfully'),
                          backgroundColor: const Color(0xFF4A7C59),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2416),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Save Changes',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Widget _sectionLabel(String t) => Text(t,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8B6914),
          letterSpacing: 0.8));

  Widget _divider() => const Padding(
      padding: EdgeInsets.only(left: 58),
      child: Divider(height: 1, color: Color(0xFFF5F3EE)));

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(children: children),
      );

  Widget _switchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2C2416))),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ]),
          ),
          CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF8B6914)),
        ]),
      );

  Widget _navTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool showChevron = true,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2C2416))),
                    if (subtitle != null)
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500)),
                  ]),
            ),
            if (showChevron)
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ]),
        ),
      );

  // ─── Dialogs ─────────────────────────────────────────────────────────────

  void _confirmClearCache(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Clear AR Cache?'),
        content: const Text(
            'This removes cached 3D models and temporary room data.'),
        actions: [
          CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context)),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Clear'),
            onPressed: () {
              Navigator.pop(context);
              context.read<SettingsBloc>().add(ClearCacheEvent());
            },
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Log Out?'),
        content: const Text('You will be returned to the sign-in screen.'),
        actions: [
          CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context)),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Log Out'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showArSteps(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        title: 'How to Use AR',
        icon: Icons.view_in_ar_outlined,
        iconColor: const Color(0xFF8B6914),
        child: Column(children: [
          _step('1', 'Open a product and tap "Try in Room"'),
          _step('2', 'Allow camera permission when prompted'),
          _step('3', 'Slowly scan your floor until dots appear'),
          _step('4', 'Tap on the surface to place the furniture'),
          _step('5', 'Pinch to resize — drag to move'),
          _step('6', 'Tap the camera icon to save a screenshot'),
        ]),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        title: 'About Furnit',
        icon: Icons.info_outline_rounded,
        iconColor: const Color(0xFF3D4A6B),
        child: Column(children: [
          const SizedBox(height: 8),
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
                color: const Color(0xFF2C2416),
                borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.chair_outlined, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 16),
          const Text('Furnit AR',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C2416))),
          const SizedBox(height: 4),
          Text('Version 1.0.0',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          Text(
            'Furnit helps you visualize furniture in your space using augmented reality.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, color: Colors.grey.shade600, height: 1.6),
          ),
        ]),
      ),
    );
  }

  Widget _step(String n, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
                color: const Color(0xFF8B6914),
                borderRadius: BorderRadius.circular(8)),
            child: Center(
                child: Text(n,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(text,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4)),
            ),
          ),
        ]),
      );
}

// ─── Profile Card Widget ──────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String? imagePath;
  final VoidCallback onEdit;

  const _ProfileCard({
    required this.name,
    required this.email,
    this.imagePath,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF2C2416),
          borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        // صورة البروفايل
        Container(
          width: 58, height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFF8B6914),
            borderRadius: BorderRadius.circular(16),
            image: imagePath != null
                ? DecorationImage(
                    image: FileImage(File(imagePath!)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: imagePath == null
              ? const Icon(Icons.person, color: Colors.white, size: 28)
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(email,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ]),
        ),
        GestureDetector(
          onTap: onEdit,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF8B6914).withOpacity(0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('Edit',
                style: TextStyle(
                    color: Color(0xFFE8B94A),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      ]),
    );
  }
}

// ─── Bottom Sheet Widget ──────────────────────────────────────────────────────

class _BottomSheet extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _BottomSheet(
      {required this.title,
      required this.icon,
      required this.iconColor,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.82),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C2416))),
            const Spacer(),
            IconButton(
                icon: Icon(Icons.close, size: 20, color: Colors.grey.shade400),
                onPressed: () => Navigator.pop(context)),
          ]),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: child,
          ),
        ),
      ]),
    );
  }
}