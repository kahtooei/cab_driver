import 'package:cab_driver/repository/models/trip_request_model.dart';
import 'package:cab_driver/shared/utils/colors.dart';
import 'package:cab_driver/ui/widgets/my_custom_buttom.dart';
import 'package:flutter/material.dart';

class ShowNotificationDialog extends StatelessWidget {
  const ShowNotificationDialog(this.trip, {super.key});

  final TripRequestModel trip;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        // height: 200,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/taxi.png",
              width: 100,
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              "NEW TRIP REQUEST",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Bold-Font"),
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              children: [
                Image.asset(
                  "assets/images/pickicon.png",
                  height: 16,
                  width: 16,
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    trip.pickupLocation!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 18),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Image.asset(
                  "assets/images/desticon.png",
                  height: 16,
                  width: 16,
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    trip.destinationLocation!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 18),
                  ),
                )
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Divider(
                height: 1,
                color: Colors.black12,
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: MyCustomButton(
                  onPress: () => Navigator.pop(context),
                  title: "DECLINE",
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                )),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                    child: MyCustomButton(
                  onPress: () {},
                  title: "ACCEPT",
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
