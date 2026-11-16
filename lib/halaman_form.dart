import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'planner_model.dart';

class HalamanForm extends StatefulWidget {
  const HalamanForm({super.key});

  @override
  State<HalamanForm> createState() => _HalamanFormState();
}

class _HalamanFormState extends State<HalamanForm> {
  final _kunci = GlobalKey<FormState>();
  late final TextEditingController _judul;
  late final TextEditingController _mataKuliah;
  DateTime? _tenggat; // ephemeral state: pilihan tanggal sementara
  bool _tenggatKosong = false;

  @override
  void initState() {
    super.initState();
    // Dibuat sekali, saat State dibuat
    _judul = TextEditingController();
    _mataKuliah = TextEditingController();
  }

  @override
  void dispose() {
    // Wajib: controller dibuang agar tidak bocor
    _judul.dispose();
    _mataKuliah.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final sekarang = DateTime.now();
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tenggat ?? sekarang,
      firstDate: DateTime(sekarang.year - 1),
      lastDate: DateTime(sekarang.year + 5),
    );
    // Setelah await, widget mungkin sudah ditutup
    if (!mounted || hasil == null) return;
    setState(() {
      _tenggat = hasil;
      _tenggatKosong = false;
    });
  }

  void _simpan() {
    final valid = _kunci.currentState!.validate();
    if (_tenggat == null) {
      setState(() => _tenggatKosong = true);
      return;
    }
    if (!valid) return;

    context.read<PlannerModel>().tambah(
          judul: _judul.text,
          mataKuliah: _mataKuliah.text,
          tenggat: _tenggat!,
        );
    context.pop(); // kembali ke daftar
  }

  String? _wajibIsi(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null;

  @override
  Widget build(BuildContext context) {
    final skema = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Tugas')),
      body: Form(
        key: _kunci,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judul,
              decoration: const InputDecoration(
                labelText: 'Judul tugas',
                border: OutlineInputBorder(),
              ),
              validator: _wajibIsi,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mataKuliah,
              decoration: const InputDecoration(
                labelText: 'Mata kuliah',
                border: OutlineInputBorder(),
              ),
              validator: _wajibIsi,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pilihTanggal,
              icon: const Icon(Icons.event),
              label: Text(
                _tenggat == null
                    ? 'Pilih tenggat'
                    : 'Tenggat: ${_tenggat!.tanggal}',
              ),
            ),
            if (_tenggatKosong)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  'Tenggat wajib dipilih',
                  style: TextStyle(color: skema.error, fontSize: 12),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _simpan,
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
