import 'dart:async';

import 'package:cab_driver/shared/utils/colors.dart';
import 'package:cab_driver/ui/screens/main_screen/widget/availability_button.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTab extends StatefulWidget {
  HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  late Position _currentPosition;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    checkPermission();
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
              child: AvailabilityButton(title: "GO ONLINE", onPress: () {})),
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
}
