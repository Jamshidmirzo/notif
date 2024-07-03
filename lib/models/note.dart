import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  String title;
  String date;
  String id;
  Note({required this.date, required this.id, required this.title});
  factory Note.fromJson(QueryDocumentSnapshot query) {
    return Note(date: query['date'], id: query.id, title: query['title']);
  }
}
