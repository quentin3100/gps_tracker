import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gps_tracker/views/activity.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //Permettre uniquement l'orientation en mode portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Activités sportives',
      home:   ActivityPage(),
    );
    
  }
}