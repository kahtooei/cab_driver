import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cab_driver/repository/models/trip_request_model.dart';
import 'package:cab_driver/shared/resources/user_data.dart';
import 'package:cab_driver/shared/utils/colors.dart';
import 'package:cab_driver/shared/utils/show_snackbar.dart';
import 'package:cab_driver/ui/screens/main_screen/pages/accepted_request_page.dart';
import 'package:cab_driver/ui/widgets/my_custom_buttom.dart';
import 'package:cab_driver/ui/widgets/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';

class ShowNotificationDialog extends StatelessWidget {
  ShowNotificationDialog(this.trip, {super.key});

  final TripRequestModel trip;
  AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

  @override
  Widget build(BuildContext context) {
    audioPlayer.open(
      Audio("assets/sounds/alert.mp3"),
      autoStart: true,
      showNotification: false,
    );
    audioPlayer.play();
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
                  onPress: () {
                    audioPlayer.stop();
                    Navigator.pop(context);
                  },
                  title: "DECLINE",
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                )),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                    child: MyCustomButton(
                  onPress: () {
                    audioPlayer.stop();
                    checkAvailability(context);
                  },
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

  checkAvailability(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ProgressDialog("Checking Availability"),
    );
    UserData driver = UserData();
    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child("driver/${driver.id}/newTrip");
    ref.once().then((DatabaseEvent event) {
      Navigator.pop(context); // for checking availability dialog
      Navigator.pop(context); // for navigation dialog
      String value = event.snapshot.value.toString();
      if (value != null) {
        if (value == trip.requestToken) {
          ref.set("accepted");
          Geofire.removeLocation(driver.id);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AcceptedRequestPage(trip),
              ));
        } else if (value == "canceled") {
          //request canceled
          showSnackBar("Request Canceled", context);
        } else if (value == "timeout") {
          //request timed out
          showSnackBar("Request TimedOut", context);
        } else {
          //other...
          showSnackBar("Request didn't find...!!!", context);
        }
      }
    });
  }
}
