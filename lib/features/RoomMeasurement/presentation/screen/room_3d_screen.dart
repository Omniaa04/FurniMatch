// lib/features/RoomMeasurement/presentation/screen/room_3d_screen.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:model_viewer_plus/model_viewer_plus.dart';

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
  Offset position;
  double rotationDeg;
  bool isSelected;

  FurnitureItem({
    required this.id, required this.name, required this.glbAsset,
    required this.emoji, required this.type,
    required this.widthM, required this.depthM, required this.heightM,
    required this.tileColor, required this.position,
    this.topImageAsset, this.rotationDeg = 0, this.isSelected = false,
  });

  FurnitureItem copyWith({Offset? position, double? rotationDeg, bool? isSelected}) =>
      FurnitureItem(
        id: id, name: name, glbAsset: glbAsset, emoji: emoji, type: type,
        widthM: widthM, depthM: depthM, heightM: heightM, tileColor: tileColor,
        topImageAsset: topImageAsset,
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
  for (final o in pts.skip(1)) path.lineTo(o.dx, o.dy);
  path.close();
  c.drawPath(path, Paint()..color = fill);
  if (sw > 0) {
    c.drawPath(path, Paint()
      ..color = stroke..style = PaintingStyle.stroke..strokeWidth = sw);
  }
}

void _box(Canvas c, double x, double y, double w, double d, double h,
    double z0, double s, Offset pan, Color top, Color left, Color front,
    {double sw = 0.8}) {
  final e = Colors.black.withValues(alpha: 0.20);
  _face(c, [
    _iso(x, y, z0, s, pan), _iso(x, y+d, z0, s, pan),
    _iso(x, y+d, z0+h, s, pan), _iso(x, y, z0+h, s, pan),
  ], left, e, sw);
  _face(c, [
    _iso(x, y, z0, s, pan), _iso(x+w, y, z0, s, pan),
    _iso(x+w, y, z0+h, s, pan), _iso(x, y, z0+h, s, pan),
  ], front, e, sw);
  _face(c, [
    _iso(x, y, z0+h, s, pan), _iso(x+w, y, z0+h, s, pan),
    _iso(x+w, y+d, z0+h, s, pan), _iso(x, y+d, z0+h, s, pan),
  ], top, e, sw);
}

Color _l(Color c, double t) => Color.lerp(c, Colors.white, t)!;
Color _d(Color c, double t) => Color.lerp(c, Colors.black, t)!;

void _drawShape(Canvas c, FurnitureItem f, double s, Offset pan) {
  final x = f.position.dx, y = f.position.dy;
  final col = f.tileColor;
  final r = (((f.rotationDeg / 90).round() * 90) % 360).toDouble();
  final w = f.effectiveWidth, d = f.effectiveDepth;
  _drawFurnitureShape(c, f, x, y, w, d, col, r, s, pan);
}

void _drawFurnitureShape(Canvas c, FurnitureItem f, double x, double y,
    double w, double d, Color col, double r, double s, Offset pan) {
  switch (f.type) {
    case FurnitureType.sofa:      _drawSofa(c, x, y, w, d, col, r, s, pan); break;
    case FurnitureType.armchair:  _drawArmchair(c, x, y, w, d, col, r, s, pan); break;
    case FurnitureType.bed:       _drawBed(c, x, y, w, d, col, r, s, pan); break;
    case FurnitureType.diningTable:
    case FurnitureType.coffeeTable:
    case FurnitureType.desk:      _drawTable(c, f, x, y, w, d, col, r, s, pan); break;
    case FurnitureType.wardrobe:  _drawWardrobe(c, f, x, y, w, d, col, r, s, pan); break;
    case FurnitureType.tvStand:   _drawTvStand(c, x, y, w, d, col, r, s, pan); break;
    case FurnitureType.bookshelf: _drawBookshelf(c, f, x, y, w, d, col, r, s, pan); break;
    case FurnitureType.plant:     _drawPlant(c, x, y, w, d, col, s, pan); break;
    case FurnitureType.lamp:      _drawLamp(c, x, y, w, d, col, s, pan); break;
    case FurnitureType.bathtub:   _drawBathtub(c, x, y, w, d, col, r, s, pan); break;
  }
}

void _drawSofa(Canvas c, double x, double y, double w, double d,
    Color col, double r, double s, Offset pan) {
  for (final lx in [x+.04, x+w-.10]) {
    for (final ly in [y+.04, y+d-.10]) {
      _box(c,lx,ly,.06,.06,.12,0,s,pan,_d(col,.55),_d(col,.65),_d(col,.60));
    }
  }
  _box(c,x,y,w,d,.12,0,s,pan,_l(col,.10),_d(col,.35),_d(col,.20));
  final sw2=(w-.08)/2;
  for(int i=0;i<2;i++){
    _box(c,x+.04+i*(sw2+.02),y+d*.22,sw2-.01,d*.55,.16,.12,s,pan,
        _l(col,.32),_d(col,.18),_d(col,.08));
  }
  if(r==0||r==180){
    final by = r==0 ? y : y+d-.18*d;
    _box(c,x,by,w,d*.18,.52,.12,s,pan,_l(col,.18),_d(col,.40),_d(col,.24));
    _box(c,x,y,.14,d,.40,.12,s,pan,_l(col,.16),_d(col,.38),_d(col,.22));
    _box(c,x+w-.14,y,.14,d,.40,.12,s,pan,_l(col,.16),_d(col,.38),_d(col,.22));
  } else {
    final bx = r==90 ? x+w-.18*w : x;
    _box(c,bx,y,w*.18,d,.52,.12,s,pan,_l(col,.18),_d(col,.40),_d(col,.24));
    _box(c,x,y,w,.14,.40,.12,s,pan,_l(col,.16),_d(col,.38),_d(col,.22));
    _box(c,x,y+d-.14,w,.14,.40,.12,s,pan,_l(col,.16),_d(col,.38),_d(col,.22));
  }
}

