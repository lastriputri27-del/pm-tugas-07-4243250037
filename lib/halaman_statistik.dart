import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'planner_model.dart';

class HalamanStatistik extends StatelessWidget {
  const HalamanStatistik({super.key});

  @override
  Widget build(BuildContext context) {
    // watch: otomatis ikut berubah saat tugas ditambah/diselesaikan/dihapus
    final p = context.watch<PlannerModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Kartu(label: 'Total', nilai: '${p.total}'),
                _Kartu(label: 'Selesai', nilai: '${p.jumlahSelesai}'),
                _Kartu(label: 'Aktif', nilai: '${p.jumlahAktif}'),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Persentase selesai: ${p.persentaseSelesai.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: p.persentaseSelesai / 100,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      ),
    );
  }
}

class _Kartu extends StatelessWidget {
  const _Kartu({required this.label, required this.nilai});

  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Text(nilai, style: Theme.of(context).textTheme.headlineMedium),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
