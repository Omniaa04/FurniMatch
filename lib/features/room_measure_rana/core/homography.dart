import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

List<double> computeHomography(List<Offset> src, List<Offset> dst) {
  assert(src.length == dst.length && src.length >= 4, 'At least 4 point pairs required');
  final int n = src.length;

  final tSrc = _normalizingTransform(src);
  final tDst = _normalizingTransform(dst);

  final srcN = src.map((p) => _applyT(tSrc, p)).toList(growable: false);
  final dstN = dst.map((p) => _applyT(tDst, p)).toList(growable: false);

  final ata = List.generate(9, (_) => Float64List(9));

  for (int i = 0; i < n; i++) {
    final sx = srcN[i].dx;
    final sy = srcN[i].dy;
    final dx = dstN[i].dx;
    final dy = dstN[i].dy;

    final r1 = Float64List.fromList([-sx, -sy, -1.0, 0.0, 0.0, 0.0, sx * dx, sy * dx, dx]);
    final r2 = Float64List.fromList([0.0, 0.0, 0.0, -sx, -sy, -1.0, sx * dy, sy * dy, dy]);

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        ata[r][c] += r1[r] * r1[c] + r2[r] * r2[c];
      }
    }
  }

  final evecs = _jacobiEigen(ata);

  int minIdx = 0;
  double minVal = ata[0][0];
  for (int i = 1; i < 9; i++) {
    if (ata[i][i] < minVal) {
      minVal = ata[i][i];
      minIdx = i;
    }
  }

  final hNorm = [
    [evecs[0][minIdx], evecs[1][minIdx], evecs[2][minIdx]],
    [evecs[3][minIdx], evecs[4][minIdx], evecs[5][minIdx]],
    [evecs[6][minIdx], evecs[7][minIdx], evecs[8][minIdx]],
  ];

  final tDstInv = _invertT(tDst);
  final temp = _mul3x3(tDstInv, hNorm);
  final hFinal = _mul3x3(temp, tSrc);

  final scale = hFinal[2][2];
  if (scale.abs() > 1e-15) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        hFinal[i][j] /= scale;
      }
    }
  }

  return [
    hFinal[0][0], hFinal[0][1], hFinal[0][2],
    hFinal[1][0], hFinal[1][1], hFinal[1][2],
    hFinal[2][0], hFinal[2][1], hFinal[2][2],
  ];
}

List<Float64List> _jacobiEigen(List<Float64List> m) {
  final n = 9;
  final v = List.generate(n, (i) {
    final row = Float64List(n);
    row[i] = 1.0;
    return row;
  });

  const int maxIter = 100;
  for (int iter = 0; iter < maxIter; iter++) {
    int p = 0, q = 1;
    double maxVal = m[0][1].abs();
    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        if (m[i][j].abs() > maxVal) {
          maxVal = m[i][j].abs();
          p = i;
          q = j;
        }
      }
    }

    if (maxVal < 1e-12) break;

    final diff = m[q][q] - m[p][p];
    double t;
    if (m[p][q].abs() < 1e-15) {
      t = 0;
    } else {
      final theta = diff / (2.0 * m[p][q]);
      t = 1.0 / (theta.abs() + sqrt(theta * theta + 1.0));
      if (theta < 0) t = -t;
    }

    final c = 1.0 / sqrt(t * t + 1.0);
    final s = t * c;

    final m_pp = m[p][p];
    final m_qq = m[q][q];
    final m_pq = m[p][q];

    m[p][p] = c * c * m_pp - 2.0 * s * c * m_pq + s * s * m_qq;
    m[q][q] = s * s * m_pp + 2.0 * s * c * m_pq + c * c * m_qq;
    m[p][q] = m[q][p] = 0.0;

    for (int i = 0; i < n; i++) {
      if (i != p && i != q) {
        final m_ip = m[i][p];
        final m_iq = m[i][q];
        m[i][p] = m[p][i] = c * m_ip - s * m_iq;
        m[i][q] = m[q][i] = s * m_ip + c * m_iq;
      }
      final v_ip = v[i][p];
      final v_iq = v[i][q];
      v[i][p] = c * v_ip - s * v_iq;
      v[i][q] = s * v_ip + c * v_iq;
    }
  }

  return v;
}

List<List<double>> _normalizingTransform(List<Offset> pts) {
  double cx = 0, cy = 0;
  for (final p in pts) { cx += p.dx; cy += p.dy; }
  cx /= pts.length;
  cy /= pts.length;

  double avgDist = 0;
  for (final p in pts) {
    final dx = p.dx - cx;
    final dy = p.dy - cy;
    avgDist += sqrt(dx * dx + dy * dy);
  }
  avgDist /= pts.length;

  final s = avgDist > 1e-15 ? sqrt(2) / avgDist : 1.0;
  return [
    [s, 0, -s * cx],
    [0, s, -s * cy],
    [0, 0, 1],
  ];
}

Offset _applyT(List<List<double>> t, Offset p) {
  return Offset(
    t[0][0] * p.dx + t[0][1] * p.dy + t[0][2],
    t[1][0] * p.dx + t[1][1] * p.dy + t[1][2],
  );
}

List<List<double>> _invertT(List<List<double>> t) {
  final s = t[0][0];
  final invS = s.abs() > 1e-15 ? 1.0 / s : 1.0;
  return [
    [invS, 0, -t[0][2] * invS],
    [0, invS, -t[1][2] * invS],
    [0, 0, 1],
  ];
}

List<List<double>> _mul3x3(List<List<double>> a, List<List<double>> b) {
  final r = List.generate(3, (_) => List.filled(3, 0.0));
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      r[i][j] = a[i][0] * b[0][j] + a[i][1] * b[1][j] + a[i][2] * b[2][j];
    }
  }
  return r;
}

Offset applyHomography(List<double> h, Offset p) {
  final w = h[6] * p.dx + h[7] * p.dy + h[8];
  if (w.abs() < 1e-15) return Offset.zero;
  final x = (h[0] * p.dx + h[1] * p.dy + h[2]) / w;
  final y = (h[3] * p.dx + h[4] * p.dy + h[5]) / w;
  return Offset(x, y);
}

double measureDistance(List<double> h, Offset p1, Offset p2) {
  final rw1 = applyHomography(h, p1);
  final rw2 = applyHomography(h, p2);
  final dx = rw1.dx - rw2.dx;
  final dy = rw1.dy - rw2.dy;
  return sqrt(dx * dx + dy * dy);
}