void _drawArmchair(Canvas c, double x, double y, double w, double d,
    Color col, double r, double s, Offset pan) {
  for(final lx in [x+.03,x+w-.09]){
    for(final ly in [y+.03,y+d-.09]){
      _box(c,lx,ly,.06,.06,.12,0,s,pan,_d(col,.55),_d(col,.65),_d(col,.60));
    }
  }
  _box(c,x,y,w,d,.12,0,s,pan,_l(col,.10),_d(col,.35),_d(col,.20));
  _box(c,x+.12,y+d*.22,w-.24,d*.55,.14,.12,s,pan,_l(col,.32),_d(col,.18),_d(col,.08));
  if(r==0||r==180){
    final by = r==0 ? y : y+d-.18*d;
    _box(c,x,by,w,d*.18,.48,.12,s,pan,_l(col,.18),_d(col,.38),_d(col,.22));
    _box(c,x,y,.12,d,.36,.12,s,pan,_l(col,.16),_d(col,.36),_d(col,.20));
    _box(c,x+w-.12,y,.12,d,.36,.12,s,pan,_l(col,.16),_d(col,.36),_d(col,.20));
  } else {
    final bx = r==90 ? x+w-.18*w : x;
    _box(c,bx,y,w*.18,d,.48,.12,s,pan,_l(col,.18),_d(col,.38),_d(col,.22));
    _box(c,x,y,w,.12,.36,.12,s,pan,_l(col,.16),_d(col,.36),_d(col,.20));
    _box(c,x,y+d-.12,w,.12,.36,.12,s,pan,_l(col,.16),_d(col,.36),_d(col,.20));
  }
}

void _drawBed(Canvas c, double x, double y, double w, double d,
    Color col, double r, double s, Offset pan) {
  for(final lx in [x+.04,x+w-.10]){
    for(final ly in [y+.04,y+d-.10]){
      _box(c,lx,ly,.08,.08,.22,0,s,pan,_d(col,.40),_d(col,.55),_d(col,.48));
    }
  }
  _box(c,x,y,w,d,.25,0,s,pan,_l(col,.15),_d(col,.42),_d(col,.28));
  _box(c,x,y,w,.10,.85,0,s,pan,_l(col,.18),_d(col,.44),_d(col,.30));
  _box(c,x+.06,y+.01,w-.12,.07,.68,.10,s,pan,_l(col,.28),_d(col,.34),_d(col,.22));
  _box(c,x,y+d-.08,w,.08,.35,0,s,pan,_l(col,.15),_d(col,.42),_d(col,.28));
  _box(c,x+.04,y+.10,w-.08,d-.20,.22,.25,s,pan,
      const Color(0xFFF5F0EA),const Color(0xFFDDD5CC),const Color(0xFFE8E0D8));
  final bc=_l(col,.50);
  _box(c,x+.04,y+d*.36,w-.08,d*.58,.08,.47,s,pan,
      _l(bc,.10),_d(bc,.18),_d(bc,.08));
  final pw=(w-.28)/2;
  for(int i=0;i<2;i++){
    _box(c,x+.08+i*(pw+.06),y+.11,pw,d*.20,.12,.47,s,pan,
        Colors.white,const Color(0xFFE0D8D0),const Color(0xFFECE4DC));
  }
}

void _drawTable(Canvas c, FurnitureItem f, double x, double y,
    double w, double d, Color col, double r, double s, Offset pan) {
  final isLow = f.type == FurnitureType.coffeeTable;
  final legH  = isLow ? 0.32 : 0.68;
  for(final lx in [x+.05,x+w-.12]){
    for(final ly in [y+.05,y+d-.12]){
      _box(c,lx,ly,.07,.07,legH,0,s,pan,_d(col,.28),_d(col,.48),_d(col,.38));
    }
  }
  _box(c,x,y,w,d,.06,legH,s,pan,_l(col,.28),_d(col,.18),_l(col,.08));
  if(f.type==FurnitureType.desk){
    if(r==0||r==180){
      final my = r==0 ? y+.02 : y+d-.07;
      _box(c,x+w*.18,my,w*.60,.05,.30,legH+.06,s,pan,
          const Color(0xFF1A1A2E),const Color(0xFF0D0D1A),const Color(0xFF16213E));
    } else {
      final mx = r==90 ? x+w-.07 : x+.02;
      _box(c,mx,y+d*.18,.05,d*.60,.30,legH+.06,s,pan,
          const Color(0xFF1A1A2E),const Color(0xFF0D0D1A),const Color(0xFF16213E));
    }
  }
}

