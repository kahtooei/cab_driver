import 'package:cab_driver/shared/resources/user_data.dart';
import 'package:cab_driver/shared/utils/page_routes.dart';
import 'package:cab_driver/shared/utils/show_snackbar.dart';
import 'package:cab_driver/ui/widgets/my_custom_buttom.dart';
import 'package:cab_driver/ui/widgets/progress_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class VehicleInfoScreen extends StatelessWidget {
  VehicleInfoScreen({super.key});

  final _txtCarModelControlle = TextEditingController();
  final _txtCarColorControlle = TextEditingController();
  final _txtCarNumberControlle = TextEditingController();

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
                  "Enter Vehicle Details",
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
                        keyboardType: TextInputType.text,
                        controller: _txtCarModelControlle,
                        decoration: const InputDecoration(
                          label: Text("Car model"),
                          labelStyle:
                              TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _txtCarColorControlle,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          label: Text("Car color"),
                          labelStyle:
                              TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _txtCarNumberControlle,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          label: Text("Car number"),
                          labelStyle:
                              TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      MyCustomButton(
                        onPress: doRegisterCar,
                        title: "PROCEED",
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

  void doRegisterCar() async {
    showDialog(
        context: _context,
        barrierDismissible: false,
        builder: (context) => const ProgressDialog("Register Car Progress"));
    if (checkFields()) {
      try {
        if (!await checkConnectivity()) {
          Navigator.pop(_context);
          showSnackBar("No Internet Connection", _context);
          return;
        }

        DatabaseReference ref =
            FirebaseDatabase.instance.ref("driver/${UserData().id}");
        Map carDetails = {
          "carModel": _txtCarModelControlle.text,
          "carColor": _txtCarColorControlle.text,
          "carNumber": _txtCarNumberControlle.text,
        };
        ref.once().then((DatabaseEvent dbEvent) async {
          if (dbEvent.snapshot.value != null) {
            await setVehicle(carDetails);
            Navigator.pushNamedAndRemoveUntil(
                _context, PagesRouteData.mainPage, (route) => false);
          } else {
            Navigator.pop(_context);
            showSnackBar("User Profile Data Not Found", _context);
          }
        });
      } catch (e) {
        Navigator.pop(_context);
        showSnackBar('Error...', _context);
      }
    } else {
      Navigator.pop(_context);
    }
  }

  setVehicle(Map vehicleDetails) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("driver/${UserData().id}/vehicleDetails");
    await ref.set(vehicleDetails);
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
    if (_txtCarModelControlle.text.length < 4) {
      showSnackBar("Valid Car model has more than 3 characters", _context);
      return false;
    }
    if (_txtCarColorControlle.text.length < 3) {
      showSnackBar("Invalid Car color", _context);
      return false;
    }
    if (_txtCarNumberControlle.text.length < 5) {
      showSnackBar("Invalid Car Number", _context);
      return false;
    }
    return true;
  }
}
