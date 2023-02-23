import 'package:cab_driver/config/firebase_options.dart';
import 'package:cab_driver/shared/resources/user_data.dart';
import 'package:cab_driver/shared/services/push_notification_service.dart';
import 'package:cab_driver/shared/utils/page_routes.dart';
import 'package:cab_driver/ui/screens/login_screen/login_screen.dart';
import 'package:cab_driver/ui/screens/main_screen/main_screen.dart';
import 'package:cab_driver/ui/screens/register_screen/register_screen.dart';
import 'package:cab_driver/ui/screens/vehicle_info_screen/vehicle_info_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var currentUser = await FirebaseAuth.instance.currentUser;
  var initPage = PagesRouteData.loginPage;
  if (currentUser != null) {
    UserData user = UserData();
    user.id = currentUser.uid;
    user.email = currentUser.email;
    DatabaseReference ref = FirebaseDatabase.instance.ref("driver/${user.id}");
    ref.once().then((DatabaseEvent dbEvent) {
      if (dbEvent.snapshot.value != null) {
        Map data = dbEvent.snapshot.value as Map;
        user.email = data['email'];
        user.fullName = data['fullName'];
        user.phone = data['phone'];
      }
    });
    initPage = PagesRouteData.mainPage;
    PushNotificationService pushNotificationService = PushNotificationService();
    await pushNotificationService.startService();
  }

  runApp(MyApp(initPage));
}

class MyApp extends StatelessWidget {
  final String initPage;
  const MyApp(this.initPage, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Regular-Font',
        primarySwatch: Colors.blue,
      ),
      initialRoute: initPage,
      routes: {
        PagesRouteData.mainPage: (context) => MainScreen(),
        PagesRouteData.loginPage: (context) => LoginScreen(),
        PagesRouteData.registerPage: (context) => RegisterScreen(),
        PagesRouteData.vehicleDetailsPage: (context) => VehicleInfoScreen(),
      },
    );
  }
}

//background notification handler
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  String messageTitle = message.notification!.title!;
  String messageBody = message.notification!.body!;
  Map<String, dynamic> dataValues = message.data;
}
