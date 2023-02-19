import 'package:cab_driver/shared/utils/page_routes.dart';
import 'package:cab_driver/ui/screens/main_screen/main_screen.dart';
import 'package:flutter/material.dart';

void main() {
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
      initialRoute: PagesRouteData.mainPage,
      routes: {
        PagesRouteData.mainPage: (context) => MainScreen(),
      },
    );
  }
}
