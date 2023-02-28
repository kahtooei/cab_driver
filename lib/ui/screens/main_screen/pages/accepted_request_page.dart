import 'dart:async';

import 'package:cab_driver/bloc/main_screen_bloc/main_screen_bloc.dart';
import 'package:cab_driver/bloc/main_screen_bloc/main_screen_status.dart';
import 'package:cab_driver/repository/models/direction.dart';
import 'package:cab_driver/repository/models/trip_request_model.dart';
import 'package:cab_driver/shared/resources/user_data.dart';
import 'package:cab_driver/shared/utils/colors.dart';
import 'package:cab_driver/ui/screens/main_screen/widget/end_trip_dialog.dart';
import 'package:cab_driver/ui/widgets/my_custom_buttom.dart';
import 'package:cab_driver/ui/widgets/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;

class AcceptedRequestPage extends StatefulWidget {
  final TripRequestModel trip;
  const AcceptedRequestPage(this.trip, {super.key});

  @override
  State<AcceptedRequestPage> createState() => _AcceptedRequestPageState();
}

class _AcceptedRequestPageState extends State<AcceptedRequestPage> {
  late DatabaseReference ref;
  late StreamSubscription<Position> currentPositionStream;
  late GoogleMapController mapController;
  late LatLng currentLocation;

  Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  List<LatLng> _points = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  double mapPadding = 0;
  bool isLoaded = false;
  String status = "accepted"; // accepted - arrived - onTrip - endTrip
  Color buttonColor = MyColors.colorGreen;
  String buttonTitle = "ARRIVED";
  String duration = "";
  late Timer timer;
  int tripDurationCounter = 0;
  BitmapDescriptor? carIcon;

