import 'dart:async';

import 'package:cab_driver/bloc/main_screen_bloc/main_screen_bloc.dart';
import 'package:cab_driver/bloc/main_screen_bloc/main_screen_status.dart';
import 'package:cab_driver/repository/models/direction.dart';
import 'package:cab_driver/repository/models/trip_request_model.dart';
import 'package:cab_driver/shared/utils/colors.dart';
import 'package:cab_driver/ui/widgets/my_custom_buttom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class AcceptedRequestPage extends StatefulWidget {
  final TripRequestModel trip;
  const AcceptedRequestPage(this.trip, {super.key});

  @override
  State<AcceptedRequestPage> createState() => _AcceptedRequestPageState();
}

class _AcceptedRequestPageState extends State<AcceptedRequestPage> {
  late GoogleMapController mapController;

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
  String duration = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                BlocProvider.of<MainScreenBloc>(context).add(
                    GetRouteDirectionEvent(
                        startPosition: BlocProvider.of<MainScreenBloc>(context)
                            .state
                            .currentPosition,
                        endPosition: widget.trip.pickupCoordinate!));
                isLoaded = true;
              }
            },
          ),
          BlocListener<MainScreenBloc, MainScreenState>(
            listenWhen: (previous, current) {
              if (previous.routeDirection != current.routeDirection &&
                  current.routeDirection is CompleteDirectionsStatus) {
                return true;
              }
              return false;
            },
            listener: (context, state) {
              _points.clear();
              _polylines.clear();
              _markers.clear();
              _circles.clear();

              //update polyline for current directions
              LatLng end = LatLng(widget.trip.pickupCoordinate!.latitude,
                  widget.trip.pickupCoordinate!.longitude);
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

              LatLngBounds bounds = getBounds(state.currentPosition, end);
              mapController
                  .animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

              //set markers
              Marker startMarker = Marker(
                  markerId: const MarkerId('start'),
                  position: LatLng(state.currentPosition.latitude,
                      state.currentPosition.longitude),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                  infoWindow: const InfoWindow(snippet: 'Your Location'));
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
                  center: LatLng(state.currentPosition.latitude,
                      state.currentPosition.longitude),
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
                        onPress: () {},
                        title: "ARRIVED",
                        backgroundColor: MyColors.colorGreen,
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
}
