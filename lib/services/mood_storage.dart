// ignore_for_this_file: avoid_print
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mood.dart';

class MoodStorage {
  static const String key = 'moods';
  static List<Mood> moods = [];

  // Instance untuk koneksi ke Cloud Firestore
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Fungsi memuat data
  static Future<void> loadMood() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);

    if (data != null) {
      final List decoded = jsonDecode(data);
      moods = decoded.map((e) => Mood.fromJson(e)).toList();
    }
    await syncFromFirestore();
  }

  // FITUR: Sinkronisasi dari Firebase ke HP
  static Future<void> syncFromFirestore() async {
    try {
      final snapshot = await _firestore
          .collection('moods')
          .orderBy('date', descending: false)
          .get();

      // Kita buat list kosong dulu untuk menampung data segar dari cloud
      List<Mood> cloudMoods = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        cloudMoods.add(
          Mood(
            // PENTING: Pastikan model Mood kamu punya field 'id' untuk menampung doc.id
            id: doc.id,
            emoji: data['emoji'] ?? '😊',
            note: data['note'] ?? '',
            date: DateTime.parse(data['date']),
          ),
        );
      }

      moods = cloudMoods;
      await saveLocal();
      print("✅ SINKRONISASI CLOUD BERHASIL: ${moods.length} data dimuat");
    } catch (e) {
      print("⚠️ SINKRONISASI GAGAL (Mungkin offline): $e");
    }
  }

  // 2. Fungsi simpan ke memori internal HP
  static Future<void> saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(moods.map((m) => m.toJson()).toList());
    await prefs.setString(key, encoded);
  }

  // 3. Fungsi Tambah Mood (Lokal + Firebase)
  static Future<void> addMood(Mood mood) async {
    try {
      // Kita kirim ke Firebase dulu untuk mendapatkan ID-nya
      DocumentReference docRef = await _firestore.collection('moods').add({
        'emoji': mood.emoji,
        'note': mood.note,
        'date': mood.date.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Simpan ke list lokal lengkap dengan ID dari Firebase tadi
      mood.id = docRef.id;
      moods.add(mood);
      await saveLocal();

      print("✅ DATA BERHASIL TERKIRIM KE FIREBASE");
    } catch (e) {
      // Jika gagal cloud, tetap simpan lokal agar tidak hilang
      moods.add(mood);
      await saveLocal();
      print("❌ GAGAL KIRIM KE FIREBASE (Tersimpan Lokal): $e");
    }
  }

  // 4. PERBAIKAN: Fungsi Hapus Mood (Sekarang Sinkron ke Firebase)
  static Future<void> deleteMood(int index) async {
    if (index >= 0 && index < moods.length) {
      // Ambil ID dokumen sebelum dihapus dari list
      String? docId = moods[index].id;

      // 1. Hapus dari list lokal agar UI cepat berubah
      moods.removeAt(index);
      await saveLocal();

      // 2. Hapus dari Firebase jika ID ditemukan
      if (docId != null && docId.isNotEmpty) {
        try {
          await _firestore.collection('moods').doc(docId).delete();
          print("✅ DATA TERHAPUS DARI FIREBASE");
        } catch (e) {
          print("❌ GAGAL HAPUS DI FIREBASE: $e");
        }
      }
    }
  }
}
