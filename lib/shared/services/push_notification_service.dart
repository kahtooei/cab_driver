// ignore_for_file: use_build_context_synchronously

import 'package:cab_driver/main.dart';
import 'package:cab_driver/repository/models/trip_request_model.dart';
import 'package:cab_driver/shared/resources/user_data.dart';
import 'package:cab_driver/ui/screens/main_screen/widget/show_notification_dialog.dart';
import 'package:cab_driver/ui/widgets/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

class PushNotificationService {
  FirebaseMessaging fcm = FirebaseMessaging.instance;
  final BuildContext context;
  PushNotificationService(this.context);

  Future initialize() async {
    FirebaseMessaging.onMessage.listen(handleNewMessage);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future getToken() async {
    String? token = await fcm.getToken();
    //add token to database
    UserData user = UserData();
    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child("driver/${user.id}/token");
    ref.set(token);

    //subscribe to topics
    await FirebaseMessaging.instance.subscribeToTopic('allDrivers');
    await FirebaseMessaging.instance.subscribeToTopic('allUsers');
  }

  handleNewMessage(RemoteMessage message) async {
    String messageTitle = message.notification!.title!;
    String messageBody = message.notification!.body!;
    Map<String, dynamic> dataValues = message.data;
    getRequestInfo(dataValues['requestToken'], context);
  }

  Future startService() async {
    await initialize();
    await getToken();
  }

  Future<TripRequestModel> getRequestInfo(
      String requestToken, BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const ProgressDialog("Fetching Request Info"));

    TripRequestModel trip = TripRequestModel();
    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child("rideRequest/$requestToken");
    await ref.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        Map snapshot = event.snapshot.value as Map;
        trip.requestToken = requestToken;
        trip.userId = "tempUserId";

        trip.pickupLocation = snapshot['pickupLocation']['latitude'].toString();
        trip.pickupLocation =
            snapshot['pickupLocation']['longitude'].toString();
        trip.pickupCoordinate = LatLng(snapshot['pickupLocation']['latitude'],
            snapshot['pickupLocation']['longitude']);

        trip.destinationLocation =
            snapshot['destinationLocation']['latitude'].toString();
        trip.destinationLocation =
            snapshot['destinationLocation']['longitude'].toString();
        trip.destinationCoordinate = LatLng(
            snapshot['destinationLocation']['latitude'],
            snapshot['destinationLocation']['longitude']);

        trip.paymentMethod = snapshot['paymentMethod'];
        trip.riderName = snapshot['riderName'];
      }
    });
    Navigator.pop(context);
    if (trip.userId != null) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => ShowNotificationDialog(trip),
      );
    }

    return trip;
  }
}
