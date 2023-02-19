import 'package:cab_driver/config/firebase_options.dart';
import 'package:cab_driver/shared/utils/page_routes.dart';
import 'package:cab_driver/ui/screens/login_screen/login_screen.dart';
import 'package:cab_driver/ui/screens/main_screen/main_screen.dart';
import 'package:cab_driver/ui/screens/register_screen/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Regular-Font',
        primarySwatch: Colors.blue,
      ),
      initialRoute: PagesRouteData.loginPage,
      routes: {
        PagesRouteData.mainPage: (context) => MainScreen(),
        PagesRouteData.loginPage: (context) => LoginScreen(),
        PagesRouteData.registerPage: (context) => RegisterScreen(),
      },
    );
  }
}
