import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            DatabaseReference ref = FirebaseDatabase.instance.ref("testing");
            ref.set("test app");
          },
          child: const Text("Test Connection"),
        ),
      ),
    );
  }
}
