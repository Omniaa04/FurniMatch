// import 'dart:convert';
// import 'dart:io';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:model_viewer_plus/model_viewer_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:furnimatch/api_config.dart';
// import '../../domain/models/room_dimensions.dart';
// import 'room_name_screen.dart';
// import 'room_setup_screen.dart';
// // import 'package:furnimatch/features/RoomMeasurement/presentation/screen/my_rooms_screen.dart';

// const _kPrimary = Color(0xFFCF8D5B);
// const _kDark    = Color(0xFF7D533D);
// const _kMedium  = Color(0xFFA36846);
// const _kLight   = Color(0xFFF5D1A9);
// const _kBg      = Color(0xFFFDF6EE);

// enum FurnitureType {
//   sofa, armchair, bed, diningTable, desk,
//   wardrobe, tvStand, plant, lamp, coffeeTable, bookshelf, bathtub,
// }

// class FurnitureItem {
//   final String id, name, glbAsset, emoji;
//   final FurnitureType type;
//   final double widthM, depthM, heightM;
//   final Color tileColor;
//   final String? topImageAsset;
//   Offset position;
//   double rotationDeg;
//   bool isSelected;

//   FurnitureItem({
//     required this.id,
//     required this.name,
//     required this.glbAsset,
//     required this.emoji,
//     required this.type,
//     required this.widthM,
//     required this.depthM,
//     required this.heightM,
//     required this.tileColor,
//     required this.position,
//     this.topImageAsset,
//     this.rotationDeg = 0,
//     this.isSelected = false,
//   });

//   FurnitureItem copyWith(
//           {Offset? position, double? rotationDeg, bool? isSelected}) =>
//       FurnitureItem(
//         id: id, name: name, glbAsset: glbAsset, emoji: emoji, type: type,
//         widthM: widthM, depthM: depthM, heightM: heightM,
//         tileColor: tileColor, topImageAsset: topImageAsset,
//         position:    position    ?? this.position,
//         rotationDeg: rotationDeg ?? this.rotationDeg,
//         isSelected:  isSelected  ?? this.isSelected,
//       );

//   double get effectiveWidth =>
//       (rotationDeg == 90 || rotationDeg == 270) ? depthM : widthM;
//   double get effectiveDepth =>
//       (rotationDeg == 90 || rotationDeg == 270) ? widthM : depthM;
// }

// Offset _iso(double x, double y, double z, double s, Offset pan) => Offset(
//   (x - y) * 0.866025 * s + pan.dx,
//   (x + y) * 0.5 * s - z * s * 0.816 + pan.dy,
// );

// void _face(Canvas c, List<Offset> pts, Color fill, Color stroke, double sw) {
//   final path = Path()..moveTo(pts[0].dx, pts[0].dy);
//   for (final o in pts.skip(1)) path.lineTo(o.dx, o.dy);
//   path.close();
//   c.drawPath(path, Paint()..color = fill);
//   if (sw > 0) {
//     c.drawPath(path, Paint()
//       ..color = stroke
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = sw);
//   }
// }

// class _RoomPainter extends CustomPainter {
//   final double roomWidth, roomLength, roomHeight, scale;
//   final Offset pan;

//   _RoomPainter({
//     required this.roomWidth, required this.roomLength,
//     required this.roomHeight, required this.scale, required this.pan,
//   });

//   Offset p(double x, double y, double z) => _iso(x, y, z, scale, pan);

//   @override
//   void paint(Canvas c, Size size) {
//     final w = roomWidth, l = roomLength, h = roomHeight;
//     final e = _kDark.withValues(alpha: .22);

//     _face(c, [p(0,0,0),p(w,0,0),p(w,l,0),p(0,l,0)],
//         const Color(0xFFF5D1A9), e, .7);
//     _face(c, [p(0,0,0),p(0,l,0),p(0,l,h),p(0,0,h)],
//         const Color(0xFFEBA46E), e, .7);
//     _face(c, [p(0,0,0),p(w,0,0),p(w,0,h),p(0,0,h)],
//         const Color(0xFFCF8D5B), e, .7);

//     final cp = Path()
//       ..moveTo(p(0,0,h).dx,p(0,0,h).dy)
//       ..lineTo(p(w,0,h).dx,p(w,0,h).dy)
//       ..lineTo(p(w,l,h).dx,p(w,l,h).dy)
//       ..lineTo(p(0,l,h).dx,p(0,l,h).dy)
//       ..close();
//     c.drawPath(cp, Paint()
//       ..color = _kDark.withValues(alpha: .14)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = .8);

//     final gp = Paint()
//       ..color = _kDark.withValues(alpha: .09)
//       ..strokeWidth = .5;
//     for (double xi = 0; xi <= w; xi++) c.drawLine(p(xi,0,0),p(xi,l,0),gp);
//     for (double yi = 0; yi <= l; yi++) c.drawLine(p(0,yi,0),p(w,yi,0),gp);
//   }

//   @override
//   bool shouldRepaint(_) => true;
// }

// class _SelectionPainter extends CustomPainter {
//   final bool isSelected;
//   _SelectionPainter(this.isSelected);

//   @override
//   void paint(Canvas c, Size size) {
//     if (!isSelected) return;
//     final rr = RRect.fromRectAndRadius(
//       Rect.fromLTWH(0, 0, size.width, size.height),
//       const Radius.circular(10),
//     );
//     c.drawRRect(rr, Paint()
//       ..color = Colors.white.withValues(alpha: .92)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3.0);
//   }

//   @override
//   bool shouldRepaint(_SelectionPainter old) => old.isSelected != isSelected;
// }

// class _FurnitureTile extends StatefulWidget {
//   final FurnitureItem item;
//   final bool isSelected;
//   final VoidCallback onSelect;
//   final VoidCallback onDoubleTap;
//   final void Function(DragUpdateDetails) onDrag;

//   const _FurnitureTile({
//     required this.item,
//     required this.isSelected,
//     required this.onSelect,
//     required this.onDoubleTap,
//     required this.onDrag,
//   });

//   @override
//   State<_FurnitureTile> createState() => _FurnitureTileState();
// }

// class _FurnitureTileState extends State<_FurnitureTile> {
//   late String _cameraOrbit;

//   @override
//   void initState() {
//     super.initState();
//     _cameraOrbit = _orbitFor(widget.item.rotationDeg);
//   }

//   @override
//   void didUpdateWidget(_FurnitureTile old) {
//     super.didUpdateWidget(old);
//     if (old.item.rotationDeg != widget.item.rotationDeg) {
//       setState(() => _cameraOrbit = _orbitFor(widget.item.rotationDeg));
//     }
//   }

//   static String _orbitFor(double deg) {
//     final az = (45 + deg).toStringAsFixed(0);
//     return '${az}deg 55deg auto';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         ModelViewer(
//           key: ValueKey(
//               '${widget.item.id}_${widget.item.rotationDeg.toStringAsFixed(0)}'),
//           src: widget.item.glbAsset,
//           alt: widget.item.name,
//           ar: false,
//           autoRotate: false,
//           cameraControls: false,
//           backgroundColor: Colors.transparent,
//           shadowIntensity: 0.7,
//           exposure: 1.1,
//           cameraOrbit: _cameraOrbit,
//           fieldOfView: '28deg',
//         ),
//         CustomPaint(painter: _SelectionPainter(widget.isSelected)),
//         GestureDetector(
//           behavior: HitTestBehavior.opaque,
//           onTap: widget.onSelect,
//           onDoubleTap: widget.onDoubleTap,
//           onPanUpdate: widget.onDrag,
//           child: const SizedBox.expand(),
//         ),
//       ],
//     );
//   }
// }

// class _LazyModelCard extends StatefulWidget {
//   final FurnitureItem item;
//   final VoidCallback onTap;
//   const _LazyModelCard({required this.item, required this.onTap});
//   @override
//   State<_LazyModelCard> createState() => _LazyModelCardState();
// }

