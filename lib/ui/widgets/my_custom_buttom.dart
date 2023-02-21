import 'package:cab_driver/shared/utils/colors.dart';
import 'package:flutter/material.dart';

class MyCustomButton extends StatelessWidget {
  final Function onPress;
  final String title;
  final Color backgroundColor;
  final Color textColor;

  const MyCustomButton(
      {required this.onPress,
      required this.title,
      super.key,
      this.backgroundColor = MyColors.colorBlue,
      this.textColor = Colors.white});

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
              backgroundColor: backgroundColor,
              foregroundColor: textColor,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)))),
          child: Text(
            title,
            style: TextStyle(
                color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
          )),
    );
  }
}
