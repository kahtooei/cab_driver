import 'package:cab_driver/shared/utils/colors.dart';
import 'package:cab_driver/ui/widgets/my_custom_buttom.dart';
import 'package:flutter/material.dart';

class ConfirmSheet extends StatelessWidget {
  const ConfirmSheet({super.key});

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
          const Text(
            "GO ONLINE",
            style: TextStyle(fontFamily: "Bold-Font", fontSize: 20),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "You are about to become available to receive trip requests",
            textAlign: TextAlign.center,
            style: TextStyle(color: MyColors.colorTextLight),
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
                  backgroundColor: MyColors.colorGreen,
                  onPress: () {},
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
