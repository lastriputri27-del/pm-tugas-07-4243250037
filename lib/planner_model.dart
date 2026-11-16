import 'package:flutter/foundation.dart';

/// Model data satu tugas kuliah (immutable; ubah lewat copyWith).
class TugasKuliah {
  const TugasKuliah({
    required this.id,
    required this.judul,
    required this.mataKuliah,
    required this.tenggat,
    this.selesai = false,
  });

  final int id;
  final String judul;
  final String mataKuliah;
  final DateTime tenggat;
  final bool selesai;

  TugasKuliah copyWith({bool? selesai}) => TugasKuliah(
        id: id,
        judul: judul,
        mataKuliah: mataKuliah,
        tenggat: tenggat,
        selesai: selesai ?? this.selesai,
      );
}

/// Format tanggal sederhana tanpa paket intl, contoh: 16 Nov 2026.
extension FormatTanggal on DateTime {
  String get tanggal {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '$day ${bulan[month - 1]} $year';
  }
}

/// State BERSAMA (app state): dipakai halaman daftar, form, statistik,
/// dan badge navigasi. Tidak mengimpor pustaka UI agar mudah diuji.
class PlannerModel extends ChangeNotifier {
  final List<TugasKuliah> _daftar = []; // privat: ubah hanya lewat method
  int _idBerikut = 1;

  /// Daftar tugas terurut berdasarkan tenggat terdekat (tidak dapat diubah).
  List<TugasKuliah> get tugas {
    final salinan = List<TugasKuliah>.of(_daftar)
      ..sort((a, b) => a.tenggat.compareTo(b.tenggat));
    return List.unmodifiable(salinan);
  }

  int get total => _daftar.length;
  int get jumlahSelesai => _daftar.where((t) => t.selesai).length;
  int get jumlahAktif => total - jumlahSelesai;

  /// Persentase tugas selesai (0-100); 0 bila belum ada tugas.
  double get persentaseSelesai =>
      total == 0 ? 0 : jumlahSelesai / total * 100;

  void tambah({
    required String judul,
    required String mataKuliah,
    required DateTime tenggat,
  }) {
    _daftar.add(TugasKuliah(
      id: _idBerikut++,
      judul: judul.trim(),
      mataKuliah: mataKuliah.trim(),
      tenggat: tenggat,
    ));
    notifyListeners(); // beri tahu semua widget yang mendengarkan
  }

  /// Membalik status selesai/aktif suatu tugas.
  void tandaiSelesai(int id) {
    final i = _daftar.indexWhere((t) => t.id == id);
    if (i == -1) return;
    _daftar[i] = _daftar[i].copyWith(selesai: !_daftar[i].selesai);
    notifyListeners();
  }

  void hapus(int id) {
    final sebelum = _daftar.length;
    _daftar.removeWhere((t) => t.id == id);
    if (_daftar.length != sebelum) notifyListeners();
  }
}
