import 'package:flutter_test/flutter_test.dart';
import 'package:pm_tugas_07_4243250037/planner_model.dart';

void main() {
  final besok = DateTime(2026, 11, 20);

  PlannerModel modelDenganDuaTugas() {
    final m = PlannerModel();
    m.tambah(judul: 'CJR', mataKuliah: 'Pengenalan Pola', tenggat: besok);
    m.tambah(judul: 'Tugas Rutin 7', mataKuliah: 'Pemrograman Mobile', tenggat: besok);
    return m;
  }

  test('tambah menambah tugas dan memberi notifikasi', () {
    final m = PlannerModel();
    var notifikasi = 0;
    m.addListener(() => notifikasi++);

    m.tambah(judul: '  CJR ', mataKuliah: 'Pengenalan Pola', tenggat: besok);

    expect(m.total, 1);
    expect(m.jumlahAktif, 1);
    expect(m.tugas.first.judul, 'CJR'); // spasi dipangkas
    expect(notifikasi, 1);
  });

  test('tandaiSelesai membalik status dan memperbarui statistik', () {
    final m = modelDenganDuaTugas();
    final id = m.tugas.first.id;

    m.tandaiSelesai(id);
    expect(m.jumlahSelesai, 1);
    expect(m.jumlahAktif, 1);
    expect(m.persentaseSelesai, 50);

    m.tandaiSelesai(id); // dibalik lagi
    expect(m.jumlahSelesai, 0);
  });

  test('hapus menghilangkan tugas; id tidak dikenal diabaikan', () {
    final m = modelDenganDuaTugas();
    var notifikasi = 0;
    m.addListener(() => notifikasi++);

    m.hapus(m.tugas.first.id);
    expect(m.total, 1);
    expect(notifikasi, 1);

    m.hapus(999); // tidak ada -> tanpa notifikasi
    expect(m.total, 1);
    expect(notifikasi, 1);
  });

  test('persentase 0 saat belum ada tugas dan daftar terurut tenggat', () {
    final m = PlannerModel();
    expect(m.persentaseSelesai, 0);

    m.tambah(judul: 'B', mataKuliah: 'X', tenggat: DateTime(2026, 12, 1));
    m.tambah(judul: 'A', mataKuliah: 'X', tenggat: DateTime(2026, 11, 1));
    expect(m.tugas.map((t) => t.judul).toList(), ['A', 'B']);
  });
}