// class _LazyModelCardState extends State<_LazyModelCard> {
//   bool _showModel = false;
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         if (!_showModel) setState(() => _showModel = true);
//         else widget.onTap();
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: _kLight,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: _showModel ? _kPrimary : _kPrimary.withValues(alpha: .35),
//             width: _showModel ? 2 : 1,
//           ),
//         ),
//         child: Column(children: [
//           Expanded(
//             child: ClipRRect(
//               borderRadius:
//                   const BorderRadius.vertical(top: Radius.circular(13)),
//               child: _showModel
//                   ? ModelViewer(
//                       src: widget.item.glbAsset, alt: widget.item.name,
//                       ar: false, autoRotate: true, autoRotateDelay: 0,
//                       cameraControls: true, backgroundColor: _kBg,
//                       shadowIntensity: 0.8, exposure: 1.1,
//                     )
//                   : Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             widget.item.tileColor.withValues(alpha: .22),
//                             widget.item.tileColor.withValues(alpha: .08),
//                           ],
//                         ),
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(widget.item.emoji,
//                               style: const TextStyle(fontSize: 36)),
//                           const SizedBox(height: 6),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 3),
//                             decoration: BoxDecoration(
//                               color: _kPrimary.withValues(alpha: .15),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: const Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.touch_app,
//                                     size: 10, color: _kPrimary),
//                                 SizedBox(width: 3),
//                                 Text('Tap to preview',
//                                     style: TextStyle(
//                                         fontSize: 9,
//                                         color: _kPrimary,
//                                         fontWeight: FontWeight.bold)),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(6, 5, 6, 6),
//             child: Column(children: [
//               Text(widget.item.name,
//                   textAlign: TextAlign.center,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w700,
//                       color: _kDark)),
//               Text(
//                 _showModel
//                     ? 'Tap again to add →'
//                     : '${widget.item.widthM}×${widget.item.depthM}m',
//                 style: TextStyle(
//                     fontSize: 9,
//                     color: _showModel ? _kPrimary : _kMedium,
//                     fontWeight:
//                         _showModel ? FontWeight.bold : FontWeight.normal),
//               ),
//             ]),
//           ),
//         ]),
//       ),
//     );
//   }
// }

// class FurnitureModelViewer extends StatelessWidget {
//   final FurnitureItem item;
//   const FurnitureModelViewer({super.key, required this.item});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _kBg,
//       appBar: AppBar(
//         backgroundColor: _kDark,
//         title: Text(item.name,
//             style: const TextStyle(
//                 color: Colors.white, fontWeight: FontWeight.bold)),
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Done',
//                 style: TextStyle(
//                     color: _kLight,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16)),
//           ),
//         ],
//       ),
//       body: Column(children: [
//         Expanded(
//           child: ModelViewer(
//             src: item.glbAsset, alt: item.name,
//             ar: false, autoRotate: false, cameraControls: true,
//             backgroundColor: _kBg, shadowIntensity: 1.0,
//             shadowSoftness: 0.8, exposure: 1.2,
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.fromLTRB(20, 16, 20, 34),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(children: [
//             Container(
//                 width: 40, height: 4,
//                 decoration: BoxDecoration(
//                     color: const Color(0xFFDDD0C4),
//                     borderRadius: BorderRadius.circular(2))),
//             const SizedBox(height: 14),
//             Row(children: [
//               Container(
//                   width: 50, height: 50,
//                   decoration: BoxDecoration(
//                       color: _kLight,
//                       borderRadius: BorderRadius.circular(12)),
//                   child: Center(
//                       child: Text(item.emoji,
//                           style: const TextStyle(fontSize: 26)))),
//               const SizedBox(width: 14),
//               Expanded(
//                   child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                 Text(item.name,
//                     style: const TextStyle(
//                         color: _kDark,
//                         fontSize: 17,
//                         fontWeight: FontWeight.bold)),
//                 Text(
//                     '${item.widthM}m × ${item.depthM}m × ${item.heightM}m',
//                     style:
//                         const TextStyle(color: _kMedium, fontSize: 13)),
//               ])),
//             ]),
//             const SizedBox(height: 10),
//             const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//               Icon(Icons.touch_app, color: _kMedium, size: 14),
//               SizedBox(width: 4),
//               Text('Drag to rotate  •  Pinch to zoom',
//                   style: TextStyle(color: _kMedium, fontSize: 12)),
//             ]),
//           ]),
//         ),
//       ]),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Main screen
// // ─────────────────────────────────────────────────────────────────────────────
// class Room3DScreen extends StatefulWidget {
//   final double roomWidth, roomLength, roomHeight;
//   final String? referenceImagePath;
//   final List<Map<String, dynamic>> initialFurniture; // ✅ جديد

//   const Room3DScreen({
//     super.key,
//     required this.roomWidth,
//     required this.roomLength,
//     required this.roomHeight,
//     this.referenceImagePath,
//     this.initialFurniture = const [], // ✅ جديد
//   });

//   @override
//   State<Room3DScreen> createState() => _Room3DScreenState();
// }

// class _Room3DScreenState extends State<Room3DScreen> {
//   double _scale = 80.0;
//   Offset _panOffset = const Offset(220, 160);
//   double _roomRotation = 0.0;
//   String? _selectedId;
//   final List<FurnitureItem> _furniture = [];
//   Size _screenSize = Size.zero;
//   bool _isSaving = false;
//   bool _isLoading = false;
//   static const _baseUrl = ApiConfig.baseUrl;

//   static final List<FurnitureItem> _catalog = [
//     FurnitureItem(id:'sofa',name:'Sofa',emoji:'🛋',type:FurnitureType.sofa,
//         glbAsset:'assets/models/sofa.glb',widthM:2.10,depthM:0.95,heightM:0.82,
//         tileColor:const Color(0xFF8B6B4A),position:Offset.zero),
//     FurnitureItem(id:'armchair',name:'Armchair',emoji:'💺',type:FurnitureType.armchair,
//         glbAsset:'assets/models/armchair.glb',widthM:0.85,depthM:0.85,heightM:0.82,
//         tileColor:const Color(0xFFA0724E),position:Offset.zero),
//     FurnitureItem(id:'bed',name:'Double Bed',emoji:'🛏',type:FurnitureType.bed,
//         glbAsset:'assets/models/bed.glb',widthM:1.60,depthM:2.10,heightM:0.80,
//         tileColor:const Color(0xFF7D533D),position:Offset.zero),
//     FurnitureItem(id:'dtable',name:'Dining Table',emoji:'🍽',type:FurnitureType.diningTable,
//         glbAsset:'assets/models/dining_table.glb',widthM:1.40,depthM:0.85,heightM:0.76,
//         tileColor:const Color(0xFFB8845A),position:Offset.zero),
//     FurnitureItem(id:'desk',name:'Desk',emoji:'🖥',type:FurnitureType.desk,
//         glbAsset:'assets/models/desk.glb',widthM:1.40,depthM:0.65,heightM:0.76,
//         tileColor:const Color(0xFFB8845A),position:Offset.zero),
//     FurnitureItem(id:'ctable',name:'Coffee Table',emoji:'☕',type:FurnitureType.coffeeTable,
//         glbAsset:'assets/models/coffee_table.glb',widthM:1.10,depthM:0.60,heightM:0.42,
//         tileColor:const Color(0xFFB8845A),position:Offset.zero),
//     FurnitureItem(id:'wardrobe',name:'Wardrobe',emoji:'🚪',type:FurnitureType.wardrobe,
//         glbAsset:'assets/models/wardrobe.glb',widthM:1.20,depthM:0.60,heightM:2.10,
//         tileColor:const Color(0xFF9B6B45),position:Offset.zero),
//     FurnitureItem(id:'tvstand',name:'TV Stand',emoji:'📺',type:FurnitureType.tvStand,
//         glbAsset:'assets/models/tv_stand.glb',widthM:1.60,depthM:0.45,heightM:0.50,
//         tileColor:const Color(0xFF7A5535),position:Offset.zero),
//     FurnitureItem(id:'shelf',name:'Bookshelf',emoji:'📚',type:FurnitureType.bookshelf,
//         glbAsset:'assets/models/bookshelf.glb',widthM:0.90,depthM:0.35,heightM:1.80,
//         tileColor:const Color(0xFF9B6B45),position:Offset.zero),
//     FurnitureItem(id:'plant',name:'Plant',emoji:'🌿',type:FurnitureType.plant,
//         glbAsset:'assets/models/plant.glb',widthM:0.45,depthM:0.45,heightM:1.10,
//         tileColor:const Color(0xFF4A7C40),position:Offset.zero),
//     FurnitureItem(id:'lamp',name:'Floor Lamp',emoji:'💡',type:FurnitureType.lamp,
//         glbAsset:'assets/models/lamp.glb',widthM:0.40,depthM:0.40,heightM:1.65,
//         tileColor:const Color(0xFFCCBB88),position:Offset.zero),
//     FurnitureItem(id:'bathtub',name:'Bathtub',emoji:'🛁',type:FurnitureType.bathtub,
//         glbAsset:'assets/models/bathtub.glb',widthM:0.80,depthM:1.70,heightM:0.56,
//         tileColor:const Color(0xFFB0C8D4),position:Offset.zero),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     // ✅ لو فيه furniture محفوظة، حمّليها بعد ما الـ widget يتبني
//     if (widget.initialFurniture.isNotEmpty) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _loadRoomData({'furniture': widget.initialFurniture});
//       });
//     }
//   }

//   void _autoFit(Size size) {
//     final w = widget.roomWidth, l = widget.roomLength;
//     final isoW = (w + l) * 0.866025;
//     final isoH = (w + l) * 0.5 + widget.roomHeight * 0.816;
//     final availW = size.width  - 80;
//     final availH = size.height - 220;
//     final scaleW = availW / isoW;
//     final scaleH = availH / isoH;
//     _scale = (scaleW < scaleH ? scaleW : scaleH).clamp(20.0, 180.0);
//     _recenter();
//   }

//   void _recenter() {
//     final w = widget.roomWidth, l = widget.roomLength;
//     final screenW = _screenSize == Size.zero ? 400.0 : _screenSize.width;
//     final screenH = _screenSize == Size.zero ? 700.0 : _screenSize.height;
//     final isoW = (w + l) * 0.866025 * _scale;
//     final isoH = (w + l) * 0.5      * _scale;
//     _panOffset = Offset(
//       (screenW - isoW) / 2 + l * 0.866025 * _scale,
//       (screenH - 200 - isoH) / 2 + 60,
//     );
//   }

//   Offset? _toFloor(Offset s) {
//     final dx = s.dx - _panOffset.dx, dy = s.dy - _panOffset.dy;
//     final x = (dx / .866025 + dy / .5) / (2 * _scale);
//     final y = (dy / .5 - dx / .866025) / (2 * _scale);
//     if (x >= 0 && x <= widget.roomWidth &&
//         y >= 0 && y <= widget.roomLength) return Offset(x, y);
//     return null;
//   }

//   Offset _furnitureScreenCenter(FurnitureItem f) {
//     final fx = f.position.dx + f.effectiveWidth / 2;
//     final fy = f.position.dy + f.effectiveDepth / 2;
//     final fz = f.heightM / 2;
//     return _iso(fx, fy, fz, _scale, _panOffset);
//   }

//   double _furniturePxW(FurnitureItem f) =>
//       f.effectiveWidth * _scale * 1.8 + f.heightM * _scale * 0.6;

//   double _furniturePxH(FurnitureItem f) =>
//       f.effectiveDepth * _scale * 1.2 + f.heightM * _scale * 1.0;

//   void _onRoomTap(TapUpDetails d) {
//     final fp = _toFloor(d.localPosition);
//     if (fp == null) { setState(() => _selectedId = null); return; }
//     setState(() => _selectedId = null);
//   }

//   void _onFurnitureDrag(String id, DragUpdateDetails d) {
//     final idx = _furniture.indexWhere((f) => f.id == id);
//     if (idx < 0) return;
//     final f = _furniture[idx];
//     final mx = (d.delta.dx / .866025 + d.delta.dy / .5) / (2 * _scale);
//     final my = (d.delta.dy / .5 - d.delta.dx / .866025) / (2 * _scale);
//     final newPos = Offset(
//       (f.position.dx + mx).clamp(0, widget.roomWidth  - f.effectiveWidth),
//       (f.position.dy + my).clamp(0, widget.roomLength - f.effectiveDepth),
//     );
//     final moved = f.copyWith(position: newPos);
//     if (!_overlaps(moved, _furniture)) setState(() => _furniture[idx] = moved);
//   }

//   void _rotate(double deg) {
//     if (_selectedId == null) return;
//     final idx = _furniture.indexWhere((f) => f.id == _selectedId);
//     if (idx < 0) return;
//     final f = _furniture[idx];
//     final raw     = (f.rotationDeg + deg) % 360;
//     final snapped = ((raw / 90).round() * 90) % 360;
//     final nr      = (snapped < 0 ? snapped + 360 : snapped).toDouble();
//     final nw = (nr == 90 || nr == 270) ? f.depthM : f.widthM;
//     final nd = (nr == 90 || nr == 270) ? f.widthM : f.depthM;
//     final newPos = Offset(
//       f.position.dx.clamp(0, widget.roomWidth  - nw),
//       f.position.dy.clamp(0, widget.roomLength - nd),
//     );
//     setState(
//         () => _furniture[idx] = f.copyWith(rotationDeg: nr, position: newPos));
//   }

//   void _delete() {
//     setState(() {
//       _furniture.removeWhere((f) => f.id == _selectedId);
//       _selectedId = null;
//     });
//   }

//   void _resize(double factor) {
//     if (_selectedId == null) return;
//     final idx = _furniture.indexWhere((f) => f.id == _selectedId);
//     if (idx < 0) return;
//     final f = _furniture[idx];
//     final newW =
//         (f.widthM * factor).clamp(0.20, widget.roomWidth  - f.position.dx);
//     final newD =
//         (f.depthM * factor).clamp(0.20, widget.roomLength - f.position.dy);
//     setState(() {
//       _furniture[idx] = FurnitureItem(
//         id: f.id, name: f.name, glbAsset: f.glbAsset,
//         emoji: f.emoji, type: f.type,
//         widthM: newW, depthM: newD,
//         heightM: (f.heightM * factor).clamp(0.10, 4.0),
//         tileColor: f.tileColor, position: f.position,
//         topImageAsset: f.topImageAsset,
//         rotationDeg: f.rotationDeg, isSelected: f.isSelected,
//       );
//     });
//   }

//   bool _overlaps(FurnitureItem a, List<FurnitureItem> others) {
//     const gap = 0.05;
//     for (final b in others) {
//       if (b.id == a.id) continue;
//       final ax1=a.position.dx, ax2=a.position.dx+a.effectiveWidth;
//       final ay1=a.position.dy, ay2=a.position.dy+a.effectiveDepth;
//       final bx1=b.position.dx-gap, bx2=b.position.dx+b.effectiveWidth+gap;
//       final by1=b.position.dy-gap, by2=b.position.dy+b.effectiveDepth+gap;
//       if (ax1<bx2&&ax2>bx1&&ay1<by2&&ay2>by1) return true;
//     }
//     return false;
//   }

//   void _addFurniture(FurnitureItem cat) {
//     final count = _furniture.where((f) => f.id.startsWith(cat.id)).length;
//     final newId = '${cat.id}_$count';
//     Offset freePos = Offset(
//       ((widget.roomWidth  - cat.widthM) / 2).clamp(0, widget.roomWidth  - cat.widthM),
//       ((widget.roomLength - cat.depthM) / 2).clamp(0, widget.roomLength - cat.depthM),
//     );
//     outer:
//     for (double ty = 0; ty <= widget.roomLength - cat.depthM; ty += 0.3) {
//       for (double tx = 0; tx <= widget.roomWidth  - cat.widthM; tx += 0.3) {
//         final candidate = FurnitureItem(
//           id: newId, name: cat.name, glbAsset: cat.glbAsset,
//           emoji: cat.emoji, type: cat.type,
//           widthM: cat.widthM, depthM: cat.depthM, heightM: cat.heightM,
//           tileColor: cat.tileColor, position: Offset(tx, ty),
//         );
//         if (!_overlaps(candidate, _furniture)) {
//           freePos = Offset(tx, ty);
//           break outer;
//         }
//       }
//     }
//     setState(() {
//       _furniture.add(FurnitureItem(
//         id: newId, name: cat.name, glbAsset: cat.glbAsset,
//         emoji: cat.emoji, type: cat.type,
//         widthM: cat.widthM, depthM: cat.depthM, heightM: cat.heightM,
//         tileColor: cat.tileColor, topImageAsset: cat.topImageAsset,
//         position: freePos,
//       ));
//       _selectedId = newId;
//     });
//     Navigator.pop(context);
//   }

//   // ✅ Save → RoomNameScreen → بعد الحفظ MyRoomsScreen فوق MainShell
//   void _showSaveDialog() {
//     if (_furniture.isEmpty) {
//       _snack('Add some furniture first!', isError: true);
//       return;
//     }

//     final dims = RoomDimensions(
//       width: widget.roomWidth,
//       length: widget.roomLength,
//       height: widget.roomHeight,
//       measuredAt: DateTime.now(),
//     );

//     final furnitureJson = _furniture.map((f) => {
//       'id': f.id,
//       'name': f.name,
//       'type': f.type.name,
//       'x': f.position.dx,
//       'y': f.position.dy,
//       'rotation': f.rotationDeg,
//       'widthM': f.widthM,
//       'depthM': f.depthM,
//       'heightM': f.heightM,
//     }).toList();

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => RoomNameScreen(
//           dimensions: dims,
//           furniture: furnitureJson,
//         ),
//       ),
//     );
//   }

//   Future<void> _showSavedRooms() async {
//     setState(() => _isLoading = true);
//     List<dynamic> rooms = [];
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getInt('user_id');
//       if (userId == null) {
//         _snack('❌ Please login first', isError: true);
//         setState(() => _isLoading = false);
//         return;
//       }
//       final res = await http.get(
//         Uri.parse('$_baseUrl/rooms/list?user_id=$userId'),
//         headers: {'ngrok-skip-browser-warning': 'true'},
//       );
//       if (res.statusCode == 200) rooms = jsonDecode(res.body) as List;
//     } catch (_) {}
//     if (mounted) setState(() => _isLoading = false);
//     if (!mounted) return;

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (_) => Container(
//         height: MediaQuery.of(context).size.height * 0.7,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
//         ),
//         child: Column(children: [
//           const SizedBox(height: 12),
//           Container(
//               width: 40, height: 4,
//               decoration: BoxDecoration(
//                   color: const Color(0xFFDDD0C4),
//                   borderRadius: BorderRadius.circular(2))),
//           const SizedBox(height: 12),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Row(children: [
//               const Text('My Rooms',
//                   style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: _kDark)),
//               const Spacer(),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.push(context, MaterialPageRoute(
//                       builder: (_) => const RoomSetupScreen()));
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 14, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: _kPrimary,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Row(mainAxisSize: MainAxisSize.min, children: [
//                     Icon(Icons.add, color: Colors.white, size: 16),
//                     SizedBox(width: 4),
//                     Text('New Room',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 13)),
//                   ]),
//                 ),
//               ),
//             ]),
//           ),
//           const SizedBox(height: 8),
//           Expanded(
//             child: rooms.isEmpty
//                 ? Center(
//                     child: Column(mainAxisSize: MainAxisSize.min, children: [
//                     const Icon(Icons.inbox_outlined,
//                         size: 52, color: _kMedium),
//                     const SizedBox(height: 8),
//                     const Text('No saved rooms yet',
//                         style: TextStyle(color: _kMedium)),
//                     const SizedBox(height: 16),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pop(context);
//                         Navigator.push(context, MaterialPageRoute(
//                             builder: (_) => const RoomSetupScreen()));
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 10),
//                         decoration: BoxDecoration(
//                           color: _kPrimary,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const Text('+ Add your first room',
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold)),
//                       ),
//                     ),
//                   ]))
//                 : ListView.builder(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 16, vertical: 4),
//                     itemCount: rooms.length,
//                     itemBuilder: (_, i) {
//                       final r = rooms[i] as Map<String, dynamic>;
//                       final furnitureList = (r['furniture'] as List?) ?? [];
//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 10),
//                         padding: const EdgeInsets.all(14),
//                         decoration: BoxDecoration(
//                           color: _kLight,
//                           borderRadius: BorderRadius.circular(14),
//                           border: Border.all(
//                               color: _kPrimary.withValues(alpha: .3)),
//                         ),
//                         child: Row(children: [
//                           Container(
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: _kPrimary.withValues(alpha: .15),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: const Icon(Icons.meeting_room_outlined,
//                                 color: _kDark, size: 22),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                               child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(r['name'] ?? 'Room',
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: _kDark,
//                                       fontSize: 14)),
//                               Text(
//                                   '${(r['width'] as num).toStringAsFixed(1)}m × '
//                                   '${(r['length'] as num).toStringAsFixed(1)}m × '
//                                   '${(r['height'] as num).toStringAsFixed(1)}m',
//                                   style: const TextStyle(
//                                       color: _kMedium, fontSize: 12)),
//                               Text(
//                                   '${furnitureList.length} furniture item(s)',
//                                   style: const TextStyle(
//                                       color: _kPrimary, fontSize: 11)),
//                             ],
//                           )),
//                           Row(mainAxisSize: MainAxisSize.min, children: [
//                             IconButton(
//                               icon: const Icon(Icons.download_outlined,
//                                   color: _kPrimary, size: 20),
//                               tooltip: 'Load this room',
//                               onPressed: () {
//                                 Navigator.pop(context);
//                                 _loadRoomData(r);
//                               },
//                             ),
//                             IconButton(
//                               icon: Icon(Icons.delete_outline,
//                                   color: Colors.red[400], size: 20),
//                               tooltip: 'Delete',
//                               onPressed: () async {
//                                 final id = r['id'] as int;
//                                 try {
//                                   await http.delete(
//                                     Uri.parse('$_baseUrl/rooms/$id'),
//                                     headers: {
//                                       'ngrok-skip-browser-warning': 'true'
//                                     },
//                                   );
//                                 } catch (_) {}
//                                 if (context.mounted) Navigator.pop(context);
//                                 _showSavedRooms();
//                               },
//                             ),
//                           ]),
//                         ]),
//                       );
//                     }),
//           ),
//           const SizedBox(height: 16),
//         ]),
//       ),
//     );
//   }

//   // ✅ بتحمّل الـ furniture من الـ API data
//   void _loadRoomData(Map<String, dynamic> r) {
//     final furnitureList = (r['furniture'] as List?) ?? [];
//     setState(() {
//       _furniture.clear();
//       _selectedId = null;
//       for (final item in furnitureList) {
//         final m = item as Map<String, dynamic>;
//         final typeName = m['type'] as String? ?? 'sofa';
//         final cat = _catalog.firstWhere(
//             (c) => c.type.name == typeName,
//             orElse: () => _catalog.first);
//         _furniture.add(FurnitureItem(
//           id: m['id'] as String? ?? '${typeName}_0',
//           name: m['name'] as String? ?? cat.name,
//           glbAsset: cat.glbAsset,
//           emoji: cat.emoji,
//           type: cat.type,
//           widthM: (m['widthM'] as num?)?.toDouble() ?? cat.widthM,
//           depthM: (m['depthM'] as num?)?.toDouble() ?? cat.depthM,
//           heightM: (m['heightM'] as num?)?.toDouble() ?? cat.heightM,
//           tileColor: cat.tileColor,
//           position: Offset(
//               (m['x'] as num).toDouble(),
//               (m['y'] as num).toDouble()),
//           rotationDeg: (m['rotation'] as num).toDouble(),
//         ));
//       }
//     });
//   }

//   void _snack(String msg, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(msg),
//       backgroundColor: isError ? Colors.red[700] : _kDark,
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//     ));
//   }

//   void _showPicker() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (_) => Container(
//         height: MediaQuery.of(context).size.height * 0.65,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
//         ),
//         child: Column(children: [
//           const SizedBox(height: 12),
//           Container(
//               width: 40, height: 4,
//               decoration: BoxDecoration(
//                   color: const Color(0xFFDDD0C4),
//                   borderRadius: BorderRadius.circular(2))),
//           const SizedBox(height: 12),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20),
//             child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text('Add Furniture',
//                     style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: _kDark))),
//           ),
//           const SizedBox(height: 10),
//           Expanded(
//             child: GridView.builder(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
//               gridDelegate:
//                   const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//                 childAspectRatio: 0.82,
//               ),
//               itemCount: _catalog.length,
//               itemBuilder: (_, i) => _LazyModelCard(
//                   item: _catalog[i],
//                   onTap: () => _addFurniture(_catalog[i])),
//             ),
//           ),
//           const SizedBox(height: 16),
//         ]),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final sel = _selectedId != null
//         ? _furniture.firstWhere((f) => f.id == _selectedId,
//             orElse: () => _furniture.first)
//         : null;

//     final sortedFurniture = [..._furniture]
//       ..sort((a, b) => (b.position.dx + b.position.dy)
//           .compareTo(a.position.dx + a.position.dy));

//     return Scaffold(
//       backgroundColor: _kBg,
//       appBar: AppBar(
//         backgroundColor: _kDark,
//         title: Text(
//           '${widget.roomWidth.toStringAsFixed(1)}m × '
//           '${widget.roomLength.toStringAsFixed(1)}m Room',
//           style: const TextStyle(
//               color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: _isLoading
//                 ? const SizedBox(
//                     width: 18, height: 18,
//                     child: CircularProgressIndicator(
//                         color: Colors.white, strokeWidth: 2))
//                 : const Icon(Icons.folder_open, color: Colors.white),
//             tooltip: 'My Rooms',
//             onPressed: _showSavedRooms,
//           ),
//           IconButton(
//             icon: _isSaving
//                 ? const SizedBox(
//                     width: 18, height: 18,
//                     child: CircularProgressIndicator(
//                         color: Colors.white, strokeWidth: 2))
//                 : const Icon(Icons.save, color: Colors.white),
//             tooltip: 'Save room',
//             onPressed: _showSaveDialog,
//           ),
//         ],
//       ),
//       body: LayoutBuilder(builder: (context, constraints) {
//         if (_screenSize == Size.zero) {
//           _screenSize = Size(constraints.maxWidth, constraints.maxHeight);
//           _autoFit(_screenSize);
//         }
//         return Stack(children: [
//           GestureDetector(
//             onTapUp: _onRoomTap,
//             onPanUpdate: _selectedId == null
//                 ? (d) => setState(() => _panOffset += d.delta)
//                 : null,
//             child: Transform.rotate(
//               angle: _roomRotation * math.pi / 180,
//               child: CustomPaint(
//                 painter: _RoomPainter(
//                   roomWidth: widget.roomWidth,
//                   roomLength: widget.roomLength,
//                   roomHeight: widget.roomHeight,
//                   scale: _scale,
//                   pan: _panOffset,
//                 ),
//                 child: Container(color: Colors.transparent),
//               ),
//             ),
//           ),

//           ...sortedFurniture.map((f) {
//             final center = _furnitureScreenCenter(f);
//             final pxW = _furniturePxW(f);
//             final pxH = _furniturePxH(f);
//             final isSelected = f.id == _selectedId;
//             return Positioned(
//               left: center.dx - pxW / 2,
//               top:  center.dy - pxH / 2,
//               width: pxW, height: pxH,
//               child: _FurnitureTile(
//                 item: f, isSelected: isSelected,
//                 onSelect: () => setState(() => _selectedId = f.id),
//                 onDoubleTap: () {
//                   setState(() => _selectedId = f.id);
//                   Navigator.push(context, MaterialPageRoute(
//                       builder: (_) => FurnitureModelViewer(item: f)));
//                 },
//                 onDrag: (d) {
//                   if (!isSelected) setState(() => _selectedId = f.id);
//                   _onFurnitureDrag(f.id, d);
//                 },
//               ),
//             );
//           }),

//           if (widget.referenceImagePath != null)
//             Positioned(
//                 left: 14, top: 14,
//                 child: GestureDetector(
//                   onTap: () => showDialog(
//                       context: context,
//                       builder: (_) => Dialog(
//                           backgroundColor: Colors.transparent,
//                           child: ClipRRect(
//                               borderRadius: BorderRadius.circular(16),
//                               child: Image.file(
//                                   File(widget.referenceImagePath!),
//                                   fit: BoxFit.contain)))),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: _kPrimary, width: 2),
//                       boxShadow: [
//                         BoxShadow(
//                             color: Colors.black.withValues(alpha: .2),
//                             blurRadius: 6)
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.file(File(widget.referenceImagePath!),
//                           width: 58, height: 58, fit: BoxFit.cover),
//                     ),
//                   ),
//                 )),

//           Positioned(
//             right: 14, top: 14,
//             child: Column(children: [
//               _iconBtn(Icons.add,
//                   () => setState(
//                       () => _scale = (_scale * 1.15).clamp(30, 240))),
//               const SizedBox(height: 8),
//               _iconBtn(Icons.remove,
//                   () => setState(
//                       () => _scale = (_scale / 1.15).clamp(30, 240))),
//               const SizedBox(height: 8),
//               _iconBtn(Icons.center_focus_strong,
//                   () => setState(() => _autoFit(_screenSize))),
//             ]),
//           ),

//           if (sel != null)
//             Positioned(
//                 top: 14, left: 0, right: 0,
//                 child: Center(
//                     child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 14, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: _kDark.withValues(alpha: .82),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Text('Double-tap → full 3D view',
//                       style:
//                           TextStyle(color: Colors.white, fontSize: 11)),
//                 ))),

//           if (sel != null)
//             Positioned(
//                 left: 0, right: 0, bottom: 112,
//                 child: Center(
//                     child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 8, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: _kDark.withValues(alpha: .93),
//                     borderRadius: BorderRadius.circular(50),
//                     boxShadow: [
//                       BoxShadow(
//                           color: Colors.black.withValues(alpha: .22),
//                           blurRadius: 12)
//                     ],
//                   ),
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     physics: const NeverScrollableScrollPhysics(),
//                     child: Row(mainAxisSize: MainAxisSize.min, children: [
//                       _rotBtn(Icons.rotate_left, '90°',
//                           () => _rotate(-90)),
//                       const SizedBox(width: 2),
//                       _rotBtn(Icons.rotate_left, '45°',
//                           () => _rotate(-45),
//                           small: true),
//                       const SizedBox(width: 4),
//                       _toolBtn(Icons.zoom_out, () => _resize(0.85)),
//                       const SizedBox(width: 2),
//                       _toolBtn(Icons.zoom_in, () => _resize(1.15)),
//                       const SizedBox(width: 4),
//                       GestureDetector(
//                         onTap: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) =>
//                                     FurnitureModelViewer(item: sel))),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 10, vertical: 10),
//                           decoration: BoxDecoration(
//                               color: _kPrimary,
//                               borderRadius: BorderRadius.circular(30)),
//                           child: const Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.view_in_ar,
//                                     color: Colors.white, size: 16),
//                                 SizedBox(width: 4),
//                                 Text('3D',
//                                     style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 13)),
//                               ]),
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       _rotBtn(Icons.rotate_right, '45°',
//                           () => _rotate(45),
//                           small: true),
//                       const SizedBox(width: 2),
//                       _rotBtn(
//                           Icons.rotate_right, '90°', () => _rotate(90)),
//                     ]),
//                   ),
//                 ))),

//           Positioned(
//               bottom: 0, left: 0, right: 0,
//               child: Container(
//                 padding:
//                     const EdgeInsets.fromLTRB(20, 14, 20, 28),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: const BorderRadius.vertical(
//                       top: Radius.circular(20)),
//                   boxShadow: [
//                     BoxShadow(
//                         color: Colors.black.withValues(alpha: .07),
//                         blurRadius: 12)
//                   ],
//                 ),
//                 child: sel != null
//                     ? Row(children: [
//                         Text(sel.emoji,
//                             style: const TextStyle(fontSize: 26)),
//                         const SizedBox(width: 12),
//                         Expanded(
//                             child: Column(
//                                 crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                               Text(sel.name,
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: _kDark,
//                                       fontSize: 15)),
//                               Text(
//                                 '${sel.rotationDeg.toInt()}°  •  '
//                                 '${sel.effectiveWidth.toStringAsFixed(1)}×'
//                                 '${sel.effectiveDepth.toStringAsFixed(1)}m',
//                                 style: const TextStyle(
//                                     fontSize: 11, color: _kMedium),
//                               ),
//                             ])),
//                         GestureDetector(
//                           onTap: _delete,
//                           child: Container(
//                               padding: const EdgeInsets.all(9),
//                               decoration: BoxDecoration(
//                                   color:
//                                       Colors.red.withValues(alpha: .10),
//                                   borderRadius:
//                                       BorderRadius.circular(10)),
//                               child: const Icon(Icons.delete_outline,
//                                   color: Colors.red, size: 20)),
//                         ),
//                       ])
//                     : Row(children: [
//                         const Icon(Icons.touch_app_outlined,
//                             color: _kMedium, size: 18),
//                         const SizedBox(width: 8),
//                         Expanded(
//                             child: Text(
//                           _furniture.isEmpty
//                               ? 'Tap "Add Furniture" to start'
//                               : 'Tap → select  •  Drag → move  •  Double-tap → 3D',
//                           style: const TextStyle(
//                               color: _kMedium, fontSize: 13),
//                         )),
//                         ElevatedButton.icon(
//                           onPressed: _showPicker,
//                           icon: const Icon(Icons.add,
//                               size: 15, color: Colors.white),
//                           label: const Text('Add Furniture',
//                               style: TextStyle(color: Colors.white)),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: _kPrimary,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10)),
//                           ),
//                         ),
//                       ]),
//               )),
//         ]);
//       }),
//     );
//   }

//   Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
//         onTap: onTap,
//         child: Container(
//           width: 40, height: 40,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//             boxShadow: [
//               BoxShadow(
//                   color: Colors.black.withValues(alpha: .10),
//                   blurRadius: 4)
//             ],
//           ),
//           child: Icon(icon, color: _kDark, size: 20),
//         ),
//       );

//   Widget _toolBtn(IconData icon, VoidCallback onTap) => GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.white.withValues(alpha: .15),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Icon(icon, color: Colors.white, size: 20),
//         ),
//       );

//   Widget _rotBtn(IconData icon, String label, VoidCallback onTap,
//           {bool small = false}) =>
//       GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: EdgeInsets.symmetric(
//               horizontal: small ? 8 : 12, vertical: small ? 6 : 8),
//           decoration: BoxDecoration(
//             color: Colors.white.withValues(alpha: .12),
//             borderRadius: BorderRadius.circular(30),
//           ),
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             Icon(icon, color: Colors.white, size: small ? 16 : 20),
//             Text(label,
//                 style: TextStyle(
//                     color: Colors.white70,
//                     fontSize: small ? 8 : 9)),
//           ]),
//         ),
//       );
// }
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:furnimatch/api_config.dart';
import 'package:furnimatch/providers/cart_provider.dart';
import '../../domain/models/room_dimensions.dart';
import 'room_name_screen.dart';
import 'room_setup_screen.dart';

const _kPrimary = Color(0xFFCF8D5B);
const _kDark    = Color(0xFF7D533D);
const _kMedium  = Color(0xFFA36846);
const _kLight   = Color(0xFFF5D1A9);
const _kBg      = Color(0xFFFDF6EE);

enum FurnitureType {
  sofa, armchair, bed, diningTable, desk,
  wardrobe, tvStand, plant, lamp, coffeeTable, bookshelf, bathtub,
}

class FurnitureItem {
  final String id, name, glbAsset, emoji;
  final FurnitureType type;
  final double widthM, depthM, heightM;
  final Color tileColor;
  final String? topImageAsset;
  final int? productId; // ← جديد
  Offset position;
  double rotationDeg;
  bool isSelected;

  FurnitureItem({
    required this.id,
    required this.name,
    required this.glbAsset,
    required this.emoji,
    required this.type,
    required this.widthM,
    required this.depthM,
    required this.heightM,
    required this.tileColor,
    required this.position,
    this.topImageAsset,
    this.productId, // ← جديد
    this.rotationDeg = 0,
    this.isSelected = false,
  });

  FurnitureItem copyWith(
          {Offset? position, double? rotationDeg, bool? isSelected}) =>
      FurnitureItem(
        id: id, name: name, glbAsset: glbAsset, emoji: emoji, type: type,
        widthM: widthM, depthM: depthM, heightM: heightM,
        tileColor: tileColor, topImageAsset: topImageAsset,
        productId: productId,
        position:    position    ?? this.position,
        rotationDeg: rotationDeg ?? this.rotationDeg,
        isSelected:  isSelected  ?? this.isSelected,
      );

  double get effectiveWidth =>
      (rotationDeg == 90 || rotationDeg == 270) ? depthM : widthM;
  double get effectiveDepth =>
      (rotationDeg == 90 || rotationDeg == 270) ? widthM : depthM;
}

Offset _iso(double x, double y, double z, double s, Offset pan) => Offset(
  (x - y) * 0.866025 * s + pan.dx,
  (x + y) * 0.5 * s - z * s * 0.816 + pan.dy,
);

void _face(Canvas c, List<Offset> pts, Color fill, Color stroke, double sw) {
  final path = Path()..moveTo(pts[0].dx, pts[0].dy);
  for (final o in pts.skip(1)) {
    path.lineTo(o.dx, o.dy);
  }
  path.close();
  c.drawPath(path, Paint()..color = fill);
  if (sw > 0) {
    c.drawPath(path, Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw);
  }
}

class _RoomPainter extends CustomPainter {
  final double roomWidth, roomLength, roomHeight, scale;
  final Offset pan;

  _RoomPainter({
    required this.roomWidth, required this.roomLength,
    required this.roomHeight, required this.scale, required this.pan,
  });

  Offset p(double x, double y, double z) => _iso(x, y, z, scale, pan);

  @override
  void paint(Canvas c, Size size) {
    final w = roomWidth, l = roomLength, h = roomHeight;
    final e = _kDark.withValues(alpha: .22);

    _face(c, [p(0,0,0),p(w,0,0),p(w,l,0),p(0,l,0)],
        const Color(0xFFF5D1A9), e, .7);
    _face(c, [p(0,0,0),p(0,l,0),p(0,l,h),p(0,0,h)],
        const Color(0xFFEBA46E), e, .7);
    _face(c, [p(0,0,0),p(w,0,0),p(w,0,h),p(0,0,h)],
        const Color(0xFFCF8D5B), e, .7);

    final cp = Path()
      ..moveTo(p(0,0,h).dx,p(0,0,h).dy)
      ..lineTo(p(w,0,h).dx,p(w,0,h).dy)
      ..lineTo(p(w,l,h).dx,p(w,l,h).dy)
      ..lineTo(p(0,l,h).dx,p(0,l,h).dy)
      ..close();
    c.drawPath(cp, Paint()
      ..color = _kDark.withValues(alpha: .14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8);

    final gp = Paint()
      ..color = _kDark.withValues(alpha: .09)
      ..strokeWidth = .5;
    for (double xi = 0; xi <= w; xi++) {
      c.drawLine(p(xi,0,0),p(xi,l,0),gp);
    }
    for (double yi = 0; yi <= l; yi++) {
      c.drawLine(p(0,yi,0),p(w,yi,0),gp);
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

class _SelectionPainter extends CustomPainter {
  final bool isSelected;
  _SelectionPainter(this.isSelected);

  @override
  void paint(Canvas c, Size size) {
    if (!isSelected) return;
    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(10),
    );
    c.drawRRect(rr, Paint()
      ..color = Colors.white.withValues(alpha: .92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0);
  }

  @override
  bool shouldRepaint(_SelectionPainter old) => old.isSelected != isSelected;
}

class _FurnitureTile extends StatefulWidget {
  final FurnitureItem item;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onDoubleTap;
  final void Function(DragUpdateDetails) onDrag;

  const _FurnitureTile({
    required this.item,
    required this.isSelected,
    required this.onSelect,
    required this.onDoubleTap,
    required this.onDrag,
  });

  @override
  State<_FurnitureTile> createState() => _FurnitureTileState();
}

class _FurnitureTileState extends State<_FurnitureTile> {
  late String _cameraOrbit;

  @override
  void initState() {
    super.initState();
    _cameraOrbit = _orbitFor(widget.item.rotationDeg);
  }

  @override
  void didUpdateWidget(_FurnitureTile old) {
    super.didUpdateWidget(old);
    if (old.item.rotationDeg != widget.item.rotationDeg) {
      setState(() => _cameraOrbit = _orbitFor(widget.item.rotationDeg));
    }
  }

  static String _orbitFor(double deg) {
    final az = (45 + deg).toStringAsFixed(0);
    return '${az}deg 55deg auto';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ModelViewer(
          key: ValueKey(
              '${widget.item.id}_${widget.item.rotationDeg.toStringAsFixed(0)}'),
          src: widget.item.glbAsset,
          alt: widget.item.name,
          ar: false,
          autoRotate: false,
          cameraControls: false,
          backgroundColor: Colors.transparent,
          shadowIntensity: 0.7,
          exposure: 1.1,
          cameraOrbit: _cameraOrbit,
          fieldOfView: '28deg',
        ),
        CustomPaint(painter: _SelectionPainter(widget.isSelected)),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onSelect,
          onDoubleTap: widget.onDoubleTap,
          onPanUpdate: widget.onDrag,
          child: const SizedBox.expand(),
        ),
      ],
    );
  }
}

class _LazyModelCard extends StatefulWidget {
  final FurnitureItem item;
  final VoidCallback onTap;
  const _LazyModelCard({required this.item, required this.onTap});
  @override
  State<_LazyModelCard> createState() => _LazyModelCardState();
}

class _LazyModelCardState extends State<_LazyModelCard> {
  bool _showModel = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_showModel) {
          setState(() => _showModel = true);
        } else {
          widget.onTap();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: _kLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _showModel ? _kPrimary : _kPrimary.withValues(alpha: .35),
            width: _showModel ? 2 : 1,
          ),
        ),
        child: Column(children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
              child: _showModel
                  ? ModelViewer(
                      src: widget.item.glbAsset, alt: widget.item.name,
                      ar: false, autoRotate: true, autoRotateDelay: 0,
                      cameraControls: true, backgroundColor: _kBg,
                      shadowIntensity: 0.8, exposure: 1.1,
                    )
                  : Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.item.tileColor.withValues(alpha: .22),
                            widget.item.tileColor.withValues(alpha: .08),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.item.emoji,
                              style: const TextStyle(fontSize: 36)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _kPrimary.withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.touch_app,
                                    size: 10, color: _kPrimary),
                                SizedBox(width: 3),
                                Text('Tap to preview',
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: _kPrimary,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 5, 6, 6),
            child: Column(children: [
              Text(widget.item.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _kDark)),
              Text(
                _showModel
                    ? 'Tap again to add →'
                    : '${widget.item.widthM}×${widget.item.depthM}m',
                style: TextStyle(
                    fontSize: 9,
                    color: _showModel ? _kPrimary : _kMedium,
                    fontWeight:
                        _showModel ? FontWeight.bold : FontWeight.normal),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class FurnitureModelViewer extends StatelessWidget {
  final FurnitureItem item;
  const FurnitureModelViewer({super.key, required this.item});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kDark,
        title: Text(item.name,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done',
                style: TextStyle(
                    color: _kLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: ModelViewer(
            src: item.glbAsset, alt: item.name,
            ar: false, autoRotate: false, cameraControls: true,
            backgroundColor: _kBg, shadowIntensity: 1.0,
            shadowSoftness: 0.8, exposure: 1.2,
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 34),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(children: [
            Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFDDD0C4),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 14),
            Row(children: [
              Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                      color: _kLight,
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                      child: Text(item.emoji,
                          style: const TextStyle(fontSize: 26)))),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                Text(item.name,
                    style: const TextStyle(
                        color: _kDark,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                Text(
                    '${item.widthM}m × ${item.depthM}m × ${item.heightM}m',
                    style:
                        const TextStyle(color: _kMedium, fontSize: 13)),
              ])),
            ]),
            const SizedBox(height: 10),
            const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Icon(Icons.touch_app, color: _kMedium, size: 14),
              SizedBox(width: 4),
              Text('Drag to rotate  •  Pinch to zoom',
                  style: TextStyle(color: _kMedium, fontSize: 12)),
            ]),
          ]),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────────────────────
class Room3DScreen extends StatefulWidget {
  final double roomWidth, roomLength, roomHeight;
  final String? referenceImagePath;
  final List<Map<String, dynamic>> initialFurniture;

  const Room3DScreen({
    super.key,
    required this.roomWidth,
    required this.roomLength,
    required this.roomHeight,
    this.referenceImagePath,
    this.initialFurniture = const [],
  });

  @override
  State<Room3DScreen> createState() => _Room3DScreenState();
}

class _Room3DScreenState extends State<Room3DScreen> {
  double _scale = 80.0;
  Offset _panOffset = const Offset(220, 160);
  final double _roomRotation = 0.0;
  String? _selectedId;
  final List<FurnitureItem> _furniture = [];
  Size _screenSize = Size.zero;
  final bool _isSaving = false;
  bool _isLoading = false;
  bool _isAddingToCart = false; // ← جديد
  static const _baseUrl = ApiConfig.baseUrl;

  static final List<FurnitureItem> _catalog = [
    FurnitureItem(id:'sofa',name:'Sofa',emoji:'🛋',type:FurnitureType.sofa,
        glbAsset:'assets/models/sofa.glb',widthM:2.10,depthM:0.95,heightM:0.82,
        tileColor:const Color(0xFF8B6B4A),position:Offset.zero,
        productId: 3), // ← DB id
    FurnitureItem(id:'armchair',name:'Armchair',emoji:'💺',type:FurnitureType.armchair,
        glbAsset:'assets/models/armchair.glb',widthM:0.85,depthM:0.85,heightM:0.82,
        tileColor:const Color(0xFFA0724E),position:Offset.zero,
        productId: 2), // ← DB id
    FurnitureItem(id:'bed',name:'Double Bed',emoji:'🛏',type:FurnitureType.bed,
        glbAsset:'assets/models/bed.glb',widthM:1.60,depthM:2.10,heightM:0.80,
        tileColor:const Color(0xFF7D533D),position:Offset.zero,
        productId: 1), // ← DB id
    FurnitureItem(id:'dtable',name:'Dining Table',emoji:'🍽',type:FurnitureType.diningTable,
        glbAsset:'assets/models/dining_table.glb',widthM:1.40,depthM:0.85,heightM:0.76,
        tileColor:const Color(0xFFB8845A),position:Offset.zero,
        productId: 4), // ← DB id
    FurnitureItem(id:'desk',name:'Desk',emoji:'🖥',type:FurnitureType.desk,
        glbAsset:'assets/models/desk.glb',widthM:1.40,depthM:0.65,heightM:0.76,
        tileColor:const Color(0xFFB8845A),position:Offset.zero,
        productId: 5), // ← DB id
    FurnitureItem(id:'ctable',name:'Coffee Table',emoji:'☕',type:FurnitureType.coffeeTable,
        glbAsset:'assets/models/coffee_table.glb',widthM:1.10,depthM:0.60,heightM:0.42,
        tileColor:const Color(0xFFB8845A),position:Offset.zero,
        productId: 19), // Coffee Table
    FurnitureItem(id:'wardrobe',name:'Wardrobe',emoji:'🚪',type:FurnitureType.wardrobe,
        glbAsset:'assets/models/wardrobe.glb',widthM:1.20,depthM:0.60,heightM:2.10,
        tileColor:const Color(0xFF9B6B45),position:Offset.zero,
        productId: 20),
    FurnitureItem(id:'tvstand',name:'TV Stand',emoji:'📺',type:FurnitureType.tvStand,
        glbAsset:'assets/models/tv_stand.glb',widthM:1.60,depthM:0.45,heightM:0.50,
        tileColor:const Color(0xFF7A5535),position:Offset.zero,
        productId: 21),
    FurnitureItem(id:'shelf',name:'Bookshelf',emoji:'📚',type:FurnitureType.bookshelf,
        glbAsset:'assets/models/bookshelf.glb',widthM:0.90,depthM:0.35,heightM:1.80,
        tileColor:const Color(0xFF9B6B45),position:Offset.zero,
        productId: 22),
    FurnitureItem(id:'plant',name:'Plant',emoji:'🌿',type:FurnitureType.plant,
        glbAsset:'assets/models/plant.glb',widthM:0.45,depthM:0.45,heightM:1.10,
        tileColor:const Color(0xFF4A7C40),position:Offset.zero,
        productId: 23),
    FurnitureItem(id:'lamp',name:'Floor Lamp',emoji:'💡',type:FurnitureType.lamp,
        glbAsset:'assets/models/lamp.glb',widthM:0.40,depthM:0.40,heightM:1.65,
        tileColor:const Color(0xFFCCBB88),position:Offset.zero,
        productId: 24),
    FurnitureItem(id:'bathtub',name:'Bathtub',emoji:'🛁',type:FurnitureType.bathtub,
        glbAsset:'assets/models/bathtub.glb',widthM:0.80,depthM:1.70,heightM:0.56,
        tileColor:const Color(0xFFB0C8D4),position:Offset.zero,
        productId: 25),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialFurniture.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadRoomData({'furniture': widget.initialFurniture});
      });
    }
  }

  void _autoFit(Size size) {
    final w = widget.roomWidth, l = widget.roomLength;
    final isoW = (w + l) * 0.866025;
    final isoH = (w + l) * 0.5 + widget.roomHeight * 0.816;
    final availW = size.width  - 80;
    final availH = size.height - 220;
    final scaleW = availW / isoW;
    final scaleH = availH / isoH;
    _scale = (scaleW < scaleH ? scaleW : scaleH).clamp(20.0, 180.0);
    _recenter();
  }

  void _recenter() {
    final w = widget.roomWidth, l = widget.roomLength;
    final screenW = _screenSize == Size.zero ? 400.0 : _screenSize.width;
    final screenH = _screenSize == Size.zero ? 700.0 : _screenSize.height;
    final isoW = (w + l) * 0.866025 * _scale;
    final isoH = (w + l) * 0.5      * _scale;
    _panOffset = Offset(
      (screenW - isoW) / 2 + l * 0.866025 * _scale,
      (screenH - 200 - isoH) / 2 + 60,
    );
  }

  Offset? _toFloor(Offset s) {
    final dx = s.dx - _panOffset.dx, dy = s.dy - _panOffset.dy;
    final x = (dx / .866025 + dy / .5) / (2 * _scale);
    final y = (dy / .5 - dx / .866025) / (2 * _scale);
    if (x >= 0 && x <= widget.roomWidth &&
        y >= 0 && y <= widget.roomLength) {
      return Offset(x, y);
    }
    return null;
  }

  Offset _furnitureScreenCenter(FurnitureItem f) {
    final fx = f.position.dx + f.effectiveWidth / 2;
    final fy = f.position.dy + f.effectiveDepth / 2;
    final fz = f.heightM / 2;
    return _iso(fx, fy, fz, _scale, _panOffset);
  }

  double _furniturePxW(FurnitureItem f) =>
      f.effectiveWidth * _scale * 1.8 + f.heightM * _scale * 0.6;

  double _furniturePxH(FurnitureItem f) =>
      f.effectiveDepth * _scale * 1.2 + f.heightM * _scale * 1.0;

  void _onRoomTap(TapUpDetails d) {
    final fp = _toFloor(d.localPosition);
    if (fp == null) { setState(() => _selectedId = null); return; }
    setState(() => _selectedId = null);
  }

  void _onFurnitureDrag(String id, DragUpdateDetails d) {
    final idx = _furniture.indexWhere((f) => f.id == id);
    if (idx < 0) return;
    final f = _furniture[idx];
    final mx = (d.delta.dx / .866025 + d.delta.dy / .5) / (2 * _scale);
    final my = (d.delta.dy / .5 - d.delta.dx / .866025) / (2 * _scale);
    final newPos = Offset(
      (f.position.dx + mx).clamp(0, widget.roomWidth  - f.effectiveWidth),
      (f.position.dy + my).clamp(0, widget.roomLength - f.effectiveDepth),
    );
    final moved = f.copyWith(position: newPos);
    if (!_overlaps(moved, _furniture)) setState(() => _furniture[idx] = moved);
  }

  void _rotate(double deg) {
    if (_selectedId == null) return;
    final idx = _furniture.indexWhere((f) => f.id == _selectedId);
    if (idx < 0) return;
    final f = _furniture[idx];
    final raw     = (f.rotationDeg + deg) % 360;
    final snapped = ((raw / 90).round() * 90) % 360;
    final nr      = (snapped < 0 ? snapped + 360 : snapped).toDouble();
    final nw = (nr == 90 || nr == 270) ? f.depthM : f.widthM;
    final nd = (nr == 90 || nr == 270) ? f.widthM : f.depthM;
    final newPos = Offset(
      f.position.dx.clamp(0, widget.roomWidth  - nw),
      f.position.dy.clamp(0, widget.roomLength - nd),
    );
    setState(
        () => _furniture[idx] = f.copyWith(rotationDeg: nr, position: newPos));
  }

  void _delete() {
    setState(() {
      _furniture.removeWhere((f) => f.id == _selectedId);
      _selectedId = null;
    });
  }

  void _resize(double factor) {
    if (_selectedId == null) return;
    final idx = _furniture.indexWhere((f) => f.id == _selectedId);
    if (idx < 0) return;
    final f = _furniture[idx];
    final newW =
        (f.widthM * factor).clamp(0.20, widget.roomWidth  - f.position.dx);
    final newD =
        (f.depthM * factor).clamp(0.20, widget.roomLength - f.position.dy);
    setState(() {
      _furniture[idx] = FurnitureItem(
        id: f.id, name: f.name, glbAsset: f.glbAsset,
        emoji: f.emoji, type: f.type,
        widthM: newW, depthM: newD,
        heightM: (f.heightM * factor).clamp(0.10, 4.0),
        tileColor: f.tileColor, position: f.position,
        topImageAsset: f.topImageAsset,
        productId: f.productId,
        rotationDeg: f.rotationDeg, isSelected: f.isSelected,
      );
    });
  }

  bool _overlaps(FurnitureItem a, List<FurnitureItem> others) {
    const gap = 0.05;
    for (final b in others) {
      if (b.id == a.id) continue;
      final ax1=a.position.dx, ax2=a.position.dx+a.effectiveWidth;
      final ay1=a.position.dy, ay2=a.position.dy+a.effectiveDepth;
      final bx1=b.position.dx-gap, bx2=b.position.dx+b.effectiveWidth+gap;
      final by1=b.position.dy-gap, by2=b.position.dy+b.effectiveDepth+gap;
      if (ax1<bx2&&ax2>bx1&&ay1<by2&&ay2>by1) return true;
    }
    return false;
  }

  void _addFurniture(FurnitureItem cat) {
    final count = _furniture.where((f) => f.id.startsWith(cat.id)).length;
    final newId = '${cat.id}_$count';
    Offset freePos = Offset(
      ((widget.roomWidth  - cat.widthM) / 2).clamp(0, widget.roomWidth  - cat.widthM),
      ((widget.roomLength - cat.depthM) / 2).clamp(0, widget.roomLength - cat.depthM),
    );
    outer:
    for (double ty = 0; ty <= widget.roomLength - cat.depthM; ty += 0.3) {
      for (double tx = 0; tx <= widget.roomWidth  - cat.widthM; tx += 0.3) {
        final candidate = FurnitureItem(
          id: newId, name: cat.name, glbAsset: cat.glbAsset,
          emoji: cat.emoji, type: cat.type,
          widthM: cat.widthM, depthM: cat.depthM, heightM: cat.heightM,
          tileColor: cat.tileColor, position: Offset(tx, ty),
          productId: cat.productId,
        );
        if (!_overlaps(candidate, _furniture)) {
          freePos = Offset(tx, ty);
          break outer;
        }
      }
    }
    setState(() {
      _furniture.add(FurnitureItem(
        id: newId, name: cat.name, glbAsset: cat.glbAsset,
        emoji: cat.emoji, type: cat.type,
        widthM: cat.widthM, depthM: cat.depthM, heightM: cat.heightM,
        tileColor: cat.tileColor, topImageAsset: cat.topImageAsset,
        productId: cat.productId,
        position: freePos,
      ));
      _selectedId = newId;
    });
    Navigator.pop(context);
  }

  // ─── Add to Cart ──────────────────────────────────────────────────────────
  Future<void> _addToCart(FurnitureItem item) async {
    if (item.productId == null) return;
    setState(() => _isAddingToCart = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;
      if (userId == 0) {
        _snack('❌ Please login first', isError: true);
        return;
      }
      final cart = context.read<CartProvider>();
      final success = await cart.addToCart(userId, item.productId!, 1);
      if (mounted) {
        _snack(success
            ? '🛒 ${item.name} added to cart!'
            : '❌ Failed to add to cart',
            isError: !success);
      }
    } catch (e) {
      if (mounted) _snack('❌ Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  void _showSaveDialog() {
    if (_furniture.isEmpty) {
      _snack('Add some furniture first!', isError: true);
      return;
    }

    final dims = RoomDimensions(
      width: widget.roomWidth,
      length: widget.roomLength,
      height: widget.roomHeight,
      measuredAt: DateTime.now(),
    );

    final furnitureJson = _furniture.map((f) => {
      'id': f.id,
      'name': f.name,
      'type': f.type.name,
      'x': f.position.dx,
      'y': f.position.dy,
      'rotation': f.rotationDeg,
      'widthM': f.widthM,
      'depthM': f.depthM,
      'heightM': f.heightM,
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomNameScreen(
          dimensions: dims,
          furniture: furnitureJson,
        ),
      ),
    );
  }

  Future<void> _showSavedRooms() async {
    setState(() => _isLoading = true);
    List<dynamic> rooms = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      if (userId == null) {
        _snack('❌ Please login first', isError: true);
        setState(() => _isLoading = false);
        return;
      }
      final res = await http.get(
        Uri.parse('$_baseUrl/rooms/list?user_id=$userId'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      if (res.statusCode == 200) rooms = jsonDecode(res.body) as List;
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFDDD0C4),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              const Text('My Rooms',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _kDark)),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const RoomSetupScreen()));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _kPrimary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.add, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('New Room',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: rooms.isEmpty
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.inbox_outlined,
                        size: 52, color: _kMedium),
                    const SizedBox(height: 8),
                    const Text('No saved rooms yet',
                        style: TextStyle(color: _kMedium)),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const RoomSetupScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: _kPrimary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('+ Add your first room',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ]))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    itemCount: rooms.length,
                    itemBuilder: (_, i) {
                      final r = rooms[i] as Map<String, dynamic>;
                      final furnitureList = (r['furniture'] as List?) ?? [];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _kLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: _kPrimary.withValues(alpha: .3)),
                        ),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _kPrimary.withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.meeting_room_outlined,
                                color: _kDark, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r['name'] ?? 'Room',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _kDark,
                                      fontSize: 14)),
                              Text(
                                  '${(r['width'] as num).toStringAsFixed(1)}m × '
                                  '${(r['length'] as num).toStringAsFixed(1)}m × '
                                  '${(r['height'] as num).toStringAsFixed(1)}m',
                                  style: const TextStyle(
                                      color: _kMedium, fontSize: 12)),
                              Text(
                                  '${furnitureList.length} furniture item(s)',
                                  style: const TextStyle(
                                      color: _kPrimary, fontSize: 11)),
                            ],
                          )),
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                              icon: const Icon(Icons.download_outlined,
                                  color: _kPrimary, size: 20),
                              tooltip: 'Load this room',
                              onPressed: () {
                                Navigator.pop(context);
                                _loadRoomData(r);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: Colors.red[400], size: 20),
                              tooltip: 'Delete',
                              onPressed: () async {
                                final id = r['id'] as int;
                                try {
                                  await http.delete(
                                    Uri.parse('$_baseUrl/rooms/$id'),
                                    headers: {
                                      'ngrok-skip-browser-warning': 'true'
                                    },
                                  );
                                } catch (_) {}
                                if (context.mounted) Navigator.pop(context);
                                _showSavedRooms();
                              },
                            ),
                          ]),
                        ]),
                      );
                    }),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _loadRoomData(Map<String, dynamic> r) {
    final furnitureList = (r['furniture'] as List?) ?? [];
    setState(() {
      _furniture.clear();
      _selectedId = null;
      for (final item in furnitureList) {
        final m = item as Map<String, dynamic>;
        final typeName = m['type'] as String? ?? 'sofa';
        final cat = _catalog.firstWhere(
            (c) => c.type.name == typeName,
            orElse: () => _catalog.first);
        _furniture.add(FurnitureItem(
          id: m['id'] as String? ?? '${typeName}_0',
          name: m['name'] as String? ?? cat.name,
          glbAsset: cat.glbAsset,
          emoji: cat.emoji,
          type: cat.type,
          widthM: (m['widthM'] as num?)?.toDouble() ?? cat.widthM,
          depthM: (m['depthM'] as num?)?.toDouble() ?? cat.depthM,
          heightM: (m['heightM'] as num?)?.toDouble() ?? cat.heightM,
          tileColor: cat.tileColor,
          productId: cat.productId,
          position: Offset(
              (m['x'] as num).toDouble(),
              (m['y'] as num).toDouble()),
          rotationDeg: (m['rotation'] as num).toDouble(),
        ));
      }
    });
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red[700] : _kDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFDDD0C4),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Add Furniture',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _kDark))),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.82,
              ),
              itemCount: _catalog.length,
              itemBuilder: (_, i) => _LazyModelCard(
                  item: _catalog[i],
                  onTap: () => _addFurniture(_catalog[i])),
            ),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sel = _selectedId != null
        ? _furniture.firstWhere((f) => f.id == _selectedId,
            orElse: () => _furniture.first)
        : null;

    final sortedFurniture = [..._furniture]
      ..sort((a, b) => (b.position.dx + b.position.dy)
          .compareTo(a.position.dx + a.position.dy));

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kDark,
        title: Text(
          '${widget.roomWidth.toStringAsFixed(1)}m × '
          '${widget.roomLength.toStringAsFixed(1)}m Room',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.folder_open, color: Colors.white),
            tooltip: 'My Rooms',
            onPressed: _showSavedRooms,
          ),
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save, color: Colors.white),
            tooltip: 'Save room',
            onPressed: _showSaveDialog,
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        if (_screenSize == Size.zero) {
          _screenSize = Size(constraints.maxWidth, constraints.maxHeight);
          _autoFit(_screenSize);
        }
        return Stack(children: [
          GestureDetector(
            onTapUp: _onRoomTap,
            onPanUpdate: _selectedId == null
                ? (d) => setState(() => _panOffset += d.delta)
                : null,
            child: Transform.rotate(
              angle: _roomRotation * math.pi / 180,
              child: CustomPaint(
                painter: _RoomPainter(
                  roomWidth: widget.roomWidth,
                  roomLength: widget.roomLength,
                  roomHeight: widget.roomHeight,
                  scale: _scale,
                  pan: _panOffset,
                ),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          ...sortedFurniture.map((f) {
            final center = _furnitureScreenCenter(f);
            final pxW = _furniturePxW(f);
            final pxH = _furniturePxH(f);
            final isSelected = f.id == _selectedId;
            return Positioned(
              left: center.dx - pxW / 2,
              top:  center.dy - pxH / 2,
              width: pxW, height: pxH,
              child: _FurnitureTile(
                item: f, isSelected: isSelected,
                onSelect: () => setState(() => _selectedId = f.id),
                onDoubleTap: () {
                  setState(() => _selectedId = f.id);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => FurnitureModelViewer(item: f)));
                },
                onDrag: (d) {
                  if (!isSelected) setState(() => _selectedId = f.id);
                  _onFurnitureDrag(f.id, d);
                },
              ),
            );
          }),

          if (widget.referenceImagePath != null)
            Positioned(
                left: 14, top: 14,
                child: GestureDetector(
                  onTap: () => showDialog(
                      context: context,
                      builder: (_) => Dialog(
                          backgroundColor: Colors.transparent,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                  File(widget.referenceImagePath!),
                                  fit: BoxFit.contain)))),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _kPrimary, width: 2),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: .2),
                            blurRadius: 6)
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(widget.referenceImagePath!),
                          width: 58, height: 58, fit: BoxFit.cover),
                    ),
                  ),
                )),

          Positioned(
            right: 14, top: 14,
            child: Column(children: [
              _iconBtn(Icons.add,
                  () => setState(
                      () => _scale = (_scale * 1.15).clamp(30, 240))),
              const SizedBox(height: 8),
              _iconBtn(Icons.remove,
                  () => setState(
                      () => _scale = (_scale / 1.15).clamp(30, 240))),
              const SizedBox(height: 8),
              _iconBtn(Icons.center_focus_strong,
                  () => setState(() => _autoFit(_screenSize))),
            ]),
          ),

          if (sel != null)
            Positioned(
                top: 14, left: 0, right: 0,
                child: Center(
                    child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _kDark.withValues(alpha: .82),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Double-tap → full 3D view',
                      style:
                          TextStyle(color: Colors.white, fontSize: 11)),
                ))),

          if (sel != null)
            Positioned(
                left: 0, right: 0, bottom: 112,
                child: Center(
                    child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: _kDark.withValues(alpha: .93),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: .22),
                          blurRadius: 12)
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      _rotBtn(Icons.rotate_left, '90°',
                          () => _rotate(-90)),
                      const SizedBox(width: 2),
                      _rotBtn(Icons.rotate_left, '45°',
                          () => _rotate(-45),
                          small: true),
                      const SizedBox(width: 4),
                      _toolBtn(Icons.zoom_out, () => _resize(0.85)),
                      const SizedBox(width: 2),
                      _toolBtn(Icons.zoom_in, () => _resize(1.15)),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    FurnitureModelViewer(item: sel))),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                              color: _kPrimary,
                              borderRadius: BorderRadius.circular(30)),
                          child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.view_in_ar,
                                    color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text('3D',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                              ]),
                        ),
                      ),
                      const SizedBox(width: 4),
                      _rotBtn(Icons.rotate_right, '45°',
                          () => _rotate(45),
                          small: true),
                      const SizedBox(width: 2),
                      _rotBtn(
                          Icons.rotate_right, '90°', () => _rotate(90)),
                    ]),
                  ),
                ))),

          // ─── Bottom Bar ───────────────────────────────────────────────────
          Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: .07),
                        blurRadius: 12)
                  ],
                ),
                child: sel != null
                    ? Row(children: [
                        Text(sel.emoji,
                            style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                              Text(sel.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _kDark,
                                      fontSize: 15)),
                              Text(
                                '${sel.rotationDeg.toInt()}°  •  '
                                '${sel.effectiveWidth.toStringAsFixed(1)}×'
                                '${sel.effectiveDepth.toStringAsFixed(1)}m',
                                style: const TextStyle(
                                    fontSize: 11, color: _kMedium),
                              ),
                            ])),

                        // ─── زرار Add to Cart (بس لو عنده productId) ───
                        if (sel.productId != null) ...[
                          GestureDetector(
                            onTap: _isAddingToCart
                                ? null
                                : () => _addToCart(sel),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 9),
                              decoration: BoxDecoration(
                                color: _isAddingToCart
                                    ? _kPrimary.withValues(alpha: .5)
                                    : _kPrimary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _isAddingToCart
                                  ? const SizedBox(
                                      width: 18, height: 18,
                                      child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2))
                                  : const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.shopping_cart,
                                            color: Colors.white, size: 16),
                                        SizedBox(width: 5),
                                        Text('Add to Cart',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12)),
                                      ]),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // ─── زرار Delete ───────────────────────────────
                        GestureDetector(
                          onTap: _delete,
                          child: Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: .10),
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.delete_outline,
                                  color: Colors.red, size: 20)),
                        ),
                      ])
                    : Row(children: [
                        const Icon(Icons.touch_app_outlined,
                            color: _kMedium, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(
                          _furniture.isEmpty
                              ? 'Tap "Add Furniture" to start'
                              : 'Tap → select  •  Drag → move  •  Double-tap → 3D',
                          style: const TextStyle(
                              color: _kMedium, fontSize: 13),
                        )),
                        ElevatedButton.icon(
                          onPressed: _showPicker,
                          icon: const Icon(Icons.add,
                              size: 15, color: Colors.white),
                          label: const Text('Add Furniture',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kPrimary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ]),
              )),
        ]);
      }),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: .10),
                  blurRadius: 4)
            ],
          ),
          child: Icon(icon, color: _kDark, size: 20),
        ),
      );

  Widget _toolBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );

  Widget _rotBtn(IconData icon, String label, VoidCallback onTap,
          {bool small = false}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: small ? 8 : 12, vertical: small ? 6 : 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: Colors.white, size: small ? 16 : 20),
            Text(label,
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: small ? 8 : 9)),
          ]),
        ),
      );
}