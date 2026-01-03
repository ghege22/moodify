import 'package:flutter/material.dart';
import '../services/mood_storage.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = <String, int>{};
    int totalMoods = 0;

    for (var m in MoodStorage.moods) {
      counter[m.emoji] = (counter[m.emoji] ?? 0) + 1;
    }

    for (var count in counter.values) {
      totalMoods += count;
    }

    if (counter.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada data statistik',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai tambah mood untuk melihat statistik',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    // PERBAIKAN: Menghapus .toList() yang tidak perlu di dalam spread operator nanti
    final entries = counter.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      color: const Color(0xFFF1F8E9),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  // PERBAIKAN: withOpacity -> withValues
                  color: Colors.green.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Mood',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$totalMoods',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF388E3C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Statistik perasaan berdasarkan emoji',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Stats List
          // PERBAIKAN: Langsung mapping entries tanpa tambahan .toList() di akhir spread
          ...entries.map(
            (e) {
              final percentage = (e.value / totalMoods * 100).toStringAsFixed(
                1,
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      // PERBAIKAN: withOpacity -> withValues
                      color: Colors.green.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(e.key, style: const TextStyle(fontSize: 24)),
                  ),
                  title: Text(
                    // PERBAIKAN: Menghapus braces yang tidak perlu ${} -> $
                    _getMoodLabel(e.key),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: LinearProgressIndicator(
                      value: e.value / totalMoods,
                      backgroundColor: Colors.grey[200],
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 6,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${e.value}x',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF388E3C),
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            },
          ), // PERBAIKAN: Menghapus .toList() di sini karena spread operator (...) sudah cukup
        ],
      ),
    );
  }

  String _getMoodLabel(String emoji) {
    switch (emoji) {
      case '😊':
        return 'Senang';
      case '😐':
        return 'Biasa saja';
      case '😔':
        return 'Sedih';
      case '😡':
        return 'Marah';
      case '🥱':
        return 'Lelah';
      default:
        // PERBAIKAN: Menghapus braces yang tidak perlu
        return 'Mood $emoji';
    }
  }
}
