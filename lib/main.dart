import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'halaman_daftar.dart';
import 'halaman_form.dart';
import 'halaman_statistik.dart';
import 'planner_model.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (_) => PlannerModel(), // satu objek untuk seluruh aplikasi
        child: const PlannerApp(),
      ),
    );

final _router = GoRouter(
  initialLocation: '/daftar',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) =>
          KerangkaNavigasi(navigationShell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/daftar',
            builder: (context, state) => const HalamanDaftar(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/statistik',
            builder: (context, state) => const HalamanStatistik(),
          ),
        ]),
      ],
    ),
    // Di luar shell: form tampil menutupi bar navigasi
    GoRoute(
      path: '/tambah',
      builder: (context, state) => const HalamanForm(),
    ),
  ],
);

class PlannerApp extends StatelessWidget {
  const PlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Planner Tugas Kuliah',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

class KerangkaNavigasi extends StatelessWidget {
  const KerangkaNavigasi({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    // select: widget ini dibangun ulang HANYA bila jumlahItem aktif berubah
    final aktif = context.select((PlannerModel m) => m.jumlahAktif);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            icon: Badge.count(
              count: aktif,
              isLabelVisible: aktif > 0,
              child: const Icon(Icons.checklist_outlined),
            ),
            selectedIcon: Badge.count(
              count: aktif,
              isLabelVisible: aktif > 0,
              child: const Icon(Icons.checklist),
            ),
            label: 'Tugas',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Statistik',
          ),
        ],
      ),
    );
  }
}
