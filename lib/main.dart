import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notif/firebase_options.dart';
import 'package:notif/services/local_notifiction_serivce.dart';
import 'package:notif/services/notesservice.dart';
import 'package:notif/views/screens/hompeage.dart';
import 'package:provider/provider.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotifictionSerivce.requestPermission();
  await LocalNotifictionSerivce.start();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        return Notesservice();
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Homepage(),
      ),
    );
  }
}
