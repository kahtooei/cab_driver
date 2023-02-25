import 'package:cab_driver/main.dart';
import 'package:cab_driver/shared/resources/user_data.dart';
import 'package:cab_driver/ui/widgets/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

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
}

Future<Map<String, dynamic>> getRequestInfo(
    String requestToken, BuildContext context) async {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ProgressDialog("Fetching Request Info"));

  Map<String, dynamic> requestInfo = {};
  DatabaseReference ref =
      FirebaseDatabase.instance.ref().child("rideRequest/$requestToken");
  await ref.once().then((DatabaseEvent event) {
    if (event.snapshot.value != null) {
      Map snapshot = event.snapshot.value as Map;
      requestInfo['requestToken'] = requestToken;

      requestInfo['pickupLatitude'] = snapshot['pickupLocation']['latitude'];
      requestInfo['pickupLongitude'] = snapshot['pickupLocation']['longitude'];

      requestInfo['destinationLatitude'] =
          snapshot['destinationLocation']['latitude'];
      requestInfo['destinationLongitude'] =
          snapshot['destinationLocation']['longitude'];

      requestInfo['paymentMethod'] = snapshot['paymentMethod'];
      requestInfo['riderName'] = snapshot['riderName'];
    }
  });
  Navigator.pop(context);

  return requestInfo;
}
