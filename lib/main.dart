// ignore_for_this_file: avoid_print
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart'; // Tambahan agar bisa Bahasa Indonesia
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'services/mood_storage.dart';

void main() async {
  // 1. Wajib paling atas
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi format tanggal Indonesia (Penting untuk fitur Hari/Tanggal)
  try {
    await initializeDateFormatting('id_ID', null);
  } catch (e) {
    print("⚠️ Gagal memuat format bahasa: $e");
  }

  // 3. Inisialisasi Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase Berhasil Terhubung");
  } catch (e) {
    print("❌ Error Firebase: $e");
  }

  // 4. Load data lokal
  await MoodStorage.loadMood();

  runApp(const MoodifyApp());
}

class MoodifyApp extends StatelessWidget {
  const MoodifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Moodify',
      theme: ThemeData(
        // Menggunakan warna hijau yang lebih fresh untuk aplikasi Mood
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
