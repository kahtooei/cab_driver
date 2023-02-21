import 'package:cab_driver/shared/utils/colors.dart';
import 'package:cab_driver/ui/widgets/my_custom_buttom.dart';
import 'package:flutter/material.dart';

class ConfirmSheet extends StatelessWidget {
  final bool isAvailable;
  final Function onPress;
  const ConfirmSheet(
      {super.key, required this.isAvailable, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(color: Colors.black38, blurRadius: 5, spreadRadius: 0.5)
      ]),
      child: Column(
        children: [
          Text(
            !isAvailable ? "GO ONLINE" : "GO OFFLINE",
            style: const TextStyle(fontFamily: "Bold-Font", fontSize: 20),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            !isAvailable
                ? "You are about to become available to receive trip requests"
                : "You will stop receiving new trip requests",
            textAlign: TextAlign.center,
            style: const TextStyle(color: MyColors.colorTextLight),
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            children: [
              Expanded(
                child: MyCustomButton(
                  title: "BACK",
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  onPress: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: MyCustomButton(
                  title: "CONFIRM",
                  backgroundColor:
                      !isAvailable ? MyColors.colorGreen : Colors.red,
                  onPress: onPress,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
