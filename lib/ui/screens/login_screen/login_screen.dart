import 'package:cab_driver/shared/resources/user_data.dart';
import 'package:cab_driver/shared/services/push_notification_service.dart';
import 'package:cab_driver/shared/utils/page_routes.dart';
import 'package:cab_driver/shared/utils/show_snackbar.dart';
import 'package:cab_driver/ui/widgets/my_custom_buttom.dart';
import 'package:cab_driver/ui/widgets/progress_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _txtEmailControlle = TextEditingController();
  final _txtPasswordControlle = TextEditingController();

  late BuildContext _context;

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "Sign In as Driver",
                  style: TextStyle(
                      fontFamily: 'Bold-Font',
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 30),
                  child: Column(
                    children: [
                      TextField(
                        controller: _txtEmailControlle,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          label: Text("Email Address"),
                          labelStyle:
                              TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _txtPasswordControlle,
                        keyboardType: TextInputType.visiblePassword,
                        obscuringCharacter: "*",
                        obscureText: true,
                        decoration: const InputDecoration(
                          label: Text("Password"),
                          labelStyle:
                              TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: MyCustomButton(
                              onPress: login,
                              title: "LOGIN",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          TextButton(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    PagesRouteData.registerPage,
                                    (route) => false);
                              },
                              child: const Text("Sign Up here"))
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  login() async {
    showDialog(
        context: _context,
        barrierDismissible: false,
        builder: (context) => const ProgressDialog("Logging Progress"));
    if (checkFields()) {
      try {
        if (!await checkConnectivity()) {
          Navigator.pop(_context);
          showSnackBar("No Internet Connection", _context);
          return;
        }
        final _auth = FirebaseAuth.instance;
        UserCredential _user = await _auth.signInWithEmailAndPassword(
            email: _txtEmailControlle.text,
            password: _txtPasswordControlle.text);
        if (_user == null) {
          Navigator.pop(_context);
          showSnackBar("Wrong Email or Password", _context);
        } else {
          DatabaseReference ref =
              FirebaseDatabase.instance.ref("driver/${_user.user!.uid}");

          ref.once().then((DatabaseEvent dbEvent) async {
            if (dbEvent.snapshot.value != null) {
              Map data = dbEvent.snapshot.value as Map;
              UserData user = UserData();
              user.email = data['email'];
              user.fullName = data['fullName'];
              user.phone = data['phone'];
              user.id = _user.user!.uid;
              PushNotificationService pushNotificationService =
                  PushNotificationService();
              await pushNotificationService.initialize();
              await pushNotificationService.getToken();
              Navigator.pushNamedAndRemoveUntil(
                  _context, PagesRouteData.mainPage, (route) => false);
            } else {
              Navigator.pop(_context);
              showSnackBar("User Profile Data Not Found", _context);
            }
          });
        }
      } on FirebaseAuthException catch (e) {
        Navigator.pop(_context);
        if (e.code == 'user-not-found') {
          showSnackBar("No user found", _context);
        } else if (e.code == 'wrong-password') {
          showSnackBar("Wrong password", _context);
        }
      } catch (e) {
        Navigator.pop(_context);
      }
    } else {
      Navigator.pop(_context);
    }
  }

  Future<bool> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      print("Connection : ${ConnectivityResult.mobile}");
      return true;
    }
    return false;
  }

  bool checkFields() {
    if (_txtEmailControlle.text.length < 6 ||
        !_txtEmailControlle.text.contains("@")) {
      showSnackBar("Invalid Email Address", _context);
      return false;
    }

    if (_txtPasswordControlle.text.length < 8) {
      showSnackBar("Valid Password has more than 8 characters", _context);
      return false;
    }
    return true;
  }

  // showSnackBar(String txt) {
  //   var snackBar = SnackBar(
  //     content: Text(txt),
  //   );
  //   ScaffoldMessenger.of(_context).showSnackBar(snackBar);
  // }
}
