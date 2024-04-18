import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:herovictoria_02/main_page.dart';
//import 'Screens/index.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
      /*title: 'Material App',
      initialRoute: '/',
      routes: {
        '/':(context) =>const LoginPage(),
        '/menu':(context) => MenuPage(),
      },
      onGenerateRoute:((settings) {
        return MaterialPageRoute(
          builder: (context) => const LoginPage(),
          );
        }
      ),*/
    );
  }
}