  createCarIcon() {
    if (carIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "assets/images/car_android.png")
          .then((icon) {
        carIcon = icon;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    ref = FirebaseDatabase.instance
        .ref()
        .child("rideRequest/${widget.trip.requestToken}");
  }

  @override
  Widget build(BuildContext context) {
    createCarIcon();
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(top: 30, bottom: mapPadding),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: _polylines,
            markers: _markers,
            circles: _circles,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
              setState(() {
                mapPadding = 270;
              });
              if (!isLoaded) {
                currentLocation = BlocProvider.of<MainScreenBloc>(context)
                    .state
                    .currentPosition;
                acceptTrip();
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) =>
                      const ProgressDialog("get pickup direction"),
                );
                BlocProvider.of<MainScreenBloc>(context).add(
                    GetRouteDirectionEvent(
                        startPosition: BlocProvider.of<MainScreenBloc>(context)
                            .state
                            .currentPosition,
                        endPosition: widget.trip.pickupCoordinate!));
                isLoaded = true;
              }

              updateCurrentLocation();
            },
          ),
          BlocListener<MainScreenBloc, MainScreenState>(
            listenWhen: (previous, current) {
              if (previous.routeDirection != current.routeDirection) {
                return true;
              }
              return false;
            },
            listener: (context, state) {
              if (state.routeDirection is CompleteDirectionsStatus) {
                Navigator.pop(context);
              }
              LatLng end = LatLng(widget.trip.pickupCoordinate!.latitude,
                  widget.trip.pickupCoordinate!.longitude);
              if (status == "arrived") {
                end = LatLng(widget.trip.destinationCoordinate!.latitude,
                    widget.trip.destinationCoordinate!.longitude);
              }
              _points.clear();
              _polylines.clear();
              _markers.clear();
              _circles.clear();

              //update polyline for current directions

              DirectionModel direction =
                  (state.routeDirection as CompleteDirectionsStatus).direction;
              String encoded_points = direction.encodedPoints!;
              duration = direction.durationText!;
              PolylinePoints polylinePoints = PolylinePoints();
              List<PointLatLng> result =
                  polylinePoints.decodePolyline(encoded_points);
              for (PointLatLng point in result) {
                _points.add(LatLng(point.latitude, point.longitude));
              }
              Polyline polyline = Polyline(
                polylineId: PolylineId('id'),
                color: Colors.blue,
                points: _points,
                width: 4,
                jointType: JointType.round,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
                geodesic: true,
              );
              _polylines.add(polyline);

              //fitting polyline on map

              LatLngBounds bounds = getBounds(currentLocation, end);
              mapController
                  .animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

              //set markers
              Marker startMarker = Marker(
                  markerId: const MarkerId('start'),
                  position: currentLocation,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                  infoWindow: const InfoWindow(title: 'Your Location'));
              Marker endMarker = Marker(
                  markerId: const MarkerId('end'),
                  position: LatLng(widget.trip.pickupCoordinate!.latitude,
                      widget.trip.pickupCoordinate!.longitude),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                  infoWindow: const InfoWindow(snippet: 'Pickup Location'));

              _markers.add(startMarker);
              _markers.add(endMarker);

              //set Circles
              Circle startCircle = Circle(
                  circleId: CircleId('start'),
                  strokeWidth: 5,
                  strokeColor: MyColors.colorGreen,
                  radius: 12,
                  center: currentLocation,
                  fillColor: MyColors.colorGreen);

              Circle endCircle = Circle(
                  circleId: CircleId('end'),
                  strokeWidth: 5,
                  strokeColor: MyColors.colorAccentPurple,
                  radius: 12,
                  center: LatLng(widget.trip.pickupCoordinate!.latitude,
                      widget.trip.pickupCoordinate!.longitude),
                  fillColor: MyColors.colorAccentPurple);

              _circles.add(startCircle);
              _circles.add(endCircle);

              setState(() {});
            },
            child: Container(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 270,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 5, spreadRadius: 0.5, color: Colors.black38)
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    duration,
                    style: TextStyle(
                        color: MyColors.colorBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.trip.riderName!,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Bold-Font"),
                      ),
                      const Icon(Icons.call)
                    ],
                  ),
                  const SizedBox(
                    height: 30,
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
                          widget.trip.pickupLocation!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 18),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
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
                          widget.trip.destinationLocation!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 18),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: MyCustomButton(
                        onPress: () {
                          if (status == "accepted") {
                            showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (context) => const ProgressDialog(
                                  "get destination direction"),
                            );
                            BlocProvider.of<MainScreenBloc>(context).add(
                                GetRouteDirectionEvent(
                                    startPosition:
                                        BlocProvider.of<MainScreenBloc>(context)
                                            .state
                                            .currentPosition,
                                    endPosition:
                                        widget.trip.destinationCoordinate!));
                            setState(() {
                              status = "arrived";
                              buttonTitle = "START TRIP";
                              buttonColor = MyColors.colorAccentPurple;
                            });
                            ref.child("status").set(status);
                          } else if (status == "arrived") {
                            status = "onTrip";
                            ref.child("status").set(status);
                            timer = Timer.periodic(
                              const Duration(seconds: 1),
                              (timer) {
                                tripDurationCounter++;
                              },
                            );
                            setState(() {
                              buttonTitle = "END TRIP";
                              buttonColor = Colors.redAccent;
                            });
                          } else if (status == "onTrip") {
                            timer.cancel();
                            currentPositionStream.cancel();
                            int faires = estimateFares();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => EndTripDialog(
                                  widget.trip.paymentMethod ?? "cash", faires),
                            );
                            status = "endTrip";
                            ref.child("status").set(status);
                            ref.child("faires").set("\$$faires");
                            updateEarning(faires);
                            DatabaseReference driverref = FirebaseDatabase
                                .instance
                                .ref()
                                .child("driver/${UserData().id}/newTrip");
                            driverref.set("waiting");
                          }
                        },
                        title: buttonTitle,
                        backgroundColor: buttonColor,
                      )),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LatLngBounds getBounds(LatLng start, LatLng end) {
    if (start.latitude > end.latitude && start.longitude > end.longitude) {
      return LatLngBounds(
          southwest: LatLng(end.latitude, end.longitude),
          northeast: LatLng(start.latitude, start.latitude));
    } else if (start.latitude > end.longitude) {
      return LatLngBounds(
          southwest: LatLng(start.latitude, start.latitude),
          northeast: LatLng(end.latitude, end.longitude));
    } else if (start.latitude > end.latitude) {
      return LatLngBounds(
          southwest: LatLng(end.latitude, end.longitude),
          northeast: LatLng(start.latitude, start.latitude));
    } else {
      return LatLngBounds(
          southwest: LatLng(start.latitude, start.latitude),
          northeast: LatLng(end.latitude, end.longitude));
    }
  }

  acceptTrip() {
    ref.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        UserData driver = UserData();
        ref.child("status").set("accepted");
        Map driverInfo = {
          "driverId": driver.id,
          "driverName": driver.fullName,
          "driverPhone": driver.phone,
          "driverLocation": {
            "latitude": currentLocation.latitude,
            "longitude": currentLocation.longitude
          }
        };
        ref.child("driverInfo").set(driverInfo);
      }
    });
  }

  updateCurrentLocation() {
    double rotation = 0;

    currentPositionStream =
        Geolocator.getPositionStream().listen((Position position) {
      rotation = mp.SphericalUtil.computeHeading(
              mp.LatLng(currentLocation.latitude, currentLocation.longitude),
              mp.LatLng(position.latitude, position.longitude))
          .toDouble();
      currentLocation = LatLng(position.latitude, position.longitude);
      Marker carLocation = Marker(
          markerId: const MarkerId("carLocation"),
          position: currentLocation,
          rotation: rotation,
          icon: carIcon!,
          infoWindow: const InfoWindow(title: 'car location'));
      CameraPosition cameraPosition =
          CameraPosition(target: currentLocation, zoom: 15);
      mapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      _markers.removeWhere((element) => element.markerId == "carLocation");
      _markers.add(carLocation);
      setState(() {});
    });
  }

  int estimateFares() {
    // $0.3 : per KM
    // $0.2 : per Minute
    // #3.0 : base
    var direction = (BlocProvider.of<MainScreenBloc>(context)
            .state
            .routeDirection as CompleteDirectionsStatus)
        .direction;
    double perMin = (tripDurationCounter / 60) * 0.2;
    double perKM = (direction.distanceValue! / 1000) * 0.3;
    int total = (perMin + perKM + 3).truncate();
    return total;
  }

  updateEarning(int faires) {
    DatabaseReference fairedb = FirebaseDatabase.instance
        .ref()
        .child("driver/${UserData().id}/earning");
    double earning = (faires.toDouble() * 0.85);
    fairedb.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        double lastEarning = double.parse(event.snapshot.value.toString());
        earning += lastEarning;
      }
      fairedb.set(earning.toStringAsFixed(2));
    });
  }
}
