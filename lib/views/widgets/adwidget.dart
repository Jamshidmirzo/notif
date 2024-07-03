import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notif/services/notesservice.dart';
import 'package:notif/services/local_notifiction_serivce.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzl;

class Adwidget extends StatefulWidget {
  const Adwidget({super.key});

  @override
  State<Adwidget> createState() => _AdwidgetState();
}

class _AdwidgetState extends State<Adwidget> {
  final notecontroller = TextEditingController();
  final timecontroller = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool isLoading = false;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        timecontroller.text = _selectedTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<Notesservice>();
    return AlertDialog(
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Back"),
        ),
        ElevatedButton(
          onPressed: () async {
            if (notecontroller.text.isNotEmpty &&
                timecontroller.text.isNotEmpty) {
              final now = DateTime.now();
              final selectedDateTime = DateTime(
                now.year,
                now.month,
                now.day,
                _selectedTime.hour,
                _selectedTime.minute,
              );

              await controller.addNote(
                notecontroller.text,
                selectedDateTime.toIso8601String(),
              );


              final notificationId = now.second * 1000 + now.millisecond;


              final currentDateTime = tz.TZDateTime.now(tz.local);
              final notificationScheduledTime = tz.TZDateTime(
                tz.local,
                selectedDateTime.year,
                selectedDateTime.month,
                selectedDateTime.day,
                selectedDateTime.hour,
                selectedDateTime.minute,
              ).subtract(Duration(minutes: 5));

              if (notificationScheduledTime.isBefore(currentDateTime)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        "Selected time is in the past. Please select a future time."),
                  ),
                );
              } else {

                LocalNotifictionSerivce.scheduleNotification(
                  id: notificationId,
                  title: 'Task Reminder',
                  body: 'You have a task due in 5 minutes!',
                  taskDueTime: selectedDateTime,
                );

                notecontroller.clear();
                timecontroller.clear();
                Navigator.pop(context);
              }
            }
          },
          child: const Text("Done"),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: notecontroller,
            decoration: InputDecoration(
              labelText: 'Note',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: timecontroller,
            readOnly: true,
            onTap: () => _selectTime(context),
            decoration: InputDecoration(
              labelText: 'Select Time',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
