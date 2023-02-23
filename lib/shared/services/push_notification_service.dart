import 'package:cab_driver/main.dart';
import 'package:cab_driver/shared/resources/user_data.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  FirebaseMessaging fcm = FirebaseMessaging.instance;

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
  }

  Future startService() async {
    await initialize();
    await getToken();
  }
}
