import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/mood_storage.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? _selectedEmojiFilter;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 1. FUNGSI BARU: Mendapatkan warna berdasarkan emoji dominan
  Color _getThemeColor(String emoji) {
    switch (emoji) {
      case '😇':
        return Colors.teal;
      case '😊':
        return Colors.green;
      case '😐':
        return Colors.orange;
      case '😢':
        return Colors.blue;
      case '😡':
        return Colors.red;
      default:
        return const Color(0xFF2E7D32); // Warna hijau default
    }
  }

  String _getMostFrequentEmoji() {
    if (MoodStorage.moods.isEmpty) return "-";
    var counts = <String, int>{};
    for (var mood in MoodStorage.moods) {
      counts[mood.emoji] = (counts[mood.emoji] ?? 0) + 1;
    }
    var sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.first.key;
  }

  String _getMoodInsight(String emoji) {
    switch (emoji) {
      case '😇':
        return "Wah, hatimu sedang tenang sekali. Pertahankan kedamaian ini!";
      case '😊':
        return "Kamu terlihat sangat positif! Bagikan energi baikmu ya.";
      case '😐':
        return "Hari yang datar? Tidak apa-apa, istirahatlah sejenak.";
      case '😢':
        return "Sedang sedih ya? Kamu sudah melakukan yang terbaik hari ini.";
      case '😡':
        return "Tarik napas dalam-dalam... Jangan biarkan amarah menguasai harimu.";
      case '-':
        return "Mulai catat mood kamu hari ini untuk melihat insight menarik!";
      default:
        return "Tetap semangat dan selalu jaga kesehatan mentalmu ya!";
    }
  }

  // Widget Search Bar
  Widget _buildSearchBar(Color themeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: "Cari catatan mood...",
          prefixIcon: Icon(Icons.search, color: themeColor),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = "");
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Color themeColor) {
    final dominantEmoji = _getMostFrequentEmoji();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.1), // Shadow mengikuti warna tema
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                "Total Mood",
                MoodStorage.moods.length.toString(),
                Icons.bar_chart_rounded,
                themeColor,
              ),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              _buildSummaryItem(
                "Dominan",
                dominantEmoji,
                Icons.auto_awesome,
                themeColor,
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: themeColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _getMoodInsight(dominantEmoji),
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color themeColor,
  ) {
    return Column(
      children: [
        Icon(icon, size: 22, color: themeColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildEmojiFilter(Color themeColor) {
    final uniqueEmojis = MoodStorage.moods.map((m) => m.emoji).toSet().toList();
    if (uniqueEmojis.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: uniqueEmojis.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildFilterChip("Semua", _selectedEmojiFilter == null, () {
              setState(() => _selectedEmojiFilter = null);
            }, themeColor);
          }
          final emoji = uniqueEmojis[index - 1];
          return _buildFilterChip(emoji, _selectedEmojiFilter == emoji, () {
            setState(() => _selectedEmojiFilter = emoji);
          }, themeColor);
        },
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    Color themeColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: themeColor.withOpacity(0.2),
        checkmarkColor: themeColor,
        labelStyle: TextStyle(
          color: isSelected ? themeColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: isSelected ? themeColor : Colors.grey[300]!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan warna tema berdasarkan mood dominan saat ini
    final String dominant = _getMostFrequentEmoji();
    final Color dynamicColor = _getThemeColor(dominant);

    List moods = MoodStorage.moods.reversed.toList();
    if (_selectedEmojiFilter != null) {
      moods = moods.where((m) => m.emoji == _selectedEmojiFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      moods = moods
          .where(
            (m) => m.note.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await MoodStorage.syncFromFirestore();
        if (mounted) setState(() {});
      },
      color: dynamicColor,
      child: Container(
        color: dynamicColor.withOpacity(
          0.05,
        ), // Background tipis mengikuti tema
        child: Column(
          children: [
            const SizedBox(height: 8),
            if (MoodStorage.moods.isNotEmpty) ...[
              _buildSummaryCard(dynamicColor),
              _buildSearchBar(dynamicColor),
              _buildEmojiFilter(dynamicColor),
            ],
            Expanded(
              child: moods.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        alignment: Alignment.center,
                        child: _buildEmptyState(),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: moods.length,
                      itemBuilder: (context, index) =>
                          _buildMoodItem(moods[index], dynamicColor),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodItem(dynamic mood, Color themeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getThemeColor(
              mood.emoji,
            ).withOpacity(0.1), // Warna item list sesuai mood aslinya
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(mood.emoji, style: const TextStyle(fontSize: 24)),
        ),
        title: Text(
          mood.note.isEmpty ? 'Tanpa catatan' : mood.note,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          DateFormat('EEEE, d MMM • HH:mm', 'id_ID').format(mood.date),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline,
            color: Colors.redAccent,
            size: 20,
          ),
          onPressed: () async {
            bool? confirm = await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Hapus Catatan?"),
                content: const Text("Data akan dihapus dari daftar."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text("Batal"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(
                      "Hapus",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              int originalIndex = MoodStorage.moods.indexOf(mood);
              await MoodStorage.deleteMood(originalIndex);
              setState(() {});
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(
          _searchQuery.isNotEmpty
              ? 'Tidak ada hasil untuk "$_searchQuery"'
              : 'Belum ada catatan mood',
          style: TextStyle(color: Colors.grey[500]),
        ),
      ],
    );
  }
}
