class Mood {
  String? id; // Tambahkan ID untuk sinkronisasi Firebase
  final String emoji;
  final String note;
  final DateTime date;

  Mood({
    this.id, // ID boleh kosong saat baru dibuat lokal
    required this.emoji,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id, // Simpan ID ke lokal juga
    'emoji': emoji,
    'note': note,
    'date': date.toIso8601String(),
  };

  factory Mood.fromJson(Map<String, dynamic> json) => Mood(
    id: json['id'], // Ambil ID dari data yang disimpan
    emoji: json['emoji'],
    note: json['note'],
    date: DateTime.parse(json['date']),
  );
}
