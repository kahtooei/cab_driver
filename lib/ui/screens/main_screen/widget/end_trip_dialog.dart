import 'package:cab_driver/shared/resources/user_data.dart';
import 'package:cab_driver/shared/utils/colors.dart';
import 'package:cab_driver/ui/widgets/my_custom_buttom.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class EndTripDialog extends StatelessWidget {
  final String paymentMethod;
  final int faires;
  const EndTripDialog(this.paymentMethod, this.faires, {super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${paymentMethod.toUpperCase()} PAYMENT",
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Bold-Font"),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(
                height: 1,
                color: Colors.black38,
              ),
            ),
            Image.asset(
              "assets/images/taxi.png",
              width: 100,
            ),
            const SizedBox(
              height: 25,
            ),
            Text(
              "\$$faires",
              style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Bold-Font"),
            ),
            const SizedBox(
              height: 25,
            ),
            const Text(
              "amount above is the total fares to be charged to the ride",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Row(
              children: [
                Expanded(
                    child: MyCustomButton(
                  onPress: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  title: paymentMethod == "cash" ? "COLLECT CASH" : "CONFIRM",
                  textColor: Colors.white,
                  backgroundColor: MyColors.colorGreen,
                )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