void _drawWardrobe(Canvas c, FurnitureItem f, double x, double y,
    double w, double d, Color col, double r, double s, Offset pan) {
  _box(c,x+.02,y+.01,w-.04,d-.02,.06,0,s,pan,_d(col,.15),_d(col,.35),_d(col,.22));
  _box(c,x,y,w,d,f.heightM,0,s,pan,_l(col,.20),_d(col,.30),col);
  _box(c,x,y,w,d,.04,f.heightM-.04,s,pan,_l(col,.25),_d(col,.28),_l(col,.12));
  if(r==0||r==180){
    final dd=(w-.06)/2;
    for(int i=0;i<2;i++){
      _box(c,x+.03+i*(dd+.02),y,dd,.03,f.heightM*.88,.02,s,pan,
          _l(col,.16),_d(col,.18),_l(col,.08));
      final hx=x+.03+i*(dd+.02)+dd*.60;
      _box(c,hx,y,.06,.025,.04,f.heightM*.45,s,pan,
          const Color(0xFFD4AA66),const Color(0xFFA07840),const Color(0xFFBB9050));
    }
  } else {
    final dd=(d-.06)/2;
    for(int i=0;i<2;i++){
      _box(c,x,y+.03+i*(dd+.02),.03,dd,f.heightM*.88,.02,s,pan,
          _l(col,.16),_d(col,.18),_l(col,.08));
      final hy=y+.03+i*(dd+.02)+dd*.60;
      _box(c,x,.06+hy,.025,.06,.04,f.heightM*.45,s,pan,
          const Color(0xFFD4AA66),const Color(0xFFA07840),const Color(0xFFBB9050));
    }
  }
}

void _drawTvStand(Canvas c, double x, double y, double w, double d,
    Color col, double r, double s, Offset pan) {
  for(final lx in [x+.05,x+w-.12]){
    for(final ly in [y+.04,y+d-.10]){
      _box(c,lx,ly,.07,.06,.16,0,s,pan,_d(col,.42),_d(col,.55),_d(col,.48));
    }
  }
  _box(c,x,y,w,d,.36,.16,s,pan,_l(col,.22),_d(col,.22),col);
  if(r==0||r==180){
    final dw2=(w-.06)/2;
    for(int i=0;i<2;i++){
      _box(c,x+.03+i*(dw2+.02),y,dw2,.025,.34,.17,s,pan,
          _l(col,.18),_d(col,.16),_l(col,.06));
    }
    _box(c,x+.04,y+.02,w-.08,.06,.44,.52,s,pan,
        const Color(0xFF0D0D1A),const Color(0xFF080810),const Color(0xFF111122));
    _box(c,x+.06,y+.025,w-.12,.04,.38,.55,s,pan,
        const Color(0xFF1A2A3A),const Color(0xFF101820),const Color(0xFF152030));
  } else {
    final dw2=(d-.06)/2;
    for(int i=0;i<2;i++){
      _box(c,x,y+.03+i*(dw2+.02),.025,dw2,.34,.17,s,pan,
          _l(col,.18),_d(col,.16),_l(col,.06));
    }
    _box(c,x+.02,y+.04,.06,d-.08,.44,.52,s,pan,
        const Color(0xFF0D0D1A),const Color(0xFF080810),const Color(0xFF111122));
    _box(c,x+.025,y+.06,.04,d-.12,.38,.55,s,pan,
        const Color(0xFF1A2A3A),const Color(0xFF101820),const Color(0xFF152030));
  }
}

void _drawBookshelf(Canvas c, FurnitureItem f, double x, double y,
    double w, double d, Color col, double r, double s, Offset pan) {
  _box(c,x,y,w,d,f.heightM,0,s,pan,_l(col,.20),_d(col,.30),col);
  final isWide = r==0||r==180;
  for(int i=1;i<=3;i++){
    if(isWide){
      _box(c,x+.03,y,w-.06,d,.04,f.heightM*i/4-.02,s,pan,
          _l(col,.16),_d(col,.28),_l(col,.08));
    } else {
      _box(c,x,y+.03,w,d-.06,.04,f.heightM*i/4-.02,s,pan,
          _l(col,.16),_d(col,.28),_l(col,.08));
    }
  }
  final bkc=[
    const Color(0xFFE74C3C),const Color(0xFF3498DB),const Color(0xFF27AE60),
    const Color(0xFFE67E22),const Color(0xFF8E44AD),const Color(0xFF16A085),
  ];
  for(int sh=0;sh<4;sh++){
    final bz=sh==0?0.03:f.heightM*sh/4+.04;
    final bh=f.heightM/4-.10;
    if(isWide){
      final nbk=4+sh%2; final bkw=(w-.10)/nbk;
      for(int b=0;b<nbk;b++){
        final bc2=bkc[(sh*nbk+b)%bkc.length];
        _box(c,x+.05+b*bkw,y+.02,bkw*.80,d*.60,bh*.90,bz,s,pan,
            _l(bc2,.20),_d(bc2,.30),bc2);
      }
    } else {
      final nbk=4+sh%2; final bkd=(d-.10)/nbk;
      for(int b=0;b<nbk;b++){
        final bc2=bkc[(sh*nbk+b)%bkc.length];
        _box(c,x+.02,y+.05+b*bkd,w*.60,bkd*.80,bh*.90,bz,s,pan,
            _l(bc2,.20),_d(bc2,.30),bc2);
      }
    }
  }
}

