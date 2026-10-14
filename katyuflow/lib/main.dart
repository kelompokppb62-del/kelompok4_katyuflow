import 'package:flutter/material.dart';

// KatyuFlow - versi sederhana (3 layar: daftar project, detail, progress)
// Data masih tiruan, tanpa kuota & poin.

void main() => runApp(const MyApp());

const navy = Color(0xFF14233F);
const teal = Color(0xFF12A594);

// Data satu project
class Project {
  final String id, nama, paket;
  bool diambil; // true kalau sudah diklaim
  Project(this.id, this.nama, this.paket, {this.diambil = false});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KatyuFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: navy),
        scaffoldBackgroundColor: const Color(0xFFF4F7FC),
      ),
      home: const HomePage(),
    );
  }
}

// StatefulWidget = layar yang isinya bisa berubah (misal setelah klaim)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0; // 0 = Jelajahi, 1 = Projectku
  int tahap = 0; // tahap pengerjaan yang sedang aktif
  Project? projectku; // project yang saya klaim (boleh kosong)

  final tahapan = ['Diklaim', 'Sedang dibuat', 'Hampir selesai', 'Menunggu review'];

  final projects = [
    Project('#104', 'Server Gaming Roblox', 'Full Setup'),
    Project('#106', 'Cafe Hangout Discord', 'Basic'),
    Project('#102', 'Server Komunitas RP', 'Premium', diambil: true),
  ];

  void klaim(Project p) {
    // setState = kasih tahu Flutter bahwa data berubah, tampilan digambar ulang
    setState(() {
      p.diambil = true;
      projectku = p;
      tahap = 0;
    });
  }

  // ---------- Layar 1: daftar project ----------
  Widget daftarProject() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Project tersedia',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: navy)),
        const SizedBox(height: 12),
        for (final p in projects)
          Card(
            child: ListTile(
              title: Text('${p.id} · ${p.nama}'),
              subtitle: Text(p.diambil ? 'Sudah diambil' : 'Tersedia — dapat diklaim'),
              trailing: Text(p.paket),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => DetailPage(
                    project: p,
                    onKlaim: () {
                      klaim(p);
                      Navigator.pop(ctx); // kembali ke daftar
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ---------- Layar 3: progress ----------
  Widget progress() {
    if (projectku == null) {
      return const Center(child: Text('Belum ada project. Klaim dulu di tab Jelajahi.'));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Project yang dikerjakan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: navy)),
        const SizedBox(height: 12),
        Card(
          color: navy,
          child: ListTile(
            title: Text('${projectku!.id}  ${projectku!.nama}',
                style: const TextStyle(color: Colors.white)),
            subtitle: const Text('Sedang dikerjakan', style: TextStyle(color: Colors.white70)),
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < tahapan.length; i++)
          ListTile(
            leading: Icon(
              i < tahap ? Icons.check_circle : Icons.radio_button_unchecked,
              color: i <= tahap ? teal : Colors.grey,
            ),
            title: Text(tahapan[i]),
            subtitle: Text(i < tahap ? 'Selesai' : i == tahap ? 'Aktif' : 'Selanjutnya'),
          ),
        const SizedBox(height: 12),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: navy, minimumSize: const Size(0, 50)),
          // onPressed null = tombol nonaktif
          onPressed: tahap < tahapan.length - 1 ? () => setState(() => tahap++) : null,
          child: Text(tahap < tahapan.length - 1
              ? 'Update ke: ${tahapan[tahap + 1]}'
              : 'Menunggu persetujuan owner'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KatyuFlow')),
      body: SafeArea(child: tab == 0 ? daftarProject() : progress()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore_outlined), label: 'Jelajahi'),
          NavigationDestination(icon: Icon(Icons.work_outline), label: 'Projectku'),
        ],
      ),
    );
  }
}

// ---------- Layar 2: detail & klaim ----------
// StatelessWidget = layar yang isinya tetap
class DetailPage extends StatelessWidget {
  final Project project;
  final VoidCallback onKlaim;

  const DetailPage({super.key, required this.project, required this.onKlaim});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail project ${project.id}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.nama,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Paket ${project.paket}'),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Client: Raka / @raka\n'
                    'Tema: Roblox & komunitas santai\n'
                    'Kebutuhan: struktur channel, roles, welcome, automod, ticket dan bot.'),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: navy),
                onPressed: project.diambil ? null : onKlaim,
                child: Text(project.diambil ? 'Sudah diambil' : 'Klaim project sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}