import 'package:cab_driver/shared/utils/colors.dart';
import 'package:flutter/material.dart';

class AvailabilityButton extends StatelessWidget {
  final Function onPress;
  final String title;

  const AvailabilityButton(
      {required this.onPress, required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      // width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
          onPressed: () {
            onPress();
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.colorOrange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 25),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)))),
          child: Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          )),
    );
  }
}