void _drawPlant(Canvas c, double x, double y, double w, double d,
    Color col, double s, Offset pan) {
  _box(c,x+w*.15,y+d*.15,w*.70,d*.70,.26,0,s,pan,
      const Color(0xFFD4785A),const Color(0xFF9B4530),const Color(0xFFBC6045));
  _box(c,x+w*.18,y+d*.18,w*.64,d*.64,.03,.24,s,pan,
      const Color(0xFF5C3D20),const Color(0xFF3A2410),const Color(0xFF4A3018));
  _box(c,x+w*.42,y+d*.42,w*.16,d*.16,.50,.27,s,pan,
      const Color(0xFF4A7C30),const Color(0xFF2A5018),const Color(0xFF3A6824));
  _box(c,x+w*.04,y+d*.04,w*.62,d*.44,.20,.62,s,pan,
      const Color(0xFF5CB85C),const Color(0xFF3A7A3A),const Color(0xFF4A9A4A));
  _box(c,x+w*.28,y+d*.02,w*.60,d*.44,.20,.76,s,pan,
      const Color(0xFF6EC96E),const Color(0xFF4A8A4A),const Color(0xFF5AB05A));
  _box(c,x+w*.04,y+d*.46,w*.62,d*.44,.20,.70,s,pan,
      const Color(0xFF52A852),const Color(0xFF386838),const Color(0xFF458845));
  _box(c,x+w*.12,y+d*.20,w*.76,d*.52,.22,.88,s,pan,
      const Color(0xFF78D878),const Color(0xFF509050),const Color(0xFF64B864));
}

void _drawLamp(Canvas c, double x, double y, double w, double d,
    Color col, double s, Offset pan) {
  _box(c,x+w*.20,y+d*.20,w*.60,d*.60,.06,0,s,pan,
      const Color(0xFFCCBB88),const Color(0xFF887744),const Color(0xFFAA9966));
  _box(c,x+w*.42,y+d*.42,w*.16,d*.16,1.20,.06,s,pan,
      const Color(0xFFBBBBBB),const Color(0xFF888888),const Color(0xFFAAAAAA));
  _box(c,x+w*.06,y+d*.06,w*.88,d*.88,.18,1.22,s,pan,
      const Color(0xFFF5E8C0),const Color(0xFFCCBB88),const Color(0xFFE8D4A8));
  _box(c,x+w*.12,y+d*.12,w*.76,d*.76,.14,1.24,s,pan,
      const Color(0xFFFFF8E8),const Color(0xFFEEDD99),const Color(0xFFF8ECC4));
}

void _drawBathtub(Canvas c, double x, double y, double w, double d,
    Color col, double r, double s, Offset pan) {
  _box(c,x,y,w,d,.54,0,s,pan,
      const Color(0xFFF0EBE6),const Color(0xFFCCC0B8),const Color(0xFFE4DBD4));
  _box(c,x+.08,y+.08,w-.16,d-.16,.38,.10,s,pan,
      const Color(0xFFB8D8EE),const Color(0xFF88B0CC),const Color(0xFFA4C8DC));
  _box(c,x+w*.38,y,w*.24,.06,.12,.54,s,pan,
      const Color(0xFFCCCCCC),const Color(0xFF999999),const Color(0xFFBBBBBB));
  _box(c,x+.02,y+.02,w-.04,d-.04,.04,.50,s,pan,
      const Color(0xFFF8F4F0),const Color(0xFFDDD5CC),const Color(0xFFEEE8E2));
}

class _RoomPainter extends CustomPainter {
  final double roomWidth, roomLength, roomHeight, scale;
  final List<FurnitureItem> furniture;
  final Offset pan;

