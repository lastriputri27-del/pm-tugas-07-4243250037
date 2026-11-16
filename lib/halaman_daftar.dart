import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'planner_model.dart';

enum FilterTugas { semua, aktif, selesai }

class HalamanDaftar extends StatefulWidget {
  const HalamanDaftar({super.key});

  @override
  State<HalamanDaftar> createState() => _HalamanDaftarState();
}

class _HalamanDaftarState extends State<HalamanDaftar> {
  // EPHEMERAL STATE: filter hanya dipakai halaman ini -> cukup setState
  FilterTugas _filter = FilterTugas.semua;

  static const _label = {
    FilterTugas.semua: 'Semua',
    FilterTugas.aktif: 'Aktif',
    FilterTugas.selesai: 'Selesai',
  };

  bool _lolos(TugasKuliah t) => switch (_filter) {
        FilterTugas.semua => true,
        FilterTugas.aktif => !t.selesai,
        FilterTugas.selesai => t.selesai,
      };

  @override
  Widget build(BuildContext context) {
    // watch: daftar dibangun ulang setiap state bersama berubah
    final daftar = context.watch<PlannerModel>().tugas.where(_lolos).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Planner Tugas Kuliah')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              children: [
                for (final f in FilterTugas.values)
                  FilterChip(
                    label: Text(_label[f]!),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
              ],
            ),
          ),
          Expanded(
            child: daftar.isEmpty
                ? const Center(child: Text('Tidak ada tugas'))
                : ListView.separated(
                    itemCount: daftar.length,
                    separatorBuilder: (context, i) =>
                        const Divider(height: 1),
                    itemBuilder: (context, i) => _ItemTugas(tugas: daftar[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tambah'),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}

class _ItemTugas extends StatelessWidget {
  const _ItemTugas({required this.tugas});

  final TugasKuliah tugas;

  @override
  Widget build(BuildContext context) {
    final skema = Theme.of(context).colorScheme;
    final hariIni = DateUtils.dateOnly(DateTime.now());
    final terlambat = !tugas.selesai && tugas.tenggat.isBefore(hariIni);

    return ListTile(
      leading: Checkbox(
        value: tugas.selesai,
        // read di dalam callback: tidak perlu mendengarkan
        onChanged: (_) => context.read<PlannerModel>().tandaiSelesai(tugas.id),
      ),
      title: Text(
        tugas.judul,
        style: TextStyle(
          decoration: tugas.selesai ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        '${tugas.mataKuliah} · ${tugas.tenggat.tanggal}'
        '${terlambat ? ' (terlambat)' : ''}',
        style: TextStyle(color: terlambat ? skema.error : null),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Hapus',
        onPressed: () => context.read<PlannerModel>().hapus(tugas.id),
      ),
    );
  }
}
