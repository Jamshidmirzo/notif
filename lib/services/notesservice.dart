import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Notesservice extends ChangeNotifier {
  final notes = FirebaseFirestore.instance.collection('notes');
  Stream<QuerySnapshot> getNotes() async* {
    yield* notes.snapshots();
  }

  Future<void> addNote(String title, String date) async {
    await notes.add({'title': title, 'date': date});
  }

  Future<void> deleteNotwe(String id) async {
    await notes.doc(id).delete();
  }
}
