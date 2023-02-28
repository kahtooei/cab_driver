import 'dart:async';

import 'package:cab_driver/bloc/main_screen_bloc/main_screen_bloc.dart';
import 'package:cab_driver/repository/models/trip_request_model.dart';
import 'package:cab_driver/shared/resources/user_data.dart';
import 'package:cab_driver/shared/utils/colors.dart';
import 'package:cab_driver/ui/screens/main_screen/pages/accepted_request_page.dart';
import 'package:cab_driver/ui/screens/main_screen/widget/confirm_sheet.dart';
import 'package:cab_driver/ui/screens/main_screen/widget/end_trip_dialog.dart';
import 'package:cab_driver/ui/screens/main_screen/widget/show_notification_dialog.dart';
import 'package:cab_driver/ui/widgets/my_custom_buttom.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTab extends StatefulWidget {
  HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool isAvailable = false;
  late GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  late DatabaseReference driverDB;
  late UserData driver;

  late Position _currentPosition;
  var geoLocator = Geolocator();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    driver = UserData();
    checkPermission();
    driverDB =
        FirebaseDatabase.instance.ref().child("driver/${driver.id}/newTrip");
  }

  checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission.name == "denied" || permission.name == "deniedForever") {
      LocationPermission reqPermission = await Geolocator.requestPermission();
      permission = reqPermission;
    }

    if (permission.name == "whileInUse" || permission.name == "always") {
      bool serviceEnabled =
          await _geolocatorPlatform.isLocationServiceEnabled();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: const EdgeInsets.only(top: 100),
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          // polylines: _polylines,
          // markers: _markers,
          // circles: _circles,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            mapController = controller;

            // setState(() {
            //   mapPadding = 300;
            // });
            setCurrentPosition();
          },
        ),
        Container(
          height: 100,
          width: double.infinity,
          decoration: const BoxDecoration(color: MyColors.colorPrimary),
          child: Center(
              child: SizedBox(
            width: 200,
            child: MyCustomButton(
                title: !isAvailable ? "GO ONLINE" : "GO OFFLINE",
                backgroundColor:
                    !isAvailable ? MyColors.colorOrange : MyColors.colorGreen,
                onPress: () {
                  showModalBottomSheet(
                    isDismissible: false,
                    context: context,
                    builder: (context) => ConfirmSheet(
                        isAvailable: isAvailable,
                        onPress: isAvailable ? goOffline : goOnline),
                  );
                }),
          )),
        )
      ],
    );
  }

  setCurrentPosition() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition();

      LatLng currentPos =
          LatLng(_currentPosition.latitude, _currentPosition.longitude);
      CameraPosition currentCP = CameraPosition(target: currentPos, zoom: 14);
      mapController.animateCamera(CameraUpdate.newCameraPosition(currentCP));
      // BlocProvider.of<MainScreenBloc>(context).add(GetCurrentAddressEvent(
      //     latitude: _currentPosition.latitude,
      //     longitude: _currentPosition.longitude));
    } catch (e) {}
  }

  goOnline() {
    UserData user = UserData();
    Geofire.initialize("driversAvailable");
    Geofire.setLocation(
        driver.id, _currentPosition.latitude, _currentPosition.longitude);
    driverDB.set("waiting");
    driverDB.onValue.listen((event) {});
    updateLocation();
    setState(() {
      isAvailable = true;
    });
    Navigator.pop(context);
  }

  goOffline() {
    Geofire.removeLocation(UserData().id);
    driverDB.onDisconnect();
    driverDB.remove();
    setState(() {
      isAvailable = false;
    });
    Navigator.pop(context);
  }

  updateLocation() {
    Geolocator.getPositionStream().listen((position) {
      _currentPosition = position;
      BlocProvider.of<MainScreenBloc>(context).add(UpdateCurrentAddressEvent(
          latitude: position.latitude, longitude: position.longitude));
      if (isAvailable) {
        Geofire.setLocation(
            UserData().id, position.latitude, position.longitude);
      }
      LatLng currentPos =
          LatLng(_currentPosition.latitude, _currentPosition.longitude);
      CameraPosition currentCP = CameraPosition(target: currentPos, zoom: 14);
      mapController.animateCamera(CameraUpdate.newCameraPosition(currentCP));
    });
  }
}
