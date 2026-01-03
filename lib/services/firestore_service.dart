import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addMood(String mood, String note) async {
    await _db.collection('moods').add({
      'mood': mood,
      'note': note,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMoods() {
    return _db
        .collection('moods')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