  _RoomPainter({
    required this.roomWidth, required this.roomLength,
    required this.roomHeight, required this.furniture,
    required this.scale, required this.pan,
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
      ..moveTo(p(0,0,h).dx,p(0,0,h).dy)..lineTo(p(w,0,h).dx,p(w,0,h).dy)
      ..lineTo(p(w,l,h).dx,p(w,l,h).dy)..lineTo(p(0,l,h).dx,p(0,l,h).dy)
      ..close();
    c.drawPath(cp, Paint()
      ..color = _kDark.withValues(alpha: .14)
      ..style = PaintingStyle.stroke..strokeWidth = .8);
    final gp = Paint()
      ..color = _kDark.withValues(alpha: .09)..strokeWidth = .5;
    for (double xi = 0; xi <= w; xi++) c.drawLine(p(xi,0,0),p(xi,l,0),gp);
    for (double yi = 0; yi <= l; yi++) c.drawLine(p(0,yi,0),p(w,yi,0),gp);
    final sorted = [...furniture]
      ..sort((a,b) => (b.position.dx+b.position.dy)
          .compareTo(a.position.dx+a.position.dy));
    for (final f in sorted) {
      _drawShape(c, f, scale, pan);
      if (f.isSelected) {
        final fx=f.position.dx, fy=f.position.dy;
        final fw=f.effectiveWidth, fd=f.effectiveDepth;
        final fh=f.heightM*0.20;
        final sp = Path()
          ..moveTo(p(fx,fy,fh).dx,p(fx,fy,fh).dy)
          ..lineTo(p(fx+fw,fy,fh).dx,p(fx+fw,fy,fh).dy)
          ..lineTo(p(fx+fw,fy+fd,fh).dx,p(fx+fw,fy+fd,fh).dy)
          ..lineTo(p(fx,fy+fd,fh).dx,p(fx,fy+fd,fh).dy)..close();
        c.drawPath(sp, Paint()
          ..color = Colors.white.withValues(alpha: .92)
          ..style = PaintingStyle.stroke..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round);
      }
    }
  }

  @override
  bool shouldRepaint(_) => true;
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
        if (!_showModel) setState(() => _showModel = true);
        else widget.onTap();
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
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
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
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
                                Icon(Icons.touch_app, size: 10, color: _kPrimary),
                                SizedBox(width: 3),
                                Text('Tap to preview',
                                    style: TextStyle(fontSize: 9,
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
                  textAlign: TextAlign.center, maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w700, color: _kDark)),
              Text(
                _showModel ? 'Tap again to add →'
                    : '${widget.item.widthM}×${widget.item.depthM}m',
                style: TextStyle(fontSize: 9,
                    color: _showModel ? _kPrimary : _kMedium,
                    fontWeight: _showModel
                        ? FontWeight.bold : FontWeight.normal),
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
                style: TextStyle(color: _kLight,
                    fontWeight: FontWeight.bold, fontSize: 16)),
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
            Container(width: 40, height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFDDD0C4),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 14),
            Row(children: [
              Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                      color: _kLight, borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(item.emoji,
                      style: const TextStyle(fontSize: 26)))),
              const SizedBox(width: 14),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(color: _kDark,
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    Text('${item.widthM}m × ${item.depthM}m × ${item.heightM}m',
                        style: const TextStyle(color: _kMedium, fontSize: 13)),
                  ])),
            ]),
            const SizedBox(height: 10),
            const Row(mainAxisAlignment: MainAxisAlignment.center,
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

class Room3DScreen extends StatefulWidget {
  final double roomWidth, roomLength, roomHeight;
  final String? referenceImagePath;

  const Room3DScreen({
    super.key,
    required this.roomWidth,
    required this.roomLength,
    required this.roomHeight,
    this.referenceImagePath,
  });

  @override
  State<Room3DScreen> createState() => _Room3DScreenState();
}

class _Room3DScreenState extends State<Room3DScreen> {
  double _scale = 80.0;
  Offset _panOffset = const Offset(220, 160);
  double _roomRotation = 0.0;
  String? _selectedId;
  final List<FurnitureItem> _furniture = [];
  // screen size captured on first build for auto-fit
  Size _screenSize = Size.zero;
  bool _isSaving = false;
  bool _isLoading = false;
  // ← update when ngrok restarts
  static const _baseUrl = 'https://pout-tavern-refuse.ngrok-free.dev';

  static final List<FurnitureItem> _catalog = [
    FurnitureItem(id:'sofa',name:'Sofa',emoji:'🛋',type:FurnitureType.sofa,
        glbAsset:'assets/models/sofa.glb',widthM:2.10,depthM:0.95,heightM:0.82,
        tileColor:const Color(0xFF8B6B4A),position:Offset.zero),
    FurnitureItem(id:'armchair',name:'Armchair',emoji:'💺',type:FurnitureType.armchair,
        glbAsset:'assets/models/armchair.glb',widthM:0.85,depthM:0.85,heightM:0.82,
        tileColor:const Color(0xFFA0724E),position:Offset.zero),
    FurnitureItem(id:'bed',name:'Double Bed',emoji:'🛏',type:FurnitureType.bed,
        glbAsset:'assets/models/bed.glb',widthM:1.60,depthM:2.10,heightM:0.80,
        tileColor:const Color(0xFF7D533D),position:Offset.zero),
    FurnitureItem(id:'dtable',name:'Dining Table',emoji:'🍽',type:FurnitureType.diningTable,
        glbAsset:'assets/models/dining_table.glb',widthM:1.40,depthM:0.85,heightM:0.76,
        tileColor:const Color(0xFFB8845A),position:Offset.zero),
    FurnitureItem(id:'desk',name:'Desk',emoji:'🖥',type:FurnitureType.desk,
        glbAsset:'assets/models/desk.glb',widthM:1.40,depthM:0.65,heightM:0.76,
        tileColor:const Color(0xFFB8845A),position:Offset.zero),
    FurnitureItem(id:'ctable',name:'Coffee Table',emoji:'☕',type:FurnitureType.coffeeTable,
        glbAsset:'assets/models/coffee_table.glb',widthM:1.10,depthM:0.60,heightM:0.42,
        tileColor:const Color(0xFFB8845A),position:Offset.zero),
    FurnitureItem(id:'wardrobe',name:'Wardrobe',emoji:'🚪',type:FurnitureType.wardrobe,
        glbAsset:'assets/models/wardrobe.glb',widthM:1.20,depthM:0.60,heightM:2.10,
        tileColor:const Color(0xFF9B6B45),position:Offset.zero),
    FurnitureItem(id:'tvstand',name:'TV Stand',emoji:'📺',type:FurnitureType.tvStand,
        glbAsset:'assets/models/tv_stand.glb',widthM:1.60,depthM:0.45,heightM:0.50,
        tileColor:const Color(0xFF7A5535),position:Offset.zero),
    FurnitureItem(id:'shelf',name:'Bookshelf',emoji:'📚',type:FurnitureType.bookshelf,
        glbAsset:'assets/models/bookshelf.glb',widthM:0.90,depthM:0.35,heightM:1.80,
        tileColor:const Color(0xFF9B6B45),position:Offset.zero),
    FurnitureItem(id:'plant',name:'Plant',emoji:'🪴',type:FurnitureType.plant,
        glbAsset:'assets/models/plant.glb',widthM:0.45,depthM:0.45,heightM:1.10,
        tileColor:const Color(0xFF4A7C40),position:Offset.zero),
    FurnitureItem(id:'lamp',name:'Floor Lamp',emoji:'💡',type:FurnitureType.lamp,
        glbAsset:'assets/models/lamp.glb',widthM:0.40,depthM:0.40,heightM:1.65,
        tileColor:const Color(0xFFCCBB88),position:Offset.zero),
    FurnitureItem(id:'bathtub',name:'Bathtub',emoji:'🛁',type:FurnitureType.bathtub,
        glbAsset:'assets/models/bathtub.glb',widthM:0.80,depthM:1.70,heightM:0.56,
        tileColor:const Color(0xFFB0C8D4),position:Offset.zero),
  ];

  @override
  void initState() { super.initState(); }

  // Called on first build when we know the screen size.
  // Calculates scale so the room fits the available canvas with padding.
  void _autoFit(Size size) {
    final w = widget.roomWidth, l = widget.roomLength;
    // Isometric projected width and height of the room floor
    final isoW = (w + l) * 0.866025; // horizontal span
    final isoH = (w + l) * 0.5 + widget.roomHeight * 0.816; // vertical span
    // Available canvas (leave padding and bottom bar space)
    final availW = size.width  - 80;
    final availH = size.height - 220;
    // Pick scale that fits both axes
    final scaleW = availW / isoW;
    final scaleH = availH / isoH;
    _scale = (scaleW < scaleH ? scaleW : scaleH).clamp(20.0, 180.0);
    _recenter();
  }

  void _recenter() {
    final w = widget.roomWidth, l = widget.roomLength;
    final screenW = _screenSize == Size.zero ? 400.0 : _screenSize.width;
    final screenH = _screenSize == Size.zero ? 700.0 : _screenSize.height;
    // Center the isometric room in the available area
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
        y >= 0 && y <= widget.roomLength) return Offset(x, y);
    return null;
  }

  void _onTap(TapUpDetails d) {
    final fp = _toFloor(d.localPosition);
    if (fp == null) { setState(() => _selectedId = null); return; }
    for (final f in _furniture.reversed) {
      if (fp.dx >= f.position.dx &&
          fp.dx <= f.position.dx + f.effectiveWidth &&
          fp.dy >= f.position.dy &&
          fp.dy <= f.position.dy + f.effectiveDepth) {
        if (f.id == _selectedId) {
          Navigator.push(context, MaterialPageRoute(
              builder: (_) => FurnitureModelViewer(item: f)));
        } else {
          setState(() => _selectedId = f.id);
        }
        return;
      }
    }
    setState(() => _selectedId = null);
  }

  void _onDrag(DragUpdateDetails d) {
    if (_selectedId == null) return;
    final idx = _furniture.indexWhere((f) => f.id == _selectedId);
    if (idx < 0) return;
    final f = _furniture[idx];
    final mx = (d.delta.dx / .866025 + d.delta.dy / .5) / (2 * _scale);
    final my = (d.delta.dy / .5 - d.delta.dx / .866025) / (2 * _scale);
    final newPos = Offset(
      (f.position.dx + mx).clamp(0, widget.roomWidth - f.effectiveWidth),
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
    final raw = (f.rotationDeg + deg) % 360;
    final snapped = ((raw / 90).round() * 90) % 360;
    final nr = (snapped < 0 ? snapped + 360 : snapped).toDouble();
    final nw = (nr == 90 || nr == 270) ? f.depthM : f.widthM;
    final nd = (nr == 90 || nr == 270) ? f.widthM : f.depthM;
    final newPos = Offset(
      f.position.dx.clamp(0, widget.roomWidth - nw),
      f.position.dy.clamp(0, widget.roomLength - nd),
    );
    final rotated = FurnitureItem(
      id: f.id, name: f.name, glbAsset: f.glbAsset, emoji: f.emoji,
      type: f.type, widthM: f.widthM, depthM: f.depthM, heightM: f.heightM,
      tileColor: f.tileColor, position: newPos, rotationDeg: nr,
    );
    if (!_overlaps(rotated, _furniture)) {
      setState(() => _furniture[idx] = f.copyWith(rotationDeg: nr, position: newPos));
    }
  }

  void _delete() {
    setState(() {
      _furniture.removeWhere((f) => f.id == _selectedId);
      _selectedId = null;
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
      ((widget.roomWidth - cat.widthM) / 2).clamp(0, widget.roomWidth - cat.widthM),
      ((widget.roomLength - cat.depthM) / 2).clamp(0, widget.roomLength - cat.depthM),
    );
    outer:
    for (double ty = 0; ty <= widget.roomLength - cat.depthM; ty += 0.3) {
      for (double tx = 0; tx <= widget.roomWidth - cat.widthM; tx += 0.3) {
        final candidate = FurnitureItem(
          id: newId, name: cat.name, glbAsset: cat.glbAsset,
          emoji: cat.emoji, type: cat.type,
          widthM: cat.widthM, depthM: cat.depthM, heightM: cat.heightM,
          tileColor: cat.tileColor, position: Offset(tx, ty),
        );
        if (!_overlaps(candidate, _furniture)) {
          freePos = Offset(tx, ty); break outer;
        }
      }
    }
    setState(() {
      _furniture.add(FurnitureItem(
        id: newId, name: cat.name, glbAsset: cat.glbAsset,
        emoji: cat.emoji, type: cat.type,
        widthM: cat.widthM, depthM: cat.depthM, heightM: cat.heightM,
        tileColor: cat.tileColor, topImageAsset: cat.topImageAsset,
        position: freePos,
      ));
      _selectedId = newId;
    });
    Navigator.pop(context);
  }

  Future<void> _saveRoom() async {
    if (_furniture.isEmpty) {
      _snack('Add some furniture first!', isError: true);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final body = {
        'name': '${widget.roomWidth.toStringAsFixed(1)}x'
            '${widget.roomLength.toStringAsFixed(1)} Room',
        'width':  widget.roomWidth,
        'length': widget.roomLength,
        'height': widget.roomHeight,
        'furniture': _furniture.map((f) => {
          'id': f.id,
          'name': f.name,
          'type': f.type.name,
          'x': f.position.dx,
          'y': f.position.dy,
          'rotation': f.rotationDeg,
        }).toList(),
      };
      final res = await http.post(
        Uri.parse('$_baseUrl/rooms/save'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode(body),
      );
      if (res.statusCode == 201) {
        _snack('✅ Room saved successfully!');
      } else {
        _snack('❌ Save failed: ${res.statusCode}', isError: true);
      }
    } catch (e) {
      _snack('❌ Connection error', isError: true);
    }
    if (mounted) setState(() => _isSaving = false);
  }

  Future<void> _showSavedRooms() async {
    setState(() => _isLoading = true);
    List<dynamic> rooms = [];
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/rooms/list'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      if (res.statusCode == 200) {
        rooms = jsonDecode(res.body) as List;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFDDD0C4),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Saved Rooms',
                  style: TextStyle(fontSize: 18,
                      fontWeight: FontWeight.bold, color: _kDark)),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: rooms.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 52, color: _kMedium),
                        SizedBox(height: 8),
                        Text('No saved rooms yet',
                            style: TextStyle(color: _kMedium)),
                      ],
                    ))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    itemCount: rooms.length,
                    itemBuilder: (_, i) {
                      final r = rooms[i] as Map<String, dynamic>;
                      final furnitureList =
                          (r['furniture'] as List?) ?? [];
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
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r['name'] ?? 'Room',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _kDark, fontSize: 14)),
                              Text(
                                '${(r['width'] as num).toStringAsFixed(1)}m × '
                                '${(r['length'] as num).toStringAsFixed(1)}m × '
                                '${(r['height'] as num).toStringAsFixed(1)}m',
                                style: const TextStyle(
                                    color: _kMedium, fontSize: 12)),
                              Text(
                                '${furnitureList.length} furniture item(s)',
                                style: const TextStyle(
                                    color: _kPrimary,
                                    fontSize: 11)),
                            ],
                          )),
                          Row(
  mainAxisSize: MainAxisSize.min,
  children: [
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
  ],
),
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
        // Find matching catalog item by type name
        final cat = _catalog.firstWhere(
          (c) => c.type.name == typeName,
          orElse: () => _catalog.first,
        );
        _furniture.add(FurnitureItem(
          id: m['id'] as String? ?? '${typeName}_0',
          name: m['name'] as String? ?? cat.name,
          glbAsset: cat.glbAsset,
          emoji: cat.emoji,
          type: cat.type,
          widthM: cat.widthM,
          depthM: cat.depthM,
          heightM: cat.heightM,
          tileColor: cat.tileColor,
          position: Offset(
            (m['x'] as num).toDouble(),
            (m['y'] as num).toDouble(),
          ),
          rotationDeg: (m['rotation'] as num).toDouble(),
        ));
      }
    });
    _snack('✅ Room loaded!');
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
          Container(width: 40, height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFDDD0C4),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Add Furniture',
                  style: TextStyle(fontSize: 18,
                      fontWeight: FontWeight.bold, color: _kDark)),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 10,
                mainAxisSpacing: 10, childAspectRatio: 0.82,
              ),
              itemCount: _catalog.length,
              itemBuilder: (_, i) => _LazyModelCard(
                item: _catalog[i], onTap: () => _addFurniture(_catalog[i]),
              ),
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

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kDark,
        title: Text(
          '${widget.roomWidth.toStringAsFixed(1)}m × ${widget.roomLength.toStringAsFixed(1)}m Room',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true, elevation: 0,
        actions: [
          // Load saved rooms
          IconButton(
            icon: _isLoading
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.folder_open, color: Colors.white),
            tooltip: 'Load saved room',
            onPressed: _showSavedRooms,
          ),
          // Save current room
          IconButton(
            icon: _isSaving
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save, color: Colors.white),
            tooltip: 'Save room',
            onPressed: _saveRoom,
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        // Auto-fit room to screen on first build
        if (_screenSize == Size.zero) {
          _screenSize = Size(constraints.maxWidth, constraints.maxHeight);
          _autoFit(_screenSize);
        }
        return Stack(children: [
        GestureDetector(
          onTapUp: _onTap,
          onPanUpdate: _selectedId != null
              ? _onDrag
              : (d) => setState(() => _panOffset += d.delta),
          child: Transform.rotate(
            angle: _roomRotation * math.pi / 180,
            child: CustomPaint(
              painter: _RoomPainter(
                roomWidth: widget.roomWidth, roomLength: widget.roomLength,
                roomHeight: widget.roomHeight,
                furniture: _furniture.map((f) =>
                    f.copyWith(isSelected: f.id == _selectedId)).toList(),
                scale: _scale, pan: _panOffset,
              ),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),

        if (widget.referenceImagePath != null)
          Positioned(left: 14, top: 14,
            child: GestureDetector(
              onTap: () => showDialog(context: context,
                  builder: (_) => Dialog(
                      backgroundColor: Colors.transparent,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(File(widget.referenceImagePath!),
                              fit: BoxFit.contain)))),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kPrimary, width: 2),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: .2), blurRadius: 6)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(widget.referenceImagePath!),
                      width: 58, height: 58, fit: BoxFit.cover),
                ),
              ),
            )),

        Positioned(right: 14, top: 14,
          child: Column(children: [
            _iconBtn(Icons.add,
                () => setState(() => _scale = (_scale * 1.15).clamp(30, 240))),
            const SizedBox(height: 8),
            _iconBtn(Icons.remove,
                () => setState(() => _scale = (_scale / 1.15).clamp(30, 240))),
            const SizedBox(height: 8),
            _iconBtn(Icons.center_focus_strong,
                () => setState(() { _autoFit(_screenSize); })),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: _kDark.withValues(alpha: .7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('View',
                  style: TextStyle(color: Colors.white70, fontSize: 8)),
            ),
            const SizedBox(height: 4),
            _iconBtn(Icons.rotate_left,
                () => setState(() =>
                    _roomRotation = (_roomRotation - 90) % 360)),
            const SizedBox(height: 8),
            _iconBtn(Icons.rotate_right,
                () => setState(() =>
                    _roomRotation = (_roomRotation + 90) % 360)),
          ])),

        if (sel != null)
          Positioned(top: 14, left: 0, right: 0,
            child: Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _kDark.withValues(alpha: .82),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Tap again → full 3D view',
                  style: TextStyle(color: Colors.white, fontSize: 11)),
            ))),

        if (sel != null)
          Positioned(left: 0, right: 0, bottom: 112,
            child: Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: _kDark.withValues(alpha: .93),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: .22), blurRadius: 12)],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _rotBtn(Icons.rotate_left, '90°', () => _rotate(-90)),
                const SizedBox(width: 4),
                _rotBtn(Icons.rotate_left, '45°', () => _rotate(-45), small: true),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => FurnitureModelViewer(item: sel))),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                        color: _kPrimary,
                        borderRadius: BorderRadius.circular(30)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.view_in_ar, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text('View 3D',
                          style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
                _rotBtn(Icons.rotate_right, '45°', () => _rotate(45), small: true),
                const SizedBox(width: 4),
                _rotBtn(Icons.rotate_right, '90°', () => _rotate(90)),
              ]),
            ))),

        Positioned(bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: .07), blurRadius: 12)],
            ),
            child: sel != null
                ? Row(children: [
                    Text(sel.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(sel.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _kDark, fontSize: 15)),
                          Text(
                            '${sel.rotationDeg.toInt()}°  •  '
                            '${sel.effectiveWidth.toStringAsFixed(1)}×'
                            '${sel.effectiveDepth.toStringAsFixed(1)}m',
                            style: const TextStyle(
                                fontSize: 11, color: _kMedium),
                          ),
                        ])),
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
                    Expanded(child: Text(
                      _furniture.isEmpty
                          ? 'Tap "Add Furniture" to start'
                          : 'Tap to select  •  Drag to move  •  Tap again → 3D',
                      style: const TextStyle(color: _kMedium, fontSize: 13),
                    )),
                    ElevatedButton.icon(
                      onPressed: _showPicker,
                      icon: const Icon(Icons.add, size: 15, color: Colors.white),
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
        color: Colors.white, borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: .10), blurRadius: 4)],
      ),
      child: Icon(icon, color: _kDark, size: 20),
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
                    color: Colors.white70, fontSize: small ? 8 : 9)),
          ]),
        ),
      );
}