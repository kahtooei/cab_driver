import 'package:flutter/material.dart';

showSnackBar(String txt, BuildContext context) {
  var snackBar = SnackBar(
    content: Text(txt),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
