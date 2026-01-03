import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Penting untuk format tanggal
import 'add_mood_screen.dart';
import 'history_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Daftar halaman utama
  final List<Widget> _pages = const [HistoryScreen(), StatsScreen()];

  /// Widget Header untuk menampilkan Hari, Tanggal, dan Bulan
  Widget _buildDateHeader() {
    DateTime sekarang = DateTime.now();

    // Format: Senin / Selasa / dsb
    String formatHari = DateFormat('EEEE', 'id_ID').format(sekarang);
    // Format: 29 Desember 2025
    String formatTanggal = DateFormat('d MMMM yyyy', 'id_ID').format(sekarang);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      color: const Color(0xFFF1F8E9), // Background hijau sangat muda
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatHari,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32), // Hijau tua
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatTanggal,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Divider pengganti greenOffset yang error tadi
          Divider(thickness: 1.5, color: Colors.green.withValues(alpha: 0.2)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Moodify',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFF1F8E9),
        child: Column(
          children: [
            // Header tanggal hanya tampil di tab Riwayat (index 0)
            if (_selectedIndex == 0) _buildDateHeader(),

            // Konten halaman (History atau Stats)
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF388E3C),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 30),
        onPressed: () async {
          // Berpindah ke halaman tambah mood
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMoodScreen()),
          );

          // Refresh tampilan saat kembali agar data terbaru muncul
          if (!mounted) return;
          setState(() {});
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF388E3C),
          unselectedItemColor: Colors.grey[500],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_rounded),
              label: 'Statistik',
            ),
          ],
        ),
      ),
    );
  }
}
