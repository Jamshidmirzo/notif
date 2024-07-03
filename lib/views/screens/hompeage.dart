import 'package:flutter/material.dart';
import 'package:notif/models/note.dart';
import 'package:notif/services/local_notifiction_serivce.dart';
import 'package:notif/services/notesservice.dart';
import 'package:notif/views/widgets/adwidget.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  void addNote() {
    showDialog(
      context: context,
      builder: (context) {
        return Adwidget();
      },
    );
  }

  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    final notesservice = context.watch<Notesservice>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes with Notification"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNote,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Center(
          child: StreamBuilder(
            stream: notesservice.getNotes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No notes available!"),
                );
              }
              final notes = snapshot.data!.docs;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!LocalNotifictionSerivce.notificationEnabled)
                    const Center(
                      child: Text(
                        'Please enable notifications',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final noteData = notes[index];
                        final note = Note.fromJson(noteData);
                        return ListTile(
                          leading: ZoomTapAnimation(
                            onTap: () {
                              isTapped = true;
                              setState(() {});
                            },
                            child: isTapped
                                ? const Icon(Icons.done_rounded)
                                : const Icon(Icons.circle),
                          ),
                          title: Text(
                            note.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                fontStyle: FontStyle.normal),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ZoomTapAnimation(
                                onTap: () {},
                                child: const Icon(Icons.edit),
                              ),
                              const SizedBox(width: 10),
                              ZoomTapAnimation(
                                onTap: () {
                                  notesservice.deleteNotwe(note.id);
                                },
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
